import std/nativesockets
import ../common/osi_layers

type
    UDP_Header* = ref object of Header
        src*: uint16
        dest*: uint16
        length*: uint16
        checksum*: uint16

    UDP_Packet* = ref object of TransportLayerProtocol
        header*: UDP_Header
        payload*: ptr byte

proc h_UDP*(port_src, port_dst: uint16): UDP_Packet =
    var udphdr = UDP_Header()
    udphdr.src = htons(port_src)
    udphdr.dest = htons(port_dst)
    udphdr.checksum = 0 # TODO checksum

    result = UDP_Packet(header: udphdr)

method to_buf*(packet: UDP_Packet): ptr byte =
    var buf = cast[ptr byte](alloc(packet.header.length))
    buf.zeroMem(packet.header.length)

    # copy header
    copyMem(buf, addr packet.header, sizeof(UDP_Header))

    # copy payload
    var p_payload = cast[int](buf) + sizeof(UDP_Header)
    copyMem(cast[ptr byte](p_payload), packet.payload, packet.header.length - uint16(sizeof(UDP_Header)))

    return buf


proc `+`*(udppkt: UDP_Packet, udp_payload: openArray[byte]): UDP_Packet =
    result = udppkt
    result.header.length = uint16(sizeof(UDP_Header) + sizeof(udp_payload))

    # copy payload
    var p = cast[ptr byte](alloc(sizeof(udp_payload)))
    p.zeroMem(sizeof(udp_payload))
    copyMem(p, unsafeAddr udp_payload, sizeof(UDP_Header))
    result.payload = p