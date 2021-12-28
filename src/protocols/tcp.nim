#[

    TODO: add header fields and processing

]#

import std/nativesockets
import ../common/osi_layers

type
    TCP_Header* = ref object
        # TODO
        #[
        src*: uint16
        dest*: uint16
        length*: uint16
        checksum*: uint16
        ]#

    TCP_Packet* = object of TransportLayerProtocol
        header*: TCP_Header
        payload*: ptr byte

proc h_TCP*(port_src, port_dst: uint16): TCP_Packet =
    result = TCP_Packet(
        header: TCP_Header(
            src: htons(port_src),
            dest: htons(port_dst),
            # TODO rest of fields
        )
    )

method to_buf*(packet: TCP_Packet): ptr byte =
    # alloc buffer
    var buf = cast[ptr byte](alloc(packet.header.length))
    buf.zeroMem(packet.header.length)

    # copy header
    copyMem(buf, cast[pointer](packet.header), sizeof(TCP_Header))

    # copy payload
    var payload_length = packet.header.length - uint16(sizeof(TCP_Header))
    var payload_pointer = cast[ptr byte](
        cast[int](buf) + sizeof(TCP_Header)
    )
    copyMem(payload_pointer, packet.payload, payload_length)

    return buf


proc `+`*(tcppkt: TCP_Packet, tcp_payload: openArray[byte]): TCP_Packet =
    result = tcppkt
    result.header.length = htons(uint16(sizeof(TCP_Header)) + uint16(tcp_payload.len)) 

    # copy payload
    var p = cast[ptr byte](alloc(tcp_payload.len))

    p.zeroMem(sizeof(tcp_payload))
    copyMem(p, unsafeAddr tcp_payload, sizeof(TCP_Header))
    result.payload = p