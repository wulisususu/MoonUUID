///|
test "deterministic corpus round trips through text and bytes" {
  for i = 0; i < 512; i = i + 1 {
    let n = i.to_uint64()
    let r = (511 - i).to_uint64()
    let high = (n << 48) | (r << 32) | (n << 16) | r
    let low = (r << 48) | (n << 32) | (r << 16) | n
    let original = @moonuuid.from_u64s(high, low)

    let canonical = @moonuuid.to_string(original)
    match @moonuuid.parse(canonical) {
      Err(_) => fail("canonical output must parse")
      Ok(decoded) => assert_true(decoded == original)
    }

    let bytes = @moonuuid.to_bytes(original)
    match @moonuuid.from_bytes(bytes) {
      Err(_) => fail("encoded UUID bytes must decode")
      Ok(decoded) => assert_true(decoded == original)
    }
  }
}

///|
test "permissive wrappers round trip over deterministic corpus" {
  for i = 0; i < 128; i = i + 1 {
    let n = i.to_uint64()
    let original = @moonuuid.from_u64s(
      (n << 40) | (n << 20) | n,
      (n << 44) | (n << 22) | n,
    )

    let urn = @moonuuid.to_urn(original)
    match @moonuuid.parse_permissive(urn) {
      Err(_) => fail("generated UUID URN must parse")
      Ok(decoded) => assert_true(decoded == original)
    }

    let braced = @moonuuid.to_braced_string(original)
    match @moonuuid.parse_permissive(braced) {
      Err(_) => fail("generated braced UUID must parse")
      Ok(decoded) => assert_true(decoded == original)
    }
  }
}

///|
test "monotonic v7 stays strictly ordered across 1024 same-ms generations" {
  let generator = @moonuuid.V7Generator::new()
  let clock = fn() -> UInt64 { 123456789UL }
  let entropy = fn(_length : Int) -> Bytes? {
    Some(b"\x01\x23\x04\x56\x78\x9a\xbc\xde\xf0\x01")
  }

  let first = match generator.next_with(clock, entropy) {
    Err(_) => abort("initial monotonic UUIDv7 generation must succeed")
    Ok(id) => id
  }

  let mut previous = first
  for _i = 0; _i < 1024; _i = _i + 1 {
    match generator.next_with(clock, entropy) {
      Err(_) => fail("same-ms monotonic generation must not fail")
      Ok(current) => {
        assert_true(previous < current)
        assert_true(@moonuuid.unix_ts_ms(current) == Some(123456789UL))
        previous = current
      }
    }
  }
}

///|
test "v7 timestamp extraction is stable over deterministic field corpus" {
  for i = 0; i < 512; i = i + 1 {
    let n = i.to_uint64()
    let timestamp = 1000000UL + n
    let rand_a = n & 0xFFFUL
    let rand_b = (n << 20) | n

    match @moonuuid.v7_from_parts(timestamp, rand_a, rand_b) {
      Err(_) => fail("bounded deterministic v7 fields must construct")
      Ok(id) => {
        assert_true(@moonuuid.version(id) == Some(7))
        assert_true(@moonuuid.variant(id) == Rfc9562)
        assert_true(@moonuuid.unix_ts_ms(id) == Some(timestamp))
      }
    }
  }
}
