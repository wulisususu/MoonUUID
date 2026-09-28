///|
test "RFC 9562 UUIDv3 DNS test vector" {
  let uuid = @moonuuid.v3_string(@moonuuid.namespace_dns(), "www.example.com")
  assert_eq(@moonuuid.to_string(uuid), "5df41881-3aed-3515-88a7-2f4a814cf09e")
  assert_true(@moonuuid.version(uuid) == Some(3))
  assert_true(@moonuuid.variant(uuid) == Rfc9562)
}

///|
test "RFC 9562 UUIDv5 DNS test vector" {
  let uuid = @moonuuid.v5_string(@moonuuid.namespace_dns(), "www.example.com")
  assert_eq(@moonuuid.to_string(uuid), "2ed6657d-e927-568b-95e1-2665a8aea6a2")
  assert_true(@moonuuid.version(uuid) == Some(5))
  assert_true(@moonuuid.variant(uuid) == Rfc9562)
}

///|
test "RFC 9562 Appendix B.2 SHA-256 UUIDv8 vector" {
  let uuid = @moonuuid.v8_sha256_string(
    @moonuuid.namespace_dns(),
    "www.example.com",
  )
  assert_eq(@moonuuid.to_string(uuid), "5c146b14-3c52-8afd-938a-375d0df1fbf6")
  assert_true(@moonuuid.version(uuid) == Some(8))
  assert_true(@moonuuid.variant(uuid) == Rfc9562)
}

///|
test "name-based UUIDs are deterministic and namespace-sensitive" {
  let a = @moonuuid.v5_string(@moonuuid.namespace_dns(), "example")
  let b = @moonuuid.v5_string(@moonuuid.namespace_dns(), "example")
  let c = @moonuuid.v5_string(@moonuuid.namespace_url(), "example")

  assert_true(a == b)
  assert_true(a != c)
}
