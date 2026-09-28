///|
/// Errors returned while constructing UUIDv6 values.
pub(all) enum V6Error {
  TimestampOutOfRange(UInt64)
  ClockSeqOutOfRange(UInt64)
  NodeOutOfRange(UInt64)
} derive(Eq)

///|
pub extend V6Error with Eq::{not_equal, equal}

///|
/// Construct an RFC 9562 UUIDv6 from UUIDv1-compatible fields.
///
/// `timestamp_100ns` is the 60-bit count of 100 ns intervals since
/// 1582-10-15 00:00:00 UTC. `clock_seq` is 14 bits and `node` is 48 bits.
pub fn v6_from_parts(
  timestamp_100ns : UInt64,
  clock_seq : UInt64,
  node : UInt64,
) -> Result[Uuid, V6Error] {
  if timestamp_100ns > 0x0FFFFFFFFFFFFFFFUL {
    return Err(TimestampOutOfRange(timestamp_100ns))
  }
  if clock_seq > 0x3FFFUL {
    return Err(ClockSeqOutOfRange(clock_seq))
  }
  if node > 0x0000FFFFFFFFFFFFUL {
    return Err(NodeOutOfRange(node))
  }

  let high = (timestamp_100ns >> 12 << 16) |
    0x6000UL |
    (timestamp_100ns & 0xFFFUL)
  let low = 0x8000000000000000UL | (clock_seq << 48) | node

  Ok({ high, low, })
}

///|
/// Extract the 60-bit Gregorian 100-ns timestamp from an RFC UUIDv6.
///
/// Returns None for non-v6 UUIDs.
pub fn gregorian_ts_100ns(uuid : Uuid) -> UInt64? {
  if version(uuid) == Some(6) {
    Some((uuid.high >> 16 << 12) | (uuid.high & 0xFFFUL))
  } else {
    None
  }
}

///|
/// Extract the 14-bit clock sequence from an RFC UUIDv6.
///
/// Returns None for non-v6 UUIDs.
pub fn v6_clock_seq(uuid : Uuid) -> UInt64? {
  if version(uuid) == Some(6) {
    Some((uuid.low >> 48) & 0x3FFFUL)
  } else {
    None
  }
}

///|
/// Extract the 48-bit node field from an RFC UUIDv6.
///
/// Returns None for non-v6 UUIDs.
pub fn v6_node(uuid : Uuid) -> UInt64? {
  if version(uuid) == Some(6) {
    Some(uuid.low & 0x0000FFFFFFFFFFFFUL)
  } else {
    None
  }
}
