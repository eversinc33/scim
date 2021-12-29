import std/nativesockets
import ../common/osi_layers
import std/bitops
import strutils

const
    TCP_HEADER_LEN = 20

const
    TCP_FLAG_CWR*: uint8 = 0b10000000
    TCP_FLAG_ECE*: uint8 = 0b01000000
    TCP_FLAG_URG*: uint8 = 0b00100000
    TCP_FLAG_ACK*: uint8 = 0b00010000
    TCP_FLAG_PSH*: uint8 = 0b00001000
    TCP_FLAG_RST*: uint8 = 0b00000100
    TCP_FLAG_SYN*: uint8 = 0b00000010
    TCP_FLAG_FIN*: uint8 = 0b00000001

type
    TCP_Header* = ref object
        src*: uint16
        dest*: uint16
        sequence_num*: uint32
        acknowledgement_num*: uint32
        data_offset*: uint8
        flags*: uint8
        window*: uint16
        checksum*: uint16
        urgent_pointer*: uint16
        # TODO: options, 0 or more 32bit words 

    TCP_Packet* = object of TransportLayerPacket
        header*: TCP_Header
        payload*: ptr byte
        metadata*: PacketMetaData 

proc h_TCP*(port_src, port_dst: uint16, flags: uint8 = TCP_FLAG_SYN): TCP_Packet =

    # TODO calc this (data_offset): 
    # first 4 bits: length of tcp header in 32 bit blocks  (default 5)
    # last 4 bits: reserved, should be zero
    var len_off: uint8 = bitor(uint8(uint8(5) shl 4), uint8(0))

    result = TCP_Packet(
        header: TCP_Header(
            src: htons(port_src),
            dest: htons(port_dst),
            sequence_num: htons(1),
            acknowledgement_num: htons(0),
            data_offset: len_off, 
            flags: flags,
            window: htons(65495), # TODO reasonable default
            checksum: 0x0000, # TODO
            urgent_pointer: htons(0)
        )
    )

method to_buf*(packet: TCP_Packet): ptr byte =
    # alloc buffer
    var buf = cast[ptr byte](alloc(packet.get_length()))
    buf.zeroMem(packet.get_length())

    # copy header
    # TODO: FIXME: TCP_HEADER_LEN doesnt work when options are set
    copyMem(buf, cast[pointer](packet.header), TCP_HEADER_LEN)

    # copy encapsulated data
    if packet.metadata.has_encapsulated_payload:
        # TODO: FIXME: TCP_HEADER_LEN doesnt work when options are set
        var payload_length = packet.get_length() - TCP_HEADER_LEN
        var payload_pointer = cast[ptr byte](
            cast[int](buf) + TCP_HEADER_LEN
        )
        copyMem(payload_pointer, packet.payload, payload_length)

    return buf

method get_length*(packet: TCP_Packet): int =
    let length_in_32bit_words = uint8(bitand(packet.header.data_offset, uint8(0b11110000)) shr 4)
    return int(length_in_32bit_words * 4)

proc `+`*(tcppkt: TCP_Packet, tcp_payload: openArray[byte]): TCP_Packet =
    result = tcppkt
    result.metadata.has_encapsulated_payload = true

    # save TCP payload to packet
    var p = cast[ptr byte](alloc(tcp_payload.len))
    p.zeroMem(sizeof(tcp_payload))
    copyMem(p, unsafeAddr tcp_payload, sizeof(TCP_Header))
    result.payload = p

    # TODO calc packet length
    # result.set_length(htons(uint16(sizeof(TCP_Header)) + uint16(tcp_payload.len)))
    # TODO recalc checksum
