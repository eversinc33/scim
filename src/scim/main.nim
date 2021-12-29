import protocols/[ipv4, udp]
import ./scim

# todo: calc total len in ip packet
let udp_payload = [byte 0xDE, 0xAD, 0x00, 0xAF, 0x00]
let total_len: uint16 = sizeof(IPv4_Header) + sizeof(UDP_Header) + udp_payload.len()

when isMainModule:
    send_packet(total_len, h_IP(IP_LOOPBACK_ADDR, IP_LOOPBACK_ADDR, protocol=IP_PROTOCOL_UDP, total_length=total_len) + (h_UDP(333, 666) + udp_payload))