import protocols/[ipv4, udp]
import ./scim

let udp_payload = [byte 0xDE, 0xAD, 0x00, 0xAF, 0x00]

when isMainModule:
    send_packet(h_IP(IP_LOOPBACK_ADDR, IP_LOOPBACK_ADDR, protocol=IP_PROTOCOL_UDP) + (h_UDP(333, 666) + udp_payload))
