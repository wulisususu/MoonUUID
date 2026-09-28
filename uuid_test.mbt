///|
test "RFC 9562 UUIDv4 test vector parses and formats" {
  match @moonuuid.parse("919108F7-52D1-4320-9BAC-F847DB4148A8") {
    Err(_) => fail("RFC UUIDv4 vector must parse")
    Ok(uuid) => {
      assert_eq(
        @moonuuid.to_string(uuid),
        "919108f7-52d1-4320-9bac-f847db4148a8",
      )
      assert_true(@moonuuid.variant(uuid) == Rfc9562)
      assert_true(@moonuuid.version(uuid) == Some(4))
    }
  }
}

///|
test "RFC 9562 UUIDv7 test vector parses and formats" {
  match @moonuuid.parse("017F22E2-79B0-7CC3-98C4-DC0C0C07398F") {
    Err(_) => fail("RFC UUIDv7 vector must parse")
    Ok(uuid) => {
      assert_eq(
        @moonuuid.to_string(uuid),
        "017f22e2-79b0-7cc3-98c4-dc0c0c07398f",
      )
      assert_true(@moonuuid.variant(uuid) == Rfc9562)
      assert_true(@moonuuid.version(uuid) == Some(7))
    }
  }
}

///|
test "Nil and Max UUIDs follow RFC 9562 sentinel definitions" {
  let zero = @moonuuid.nil()
  assert_true(@moonuuid.is_nil(zero))
  assert_false(@moonuuid.is_max(zero))
  assert_eq(@moonuuid.to_string(zero), "00000000-0000-0000-0000-000000000000")
  assert_true(@moonuuid.variant(zero) == Ncs)
  assert_true(@moonuuid.version(zero) == None)

  let all_ones = @moonuuid.max()
  assert_true(@moonuuid.is_max(all_ones))
  assert_false(@moonuuid.is_nil(all_ones))
  assert_eq(
    @moonuuid.to_string(all_ones),
    "ffffffff-ffff-ffff-ffff-ffffffffffff",
  )
  assert_true(@moonuuid.variant(all_ones) == Future)
  assert_true(@moonuuid.version(all_ones) == None)
}

///|
test "strict parse rejects non-canonical input" {
  assert_false(@moonuuid.is_valid("not-a-uuid"))
  assert_false(@moonuuid.is_valid("919108f752d143209bacf847db4148a8"))
  assert_false(@moonuuid.is_valid("{919108f7-52d1-4320-9bac-f847db4148a8}"))
  assert_false(
    @moonuuid.is_valid("urn:uuid:919108f7-52d1-4320-9bac-f847db4148a8"),
  )
  assert_false(@moonuuid.is_valid("919108f7-52d1-4320-9bac-f847db4148az"))
}

///|
test "permissive parse accepts canonical compact URN and braced forms" {
  let expected = "919108f7-52d1-4320-9bac-f847db4148a8"
  let inputs = [
    "919108F7-52D1-4320-9BAC-F847DB4148A8",
    "919108F752D143209BACF847DB4148A8",
    "urn:uuid:919108F7-52D1-4320-9BAC-F847DB4148A8",
    "URN:UUID:919108F7-52D1-4320-9BAC-F847DB4148A8",
    "{919108F7-52D1-4320-9BAC-F847DB4148A8}",
  ]

  for input in inputs {
    match @moonuuid.parse_permissive(input) {
      Err(_) => fail("permissive UUID form must parse")
      Ok(uuid) => assert_eq(@moonuuid.to_string(uuid), expected)
    }
  }
}

///|
test "permissive parse rejects malformed wrappers" {
  assert_false(
    @moonuuid.is_valid_permissive("[919108f7-52d1-4320-9bac-f847db4148a8]"),
  )
  assert_false(
    @moonuuid.is_valid_permissive("xxx:uuid:919108f7-52d1-4320-9bac-f847db4148a8"),
  )
}

///|
test "text format helpers emit stable interoperable forms" {
  match @moonuuid.parse("919108f7-52d1-4320-9bac-f847db4148a8") {
    Err(_) => fail("UUID must parse")
    Ok(uuid) => {
      assert_eq(
        @moonuuid.to_urn(uuid),
        "urn:uuid:919108f7-52d1-4320-9bac-f847db4148a8",
      )
      assert_eq(
        @moonuuid.to_braced_string(uuid),
        "{919108f7-52d1-4320-9bac-f847db4148a8}",
      )
    }
  }
}

///|
test "UUID round trips through 16 network-order bytes" {
  let expected = b"\x91\x91\x08\xf7\x52\xd1\x43\x20\x9b\xac\xf8\x47\xdb\x41\x48\xa8"

  match @moonuuid.parse("919108f7-52d1-4320-9bac-f847db4148a8") {
    Err(_) => fail("UUID must parse")
    Ok(uuid) => {
      assert_eq(@moonuuid.to_bytes(uuid), expected)
      match @moonuuid.from_bytes(expected) {
        Err(_) => fail("16-byte UUID must decode")
        Ok(decoded) => assert_eq(decoded, uuid)
      }
    }
  }
}

///|
test "binary decoder requires exactly 16 bytes" {
  match @moonuuid.from_bytes(b"123456789012345") {
    Ok(_) => fail("15 bytes must be rejected")
    Err(_) => ()
  }
  match @moonuuid.from_bytes(b"12345678901234567") {
    Ok(_) => fail("17 bytes must be rejected")
    Err(_) => ()
  }
}

///|
test "u64 constructor round trips through canonical text" {
  let uuid = @moonuuid.from_u64s(0x919108F752D14320UL, 0x9BACF847DB4148A8UL)
  assert_eq(@moonuuid.high(uuid), 0x919108F752D14320UL)
  assert_eq(@moonuuid.low(uuid), 0x9BACF847DB4148A8UL)
  assert_eq(
    @moonuuid.to_string(uuid),
    "919108f7-52d1-4320-9bac-f847db4148a8",
  )
}
