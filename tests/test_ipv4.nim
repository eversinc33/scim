import unittest

import std/nativesockets
import strutils
import scim/protocols/[ipv4]

test "ipv4 checksum":
  var ippkt = h_IP(IP_LOOPBACK_ADDR, IP_LOOPBACK_ADDR, protocol=IP_PROTOCOL_UDP)
  check ippkt.header.checksum == htons(uint16(0x54EE))

test "ipv4 to_buf()":
  var ippkt = h_IP(IP_LOOPBACK_ADDR, IP_LOOPBACK_ADDR, protocol=IP_PROTOCOL_UDP)
  let send_buf = ippkt.to_buf()
  
  for b in 0..<ippkt.get_length():
    let byte_val = cast[ptr byte](cast[int](send_buf) + int(b))[]
    case b
    of 0: assert byte_val == 0x45 # version / header len
    of 1: assert byte_val == 0x10
    of 2: assert byte_val == 0x00 # total_len
    of 3: assert byte_val == 0x14
    of 4: assert byte_val == 0x27 # id
    of 5: assert byte_val == 0xD9
    of 6: assert byte_val == 0x00 # fragment offset
    of 7: assert byte_val == 0x00
    of 8: assert byte_val == 0x40 # ttl (64)
    of 9: assert byte_val == 0x11 # protocol (upd = 17)
    of 10: assert byte_val == 0x54 # checksum
    of 11: assert byte_val == 0xEE 
    of 12: assert byte_val == 0x7F # src_addr
    of 13: assert byte_val == 0x00
    of 14: assert byte_val == 0x00
    of 15: assert byte_val == 0x01
    of 16: assert byte_val == 0x7F # dest_addr
    of 17: assert byte_val == 0x00
    of 18: assert byte_val == 0x00
    of 19: assert byte_val == 0x01
    else: fail
