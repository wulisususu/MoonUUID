///|
test "RFC 9562 UUIDv4 test vector parses and formats" {
  match parse("919108F7-52D1-4320-9BAC-F847DB4148A8") {
    Err(_) => fail("RFC UUIDv4 vector must parse")
    Ok(uuid) => {
      assert_eq(
        to_string(uuid),
        "919108f7-52d1-4320-9bac-f847db4148a8",
      )
      assert_true(variant(uuid) == Rfc9562)
      assert_true(version(uuid) == Some(4))
    }
  }
}

///|
test "RFC 9562 UUIDv7 test vector parses and formats" {
  match parse("017F22E2-79B0-7CC3-98C4-DC0C0C07398F") {
    Err(_) => fail("RFC UUIDv7 vector must parse")
    Ok(uuid) => {
      assert_eq(
        to_string(uuid),
        "017f22e2-79b0-7cc3-98c4-dc0c0c07398f",
      )
      assert_true(variant(uuid) == Rfc9562)
      assert_true(version(uuid) == Some(7))
    }
  }
}

///|
test "Nil and Max UUIDs follow RFC 9562 sentinel definitions" {
  let zero = nil()
  assert_true(is_nil(zero))
  assert_false(is_max(zero))
  assert_eq(to_string(zero), "00000000-0000-0000-0000-000000000000")
  assert_true(variant(zero) == Ncs)
  assert_true(version(zero) == None)

  let all_ones = max()
  assert_true(is_max(all_ones))
  assert_false(is_nil(all_ones))
  assert_eq(
    to_string(all_ones),
    "ffffffff-ffff-ffff-ffff-ffffffffffff",
  )
  assert_true(variant(all_ones) == Future)
  assert_true(version(all_ones) == None)
}

///|
test "parse rejects non-canonical input" {
  assert_false(is_valid("not-a-uuid"))
  assert_false(is_valid("919108f7-52d1-4320-9bacf847db4148a8"))
  assert_false(is_valid("919108f7-52d1-4320-9bac-f847db4148az"))
}

///|
test "u64 constructor round trips through canonical text" {
  let uuid = from_u64s(0x919108F752D14320UL, 0x9BACF847DB4148A8UL)
  assert_eq(high(uuid), 0x919108F752D14320UL)
  assert_eq(low(uuid), 0x9BACF847DB4148A8UL)
  assert_eq(
    to_string(uuid),
    "919108f7-52d1-4320-9bac-f847db4148a8",
  )
}
