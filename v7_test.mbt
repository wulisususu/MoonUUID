///|
test "RFC 9562 Appendix A UUIDv7 field vector" {
  match
    @moonuuid.v7_from_parts(0x017F22E279B0UL, 0xCC3UL, 0x18C4DC0C0C07398FUL) {
    Err(_) => fail("RFC UUIDv7 vector fields must construct")
    Ok(uuid) => {
      assert_eq(
        @moonuuid.to_string(uuid),
        "017f22e2-79b0-7cc3-98c4-dc0c0c07398f",
      )
      assert_true(@moonuuid.version(uuid) == Some(7))
      assert_true(@moonuuid.variant(uuid) == Rfc9562)
      assert_true(@moonuuid.unix_ts_ms(uuid) == Some(1645557742000UL))
    }
  }
}

///|
test "v7 entropy mapping reproduces RFC vector" {
  let entropy = b"\x0c\xc3\x18\xc4\xdc\x0c\x0c\x07\x39\x8f"

  match @moonuuid.v7_from_entropy(1645557742000UL, entropy) {
    Err(_) => fail("valid v7 entropy must construct")
    Ok(uuid) =>
      assert_eq(
        @moonuuid.to_string(uuid),
        "017f22e2-79b0-7cc3-98c4-dc0c0c07398f",
      )
  }
}

///|
test "v7 validates field widths" {
  match @moonuuid.v7_from_parts(0x1000000000000UL, 0UL, 0UL) {
    Err(TimestampOutOfRange(_)) => ()
    _ => fail("timestamp wider than 48 bits must fail")
  }
  match @moonuuid.v7_from_parts(0UL, 0x1000UL, 0UL) {
    Err(RandAOutOfRange(_)) => ()
    _ => fail("rand_a wider than 12 bits must fail")
  }
  match @moonuuid.v7_from_parts(0UL, 0UL, 0x4000000000000000UL) {
    Err(RandBOutOfRange(_)) => ()
    _ => fail("rand_b wider than 62 bits must fail")
  }
  match @moonuuid.v7_from_entropy(0UL, b"123456789") {
    Err(InvalidEntropyLength(9)) => ()
    _ => fail("v7 requires exactly 10 entropy bytes")
  }
}

///|
test "v7 injected providers request ten entropy bytes" {
  let clock = fn() -> UInt64 { 1645557742000UL }
  let entropy = fn(length : Int) -> Bytes? {
    if length == 10 {
      Some(b"\x0c\xc3\x18\xc4\xdc\x0c\x0c\x07\x39\x8f")
    } else {
      None
    }
  }

  match @moonuuid.v7_with(clock, entropy) {
    Err(_) => fail("providers must produce UUIDv7")
    Ok(uuid) =>
      assert_eq(
        @moonuuid.to_string(uuid),
        "017f22e2-79b0-7cc3-98c4-dc0c0c07398f",
      )
  }
}

///|
test "monotonic generator increases within one millisecond" {
  let generator = @moonuuid.V7Generator::new()
  let clock = fn() -> UInt64 { 1645557742000UL }
  let entropy = fn(_length : Int) -> Bytes? {
    Some(b"\x00\x01\x00\x00\x00\x00\x00\x00\x00\x01")
  }

  let first = generator.next_with(clock, entropy)
  let second = generator.next_with(clock, entropy)
  let third = generator.next_with(clock, entropy)

  match (first, second, third) {
    (Ok(a), Ok(b), Ok(c)) => {
      assert_true(a < b)
      assert_true(b < c)
      assert_true(@moonuuid.unix_ts_ms(a) == Some(1645557742000UL))
      assert_true(@moonuuid.unix_ts_ms(c) == Some(1645557742000UL))
    }
    _ => fail("same-millisecond monotonic generation must succeed")
  }
}

///|
test "monotonic generator absorbs clock rollback" {
  let generator = @moonuuid.V7Generator::new()
  let mut current = 2000UL
  let clock = fn() -> UInt64 { current }
  let entropy = fn(_length : Int) -> Bytes? {
    Some(b"\x00\x02\x00\x00\x00\x00\x00\x00\x00\x10")
  }

  let first = generator.next_with(clock, entropy)
  current = 1999UL
  let second = generator.next_with(clock, entropy)

  match (first, second) {
    (Ok(a), Ok(b)) => {
      assert_true(a < b)
      assert_true(@moonuuid.unix_ts_ms(a) == Some(2000UL))
      assert_true(@moonuuid.unix_ts_ms(b) == Some(2000UL))
    }
    _ => fail("clock rollback must preserve monotonic order")
  }
}

///|
test "monotonic generator reseeds after timestamp advances" {
  let generator = @moonuuid.V7Generator::new()
  let mut current = 3000UL
  let clock = fn() -> UInt64 { current }
  let entropy = fn(_length : Int) -> Bytes? {
    Some(b"\x0a\xbc\x01\x02\x03\x04\x05\x06\x07\x08")
  }

  let first = generator.next_with(clock, entropy)
  current = 3001UL
  let second = generator.next_with(clock, entropy)

  match (first, second) {
    (Ok(a), Ok(b)) => {
      assert_true(a < b)
      assert_true(@moonuuid.unix_ts_ms(b) == Some(3001UL))
    }
    _ => fail("new millisecond must reseed and advance")
  }
}

///|
test "monotonic generator carries rand_b into rand_a" {
  let generator = @moonuuid.V7Generator::new()
  let clock = fn() -> UInt64 { 4000UL }
  let entropy = fn(_length : Int) -> Bytes? {
    Some(b"\x00\x01\xff\xff\xff\xff\xff\xff\xff\xff")
  }

  let first = generator.next_with(clock, entropy)
  let second = generator.next_with(clock, entropy)

  match (first, second) {
    (Ok(a), Ok(b)) => {
      assert_true(a < b)
      assert_eq(@moonuuid.to_string(a), "00000000-0fa0-7001-bfff-ffffffffffff")
      assert_eq(@moonuuid.to_string(b), "00000000-0fa0-7002-8000-000000000000")
    }
    _ => fail("rand_b overflow should carry into rand_a")
  }
}

///|
test "default v7 reports unsupported secure entropy without weak fallback" {
  match @moonuuid.v7() {
    Ok(uuid) => {
      assert_true(@moonuuid.version(uuid) == Some(7))
      assert_true(@moonuuid.variant(uuid) == Rfc9562)
      assert_true(@moonuuid.unix_ts_ms(uuid) != None)
    }
    Err(EntropyUnavailable) => ()
    Err(_) => fail("platform v7 should only fail for unavailable entropy")
  }
}
