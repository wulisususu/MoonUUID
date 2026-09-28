///|
test "RFC 9562 Appendix B UUIDv8 illustrative vector" {
  match
    @moonuuid.v8_from_parts(0x2489E9AD2EE2UL, 0xE00UL, 0x0EC932D5F69181C0UL) {
    Err(_) => fail("valid UUIDv8 custom fields must construct")
    Ok(uuid) => {
      assert_eq(
        @moonuuid.to_string(uuid),
        "2489e9ad-2ee2-8e00-8ec9-32d5f69181c0",
      )
      assert_true(@moonuuid.version(uuid) == Some(8))
      assert_true(@moonuuid.variant(uuid) == Rfc9562)
      assert_true(@moonuuid.v8_custom_a(uuid) == Some(0x2489E9AD2EE2UL))
      assert_true(@moonuuid.v8_custom_b(uuid) == Some(0xE00UL))
      assert_true(@moonuuid.v8_custom_c(uuid) == Some(0x0EC932D5F69181C0UL))
    }
  }
}

///|
test "v8 validates custom field widths" {
  match @moonuuid.v8_from_parts(0x1000000000000UL, 0UL, 0UL) {
    Err(CustomAOutOfRange(_)) => ()
    _ => fail("custom_a must fit 48 bits")
  }

  match @moonuuid.v8_from_parts(0UL, 0x1000UL, 0UL) {
    Err(CustomBOutOfRange(_)) => ()
    _ => fail("custom_b must fit 12 bits")
  }

  match @moonuuid.v8_from_parts(0UL, 0UL, 0x4000000000000000UL) {
    Err(CustomCOutOfRange(_)) => ()
    _ => fail("custom_c must fit 62 bits")
  }
}
