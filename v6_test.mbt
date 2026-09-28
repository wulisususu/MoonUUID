///|
test "RFC 9562 Appendix A UUIDv6 vector" {
  match @moonuuid.v6_from_parts(
    0x1EC9414C232AB00UL,
    0x33C8UL,
    0x9F6BDECED846UL,
  ) {
    Err(_) => fail("RFC UUIDv6 vector must construct")
    Ok(uuid) => {
      assert_eq(
        @moonuuid.to_string(uuid),
        "1ec9414c-232a-6b00-b3c8-9f6bdeced846",
      )
      assert_true(@moonuuid.version(uuid) == Some(6))
      assert_true(@moonuuid.variant(uuid) == Rfc9562)
      assert_true(
        @moonuuid.gregorian_ts_100ns(uuid) ==
        Some(0x1EC9414C232AB00UL),
      )
      assert_true(@moonuuid.v6_clock_seq(uuid) == Some(0x33C8UL))
      assert_true(@moonuuid.v6_node(uuid) == Some(0x9F6BDECED846UL))
    }
  }
}

///|
test "v6 validates field widths" {
  match @moonuuid.v6_from_parts(0x1000000000000000UL, 0UL, 0UL) {
    Err(TimestampOutOfRange(_)) => ()
    _ => fail("v6 timestamp must fit 60 bits")
  }

  match @moonuuid.v6_from_parts(0UL, 0x4000UL, 0UL) {
    Err(ClockSeqOutOfRange(_)) => ()
    _ => fail("v6 clock sequence must fit 14 bits")
  }

  match @moonuuid.v6_from_parts(0UL, 0UL, 0x1000000000000UL) {
    Err(NodeOutOfRange(_)) => ()
    _ => fail("v6 node must fit 48 bits")
  }
}
