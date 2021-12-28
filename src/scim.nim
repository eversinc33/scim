import std/nativesockets
import std/net
import protocols/[ipv4, udp]

when isMainModule:
    let socket = newsocket(AF_INET, SOCK_RAW, IPPROTO_RAW)
    let udp_payload = [byte 0xDE, 0xAD, 0x00, 0xAF, 0x00]
    
    var total_len: uint16 = sizeof(IPv4_Header) + sizeof(UDP_Header) + udp_payload.len()

    var packet = h_IP(IP_LOOPBACK_ADDR, IP_LOOPBACK_ADDR, protocol=IP_PROTOCOL_UDP, total_length=total_len) + (h_UDP(333, 666) + udp_payload)

    var send_buf: ptr byte = cast[ptr byte](alloc(total_len))
    send_buf.zeroMem(total_len)
    copyMem(send_buf, packet.to_buf(), total_len)

    echo(repr(packet))

    var address = "127.0.0.1"
    var port = Port(666)
    socket.sendto(address, port, send_buf, int(total_len))

    socket.close()
