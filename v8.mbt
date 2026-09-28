///|
/// Errors returned while constructing UUIDv8 values.
pub(all) enum V8Error {
  CustomAOutOfRange(UInt64)
  CustomBOutOfRange(UInt64)
  CustomCOutOfRange(UInt64)
} derive(Eq)

///|
pub extend V8Error with Eq::{not_equal, equal}

///|
/// Construct an RFC 9562 UUIDv8 from application-defined fields.
///
/// UUIDv8 reserves 48 bits as `custom_a`, 12 bits as `custom_b`, and
/// 62 bits as `custom_c`; MoonUUID inserts the required version and variant.
pub fn v8_from_parts(
  custom_a : UInt64,
  custom_b : UInt64,
  custom_c : UInt64,
) -> Result[Uuid, V8Error] {
  if custom_a > 0x0000FFFFFFFFFFFFUL {
    return Err(CustomAOutOfRange(custom_a))
  }
  if custom_b > 0xFFFUL {
    return Err(CustomBOutOfRange(custom_b))
  }
  if custom_c > 0x3FFFFFFFFFFFFFFFUL {
    return Err(CustomCOutOfRange(custom_c))
  }

  let high = (custom_a << 16) | 0x8000UL | custom_b
  let low = 0x8000000000000000UL | custom_c
  Ok({ high, low, })
}

///|
/// Extract UUIDv8 custom_a (48 bits), or None for non-v8 UUIDs.
pub fn v8_custom_a(uuid : Uuid) -> UInt64? {
  if version(uuid) == Some(8) {
    Some((uuid.high >> 16) & 0x0000FFFFFFFFFFFFUL)
  } else {
    None
  }
}

///|
/// Extract UUIDv8 custom_b (12 bits), or None for non-v8 UUIDs.
pub fn v8_custom_b(uuid : Uuid) -> UInt64? {
  if version(uuid) == Some(8) {
    Some(uuid.high & 0xFFFUL)
  } else {
    None
  }
}

///|
/// Extract UUIDv8 custom_c (62 bits), or None for non-v8 UUIDs.
pub fn v8_custom_c(uuid : Uuid) -> UInt64? {
  if version(uuid) == Some(8) {
    Some(uuid.low & 0x3FFFFFFFFFFFFFFFUL)
  } else {
    None
  }
}
