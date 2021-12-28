import std/nativesockets
import ../common/osi_layers

type
    UDP_Header* = ref object
        src*: uint16
        dest*: uint16
        length*: uint16
        checksum*: uint16

    UDP_Packet* = object of TransportLayerProtocol
        header*: ptr byte
        payload*: ptr byte

proc h_UDP*(port_src, port_dst: uint16): UDP_Packet =
    var udphdr = UDP_Header()
    udphdr.src = htons(port_src)
    udphdr.dest = htons(port_dst)
    udphdr.checksum = 0 # TODO checksum

    result = UDP_Packet(header: cast[ptr byte](udphdr))

method to_buf*(packet: UDP_Packet): ptr byte =
    var hdrlen = cast[UDP_Header](packet.header).length
    var buf = cast[ptr byte](alloc(hdrlen))
    buf.zeroMem(hdrlen)

    # copy header
    copyMem(buf, packet.header, sizeof(UDP_Header))

    # copy payload
    var p_payload = cast[int](buf) + sizeof(UDP_Header)
    copyMem(cast[ptr byte](p_payload), packet.payload, hdrlen - uint16(sizeof(UDP_Header)))

    return buf


proc `+`*(udppkt: UDP_Packet, udp_payload: openArray[byte]): UDP_Packet =
    result = udppkt
    cast[UDP_Header](result.header).length = htons(uint16(sizeof(UDP_Header)) + uint16(udp_payload.len)) 

    # copy payload
    var p = cast[ptr byte](alloc(udp_payload.len))

    p.zeroMem(sizeof(udp_payload))
    copyMem(p, unsafeAddr udp_payload, sizeof(UDP_Header))
    result.payload = p