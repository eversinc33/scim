# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import std/nativesockets
import strutils
import scim/protocols/[ipv4]

test "ipv4 checksum":
  var ippkt = h_IP(IP_LOOPBACK_ADDR, IP_LOOPBACK_ADDR, protocol=IP_PROTOCOL_UDP)
  check ippkt.header.checksum == htons(uint16(0x54EE))

test "ipv4 to_buf()":
  let send_buf = h_IP(IP_LOOPBACK_ADDR, IP_LOOPBACK_ADDR, protocol=IP_PROTOCOL_UDP).to_buf()
  
  for b in uint16(0)..<20:
    let byte_val = cast[ptr byte](cast[int](send_buf) + int(b))[]
    case b
    of 0: assert byte_val == 0x45 # version / header len
    of 1: assert byte_val == 0x10
    of 2: assert byte_val == 0x00 # total_len
    of 3: assert byte_val == 0x14
    of 4: assert byte_val == 0x27
    of 5: assert byte_val == 0xD9
    of 6: assert byte_val == 0x00
    of 7: assert byte_val == 0x00
    of 8: assert byte_val == 0x40
    of 9: assert byte_val == 0x11
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
    else: assert byte_val == 0x00
