import std/nativesockets
import ../common/osi_layers

const 
    UDP_HEADER_SIZE = 8

type
    UDP_Header* = ref object
        src*: uint16
        dest*: uint16
        length*: uint16
        checksum*: uint16

    UDP_Packet* = object of TransportLayerPacket
        header*: UDP_Header
        payload*: ptr byte

proc h_UDP*(port_src, port_dst: uint16): UDP_Packet =
    result = UDP_Packet(
        header: UDP_Header(
            src: htons(port_src),
            dest: htons(port_dst),
            length: uint16(UDP_HEADER_SIZE),
            checksum: 0 # TODO: calc checksum
        )
    )

method to_buf*(packet: UDP_Packet): ptr byte =

    # alloc buffer
    var buf = cast[ptr byte](alloc(packet.get_length()))
    buf.zeroMem(packet.get_length())

    # copy header
    copyMem(buf, cast[pointer](packet.header), UDP_HEADER_SIZE)

    # copy payload
    var payload_length = uint16(packet.get_length() - UDP_HEADER_SIZE)
    var payload_pointer = cast[ptr byte](
        cast[int](buf) + UDP_HEADER_SIZE
    )
    copyMem(payload_pointer, packet.payload, payload_length)

    return buf

method get_length*(packet: UDP_Packet): int =
    return int(ntohs(packet.header.length))


proc `+`*(udppkt: UDP_Packet, udp_payload: openArray[byte]): UDP_Packet =
    result = udppkt

    # save udp payload to packet
    var p = cast[ptr byte](alloc(udp_payload.len))
    p.zeroMem(sizeof(udp_payload))
    copyMem(p, unsafeAddr udp_payload, UDP_HEADER_SIZE)
    result.payload = p

    # calc packet length
    result.header.length = htons(uint16(UDP_HEADER_SIZE) + uint16(udp_payload.len)) 
    # TODO recalc checksum
