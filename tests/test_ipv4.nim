# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import std/nativesockets
import strutils
import protocols/[ipv4]

test "ipv4 checksum calculated correctly":
  var iphdr = h_IP(IP_LOOPBACK_ADDR, IP_LOOPBACK_ADDR, protocol = IP_PROTOCOL_UDP)
  iphdr.total_length = htons(32)
  iphdr.checksum = calc_ipv4_checksum(iphdr)
  echo "[*] ipv4_checksum: " & iphdr.checksum.toHex
  check iphdr.checksum == uint16(0x54e2)
