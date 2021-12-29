import std/nativesockets
import std/net
import common/osi_layers

proc send_packet*(total_len: uint16, packet: NetworkLayerPacket) =
    let socket = newsocket(AF_INET, SOCK_RAW, IPPROTO_RAW)
    defer: socket.close()

    # TODO: get length from packet
    var send_buf: ptr byte = cast[ptr byte](alloc(total_len))
    send_buf.zeroMem(total_len)
    copyMem(send_buf, packet.to_buf(), total_len)

    # TODO: get ip and port from packet
    socket.sendto("127.0.0.1", Port(1), send_buf, int(total_len))