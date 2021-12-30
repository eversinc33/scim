import ../common/osi_layers
import ./ipv4   
import std/nativesockets

const
    ETH_ALEN* = 6
    ETH_FRAME_LEN* = 14
    ETH_P_IP* = 0x0800
    ETH_LOCALHOST*: array[ETH_ALEN, uint8]= [uint8(0x00), uint8(0x00), uint8(0x00), uint8(0x00), uint8(0x00), uint8(0x00)] 

type
    ETH_Header* = object
        dest*: array[ETH_ALEN, uint8]
        src*: array[ETH_ALEN, uint8]
        proto*: uint16

    ETH_Frame* = object
        header*: ETH_Header
        data*: ptr NetworkLayerPacket
        metadata: PacketMetaData

proc h_ETH*(dest, src: array[ETH_ALEN, uint8], proto = ETH_P_IP): ETH_Frame =
    result = ETH_Frame(
        header: ETH_Header(
            dest: dest,
            src: src,
            proto: uint16(proto)
        )
    )

    result.metadata.length = ETH_FRAME_LEN

method get_length*(frame: ETH_Frame): int =
    return int(frame.metadata.length)

method to_buf*(frame: ETH_Frame): ptr byte =
    # alloc buffer
    var buf = cast[ptr byte](alloc(frame.get_length()))
    buf.zeroMem(frame.get_length())

    # copy header
    copyMem(buf, unsafeAddr frame.header, ETH_FRAME_LEN)

    # copy encapsulated data
    if frame.metadata.has_encapsulated_payload:
        var payload_length = frame.get_length() - ETH_FRAME_LEN
        var payload_pointer = cast[ptr byte](
            cast[int](buf) + ETH_FRAME_LEN
        )
        copyMem(payload_pointer, frame.data, payload_length)

    return buf

proc `+`*(ethfrm: ETH_Frame, ippkt: IPv4_Packet): ETH_Frame =
    result = ethfrm
    result.metadata.has_encapsulated_payload = true

    # set protocol and data
    # result.header.proto = TODO
    result.data = unsafeAddr ippkt

    # recalc length
    result.metadata.length = htons(uint16(IPv4_HEADER_SIZE + ippkt.get_length()))
