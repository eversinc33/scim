import std/bitops
import std/nativesockets
import ./udp
import ./tcp
import ../common/osi_layers

const
    IPv4_HEADER_SIZE* = 20

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
        data*: ptr TransportLayerPacket
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
    return bitnot(uint16(checksum))

method to_buf*(packet: IPv4_Packet): ptr byte =
    var buf = cast[ptr byte](alloc(packet.get_length()))
    buf.zeroMem(packet.get_length())

    # copy header
    copyMem(buf, unsafeAddr packet.header, IPv4_HEADER_SIZE)

    # copy encapsulated data
    if packet.metadata.has_encapsulated_payload:
        var p_payload = cast[int](buf) + IPv4_HEADER_SIZE
        copyMem(cast[ptr byte](p_payload), packet.data[].to_buf(), uint16(packet.get_length() - IPv4_HEADER_SIZE))

    return buf

proc h_IP*(
        src_addr, dst_addr: uint32, 
        id: uint16 = 10201, 
        protocol: uint8 = IP_PROTOCOL_TCP, 
        total_length: uint16 = uint16(IPv4_HEADER_SIZE)
    ): IPv4_Packet =

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
            total_length: htons(total_length)
         )
    )

    result.header.checksum = calc_ipv4_checksum(result.header)

method get_length*(packet: IPv4_Packet): int =
    return int(ntohs(packet.header.total_length))

proc `+`*(ippkt: IPv4_Packet, udppkt: UDP_Packet): IPv4_Packet =
    result = ippkt
    result.metadata.has_encapsulated_payload = true

    # set protocol and data
    result.header.proto = IP_PROTOCOL_UDP
    result.data = unsafeAddr udppkt

    # recalc length and checksum
    result.header.total_length = htons(uint16(IPv4_HEADER_SIZE + udppkt.get_length()))
    result.header.checksum = calc_ipv4_checksum(result.header)

proc `+`*(ippkt: IPv4_Packet, tcppkt: TCP_Packet): IPv4_Packet =
    result = ippkt
    result.metadata.has_encapsulated_payload = true

    # set protocol and data
    result.header.proto = IP_PROTOCOL_TCP
    result.data = unsafeAddr tcppkt

    # recalc length and checksum
    result.header.total_length = htons(uint16(IPv4_HEADER_SIZE + tcppkt.get_length()))
    result.header.checksum = calc_ipv4_checksum(result.header)