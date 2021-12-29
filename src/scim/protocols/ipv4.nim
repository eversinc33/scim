import std/bitops
import std/nativesockets
import ./udp
import ../common/osi_layers

type
    IPv4_Header* = object
        ver_len*: uint8 # version | header length
        tos*: uint8     # type of service
        total_length*: uint16 # total packet length
        id*: uint16
        flags_fragoff*: uint16 # flags | fragment offset
        ttl*: uint8
        proto*: uint8
        checksum*: uint16
        src*: uint32
        dest*: uint32

    IPv4_Packet* = object of NetworkLayerPacket
        header*: IPv4_Header
        data*: ptr TransportLayerProtocol
        metadata*: PacketMetaData 

const 
    IP_LOOPBACK_ADDR* = 0x0100007F
    
    # protocol field values
    IP_PROTOCOL_TCP* = 6
    IP_PROTOCOL_UDP* = 17

    checksum_words = int(sizeof(IPv4_Header))

proc calc_ipv4_checksum*(ip_header: IPv4_Header): uint16 = 
    var ip_hdr = cast[ptr byte](unsafeAddr ip_header)

    # Set the checksum field to zero.
    var checksum: uint32 = 0x00000000

    var i = 0
    while i < checksum_words:

        # Reinterpret the data as a sequence of 16-bit unsigned integers that are in network byte order.
        var b1: uint8 = cast[ptr type(ip_hdr[])](cast[ByteAddress](ip_hdr) +% i * sizeof(ip_hdr[]))[]
        var b2: uint8 = cast[ptr type(ip_hdr[])](cast[ByteAddress](ip_hdr) +% (i+1) * sizeof(ip_hdr[]))[]
        var w: uint16 = bitor(uint16(b1) shl 8, b2)
        # Calculate the sum of the integers, subtracting 0xffff whenever the result reaches 0x10000 or greater.
        checksum += ntohs(w)
        if checksum > 0xffff:
            checksum -= 0xffff
        i += 2

    # Calculate the bitwise complement of the sum. This is the required value of the checksum field.
    return htons(bitnot(uint16(checksum)))

method to_buf*(packet: IPv4_Packet): ptr byte =
    var buf = cast[ptr byte](alloc(packet.header.total_length))
    buf.zeroMem(packet.header.total_length)

    # copy header
    copyMem(buf, unsafeAddr packet.header, sizeof(IPv4_Header))

    # copy encapsulated data
    if packet.metadata.has_encapsulated_payload:
        var p_payload = cast[int](buf) + sizeof(IPv4_Header)
        copyMem(cast[ptr byte](p_payload), packet.data[].to_buf(), packet.header.total_length - uint16(sizeof(IPv4_Header)))

    return buf

proc h_IP*(src_addr, dst_addr: uint32, id: uint16 = 10201, protocol: uint8 = IP_PROTOCOL_TCP, total_length: uint16 = uint16(sizeof(IPv4_header))): IPv4_Packet =

    let version: uint8 = uint8(4) shl 4
    let header_length: uint8 = 5

    result = IPv4_Packet(
        header: IPv4_Header(
            ver_len: bitor(version, header_length),
            tos: 16,
            id: htons(id),
            ttl: 64,
            proto: protocol,
            src: src_addr,
            dest: dst_addr,
            total_length: total_length
         )
    )

# TODO: when adding payload to payload, exec callback to adjust length and checksum
# TODO: overload `+` , add payload and adjust protocol depending on payload
proc `+`*(ippkt: IPv4_Packet, udppkt: UDP_Packet): IPv4_Packet =
    result = ippkt
    result.header.proto = IP_PROTOCOL_UDP
    result.data = unsafeAddr udppkt
    result.metadata.has_encapsulated_payload = true
