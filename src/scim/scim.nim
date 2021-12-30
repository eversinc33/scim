import std/nativesockets
import std/net
import protocols/[ipv4, ethernet]
import os

proc send_packet*(frame: ETH_Frame) =
    let socket = createNativeSocket(AF_INET, SOCK_RAW, IPPROTO_RAW)
    defer: socket.close()

    var send_buf = frame.to_buf()

    # TODO: send eth frames
    

proc send_packet*(packet: IPv4_Packet) =
    let socket = newsocket(AF_INET, SOCK_RAW, IPPROTO_RAW)
    defer: socket.close()

    var send_buf = packet.to_buf()
    
    socket.sendto(
        "0.0.0.0", # doesnt matter, overwritten by packet
        Port(1),   # doesnt matter, overwritten by packet
        send_buf, 
        int(packet.get_length())
    )