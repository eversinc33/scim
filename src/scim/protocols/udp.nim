import std/nativesockets
import ../common/osi_layers

type
    UDP_Header* = ref object
        src*: uint16
        dest*: uint16
        length*: uint16
        checksum*: uint16

    UDP_Packet* = object of TransportLayerProtocol
        header*: UDP_Header
        payload*: ptr byte

proc h_UDP*(port_src, port_dst: uint16): UDP_Packet =
    result = UDP_Packet(
        header: UDP_Header(
            src: htons(port_src),
            dest: htons(port_dst),
            length: uint16(sizeof(UDP_Header)),
            checksum: 0 # TODO: calc checksum
        )
    )

method to_buf*(packet: UDP_Packet): ptr byte =
    # alloc buffer
    var buf = cast[ptr byte](alloc(packet.header.length))
    buf.zeroMem(packet.header.length)

    # copy header
    copyMem(buf, cast[pointer](packet.header), sizeof(UDP_Header))

    # copy payload
    var payload_length = packet.header.length - uint16(sizeof(UDP_Header))
    var payload_pointer = cast[ptr byte](
        cast[int](buf) + sizeof(UDP_Header)
    )
    copyMem(payload_pointer, packet.payload, payload_length)

    return buf


proc `+`*(udppkt: UDP_Packet, udp_payload: openArray[byte]): UDP_Packet =
    result = udppkt

    # calc packet length
    result.header.length = htons(uint16(sizeof(UDP_Header)) + uint16(udp_payload.len)) 

    # save udp payload to packet
    var p = cast[ptr byte](alloc(udp_payload.len))
    p.zeroMem(sizeof(udp_payload))
    copyMem(p, unsafeAddr udp_payload, sizeof(UDP_Header))
    result.payload = p