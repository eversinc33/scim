import protocols/[ipv4, udp, tcp, ethernet]
import ./scim

let udp_payload = [byte 0xDE, 0xAD, 0x00, 0xAF, 0x00]

when isMainModule:
    send_packet(h_ETH(ETH_LOCALHOST, ETH_LOCALHOST))
    #send_packet(h_IP(IP_LOOPBACK_ADDR, IP_LOOPBACK_ADDR) + (h_UDP(333, 666) + udp_payload))
    #let flags = uint8(TCP_FLAG_SYN) or uint8(TCP_FLAG_ACK)
    #send_packet(h_IP(IP_LOOPBACK_ADDR, IP_LOOPBACK_ADDR) + h_TCP(333, 666, flags=flags)) # + udp_payload))