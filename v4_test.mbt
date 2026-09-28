///|
test "v4 preserves RFC 9562 Appendix A UUIDv4 vector" {
  let entropy = b"\x91\x91\x08\xf7\x52\xd1\x43\x20\x9b\xac\xf8\x47\xdb\x41\x48\xa8"

  match @moonuuid.v4_from_entropy(entropy) {
    Err(_) => fail("16 bytes of entropy must generate UUIDv4")
    Ok(uuid) => {
      assert_eq(
        @moonuuid.to_string(uuid),
        "919108f7-52d1-4320-9bac-f847db4148a8",
      )
      assert_true(@moonuuid.version(uuid) == Some(4))
      assert_true(@moonuuid.variant(uuid) == Rfc9562)
    }
  }
}

///|
test "v4 forces version and RFC variant bits" {
  match
    @moonuuid.v4_from_entropy(
      b"\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff",
    ) {
    Err(_) => fail("16 bytes of entropy must generate UUIDv4")
    Ok(uuid) =>
      assert_eq(
        @moonuuid.to_string(uuid),
        "ffffffff-ffff-4fff-bfff-ffffffffffff",
      )
  }

  match
    @moonuuid.v4_from_entropy(
      b"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
    ) {
    Err(_) => fail("16 bytes of entropy must generate UUIDv4")
    Ok(uuid) =>
      assert_eq(
        @moonuuid.to_string(uuid),
        "00000000-0000-4000-8000-000000000000",
      )
  }
}

///|
test "v4 injected provider is requested for exactly 16 bytes" {
  let provider = fn(length : Int) -> Bytes? {
    if length == 16 {
      Some(b"\x91\x91\x08\xf7\x52\xd1\x43\x20\x9b\xac\xf8\x47\xdb\x41\x48\xa8")
    } else {
      None
    }
  }

  match @moonuuid.v4_with_entropy(provider) {
    Err(_) => fail("provider should receive a 16-byte request")
    Ok(uuid) =>
      assert_eq(
        @moonuuid.to_string(uuid),
        "919108f7-52d1-4320-9bac-f847db4148a8",
      )
  }
}

///|
test "v4 reports unavailable and malformed entropy" {
  match @moonuuid.v4_with_entropy(fn(_length : Int) -> Bytes? { None }) {
    Err(EntropyUnavailable) => ()
    _ => fail("missing entropy must be reported")
  }

  match
    @moonuuid.v4_with_entropy(fn(_length : Int) -> Bytes? {
      Some(b"123456789012345")
    }) {
    Err(InvalidEntropyLength(15)) => ()
    _ => fail("wrong entropy length must be reported")
  }
}

///|
test "default v4 never falls back to non-secure randomness" {
  match @moonuuid.v4() {
    Ok(uuid) => {
      assert_true(@moonuuid.version(uuid) == Some(4))
      assert_true(@moonuuid.variant(uuid) == Rfc9562)
      assert_eq(@moonuuid.to_bytes(uuid).length(), 16)
    }
    Err(EntropyUnavailable) => ()
    Err(InvalidEntropyLength(_)) =>
      fail("platform entropy adapter must return exactly 16 bytes")
  }
}
