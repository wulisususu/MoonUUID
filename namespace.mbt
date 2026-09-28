///|
/// RFC 9562 / RFC 4122 DNS namespace UUID.
pub fn namespace_dns() -> Uuid {
  { high: 0x6BA7B8109DAD11D1UL, low: 0x80B400C04FD430C8UL }
}

///|
/// RFC 9562 / RFC 4122 URL namespace UUID.
pub fn namespace_url() -> Uuid {
  { high: 0x6BA7B8119DAD11D1UL, low: 0x80B400C04FD430C8UL }
}

///|
/// RFC 9562 / RFC 4122 OID namespace UUID.
pub fn namespace_oid() -> Uuid {
  { high: 0x6BA7B8129DAD11D1UL, low: 0x80B400C04FD430C8UL }
}

///|
/// RFC 9562 / RFC 4122 X.500 DN namespace UUID.
pub fn namespace_x500() -> Uuid {
  { high: 0x6BA7B8149DAD11D1UL, low: 0x80B400C04FD430C8UL }
}
