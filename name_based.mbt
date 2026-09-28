///|
fn namespaced_name_bytes(ns : Uuid, name : Bytes) -> FixedArray[Byte] {
  let namespace_bytes = to_bytes(ns)
  let output = FixedArray::make(16 + name.length(), b'\x00')

  for i = 0; i < 16; i = i + 1 {
    output[i] = namespace_bytes[i]
  }
  for i = 0; i < name.length(); i = i + 1 {
    output[16 + i] = name[i]
  }

  output
}

///|
fn uuid_from_hash_prefix(digest : FixedArray[Byte], uuid_version : Int) -> Uuid {
  let mut high = 0UL
  let mut low = 0UL

  for i = 0; i < 8; i = i + 1 {
    high = (high << 8) | digest[i].to_int().to_uint64()
  }
  for i = 8; i < 16; i = i + 1 {
    low = (low << 8) | digest[i].to_int().to_uint64()
  }

  high = (high & 0xFFFFFFFFFFFF0FFFUL) | (uuid_version.to_uint64() << 12)
  low = (low & 0x3FFFFFFFFFFFFFFFUL) | 0x8000000000000000UL

  { high, low, }
}

///|
/// Generate an RFC 9562 UUIDv3 from a namespace UUID and arbitrary name bytes.
///
/// UUIDv3 uses MD5 for compatibility with the standardized name-based format.
/// This API does not treat MD5 as a general-purpose security primitive.
pub fn v3(ns : Uuid, name : Bytes) -> Uuid {
  let input = namespaced_name_bytes(ns, name)
  uuid_from_hash_prefix(@crypto.md5(input), 3)
}

///|
/// Generate UUIDv3 from a UTF-8 encoded string name.
///
/// Name canonicalization is namespace/application specific and remains the
/// caller's responsibility.
pub fn v3_string(ns : Uuid, name : String) -> Uuid {
  v3(ns, @utf8.encode(name))
}

///|
/// Generate an RFC 9562 UUIDv5 from a namespace UUID and arbitrary name bytes.
///
/// UUIDv5 uses SHA-1 because that algorithm is part of the standardized UUIDv5
/// format. This API should not be interpreted as recommending SHA-1 for new
/// cryptographic designs.
pub fn v5(ns : Uuid, name : Bytes) -> Uuid {
  let input = namespaced_name_bytes(ns, name)
  uuid_from_hash_prefix(@crypto.sha1(input), 5)
}

///|
/// Generate UUIDv5 from a UTF-8 encoded string name.
///
/// Name canonicalization is namespace/application specific and remains the
/// caller's responsibility.
pub fn v5_string(ns : Uuid, name : String) -> Uuid {
  v5(ns, @utf8.encode(name))
}

///|
/// Generate the RFC 9562 Appendix B.2 SHA-256 name-based UUIDv8 profile.
///
/// RFC 9562 defines UUIDv8 as application-specific. This helper follows the
/// document's illustrative SHA-256 construction: hash namespace bytes followed
/// by name bytes, take the first 128 hash bits, then overwrite version/variant.
pub fn v8_sha256(ns : Uuid, name : Bytes) -> Uuid {
  let input = namespaced_name_bytes(ns, name)
  uuid_from_hash_prefix(@crypto.sha256(input), 8)
}

///|
/// UTF-8 string convenience wrapper for the illustrative SHA-256 UUIDv8 profile.
pub fn v8_sha256_string(ns : Uuid, name : String) -> Uuid {
  v8_sha256(ns, @utf8.encode(name))
}
