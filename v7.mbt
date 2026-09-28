///|
/// Errors that can occur while constructing or generating UUIDv7 values.
pub(all) enum V7Error {
  EntropyUnavailable
  InvalidEntropyLength(Int)
  TimestampOutOfRange(UInt64)
  RandAOutOfRange(UInt64)
  RandBOutOfRange(UInt64)
  MonotonicOverflow
} derive(Eq)

///|
pub extend V7Error with Eq::{not_equal, equal}

///|
/// Stateful UUIDv7 generator for strict monotonic ordering on one node/process.
///
/// For a new millisecond, fresh random fields are generated. For the same
/// millisecond, or when the supplied clock moves backwards, the previous
/// timestamp is reused and the 74-bit random payload is incremented.
pub struct V7Generator {
  mut initialized : Bool
  mut last_ms : UInt64
  mut rand_a : UInt64
  mut rand_b : UInt64
}

///|
/// Construct an empty monotonic UUIDv7 generator.
pub fn V7Generator::new() -> V7Generator {
  { initialized: false, last_ms: 0UL, rand_a: 0UL, rand_b: 0UL, }
}

///|
/// Return the 48-bit Unix-millisecond timestamp embedded in a UUIDv7.
///
/// Returns None for UUIDs that are not RFC-variant version 7 values.
pub fn unix_ts_ms(uuid : Uuid) -> UInt64? {
  if version(uuid) == Some(7) {
    Some((uuid.high >> 16) & 0x0000FFFFFFFFFFFFUL)
  } else {
    None
  }
}

///|
/// Construct UUIDv7 from its RFC 9562 fields.
///
/// `unix_ms` must fit in 48 bits, `rand_a` in 12 bits and `rand_b` in 62 bits.
pub fn v7_from_parts(
  unix_ms : UInt64,
  rand_a : UInt64,
  rand_b : UInt64,
) -> Result[Uuid, V7Error] {
  if unix_ms > 0x0000FFFFFFFFFFFFUL {
    return Err(TimestampOutOfRange(unix_ms))
  }
  if rand_a > 0xFFFUL {
    return Err(RandAOutOfRange(rand_a))
  }
  if rand_b > 0x3FFFFFFFFFFFFFFFUL {
    return Err(RandBOutOfRange(rand_b))
  }

  let high = (unix_ms << 16) | 0x7000UL | rand_a
  let low = 0x8000000000000000UL | rand_b
  Ok({ high, low, })
}

///|
fn v7_entropy_fields(entropy : Bytes) -> Result[(UInt64, UInt64), V7Error] {
  if entropy.length() != 10 {
    return Err(InvalidEntropyLength(entropy.length()))
  }

  let rand_a = (
      (entropy[0].to_int().to_uint64() << 8) | entropy[1].to_int().to_uint64()
    ) &
    0xFFFUL

  let mut rand_b = 0UL
  for i = 2; i < 10; i = i + 1 {
    rand_b = (rand_b << 8) | entropy[i].to_int().to_uint64()
  }
  rand_b = rand_b & 0x3FFFFFFFFFFFFFFFUL

  Ok((rand_a, rand_b))
}

///|
/// Construct UUIDv7 from a Unix-millisecond timestamp and 10 entropy bytes.
///
/// The first 12 usable bits seed `rand_a`; the following 62 usable bits seed
/// `rand_b`. Excess high bits are masked away to preserve the RFC layout.
pub fn v7_from_entropy(
  unix_ms : UInt64,
  entropy : Bytes,
) -> Result[Uuid, V7Error] {
  match v7_entropy_fields(entropy) {
    Err(error) => Err(error)
    Ok((rand_a, rand_b)) => v7_from_parts(unix_ms, rand_a, rand_b)
  }
}

///|
/// Generate UUIDv7 using injected clock and entropy providers.
///
/// The clock returns Unix time in milliseconds. The entropy provider is asked
/// for exactly 10 bytes.
pub fn v7_with(
  clock : () -> UInt64,
  entropy : (Int) -> Bytes?,
) -> Result[Uuid, V7Error] {
  let unix_ms = clock()
  match entropy(10) {
    None => Err(EntropyUnavailable)
    Some(bytes) => v7_from_entropy(unix_ms, bytes)
  }
}

///|
/// Generate UUIDv7 using MoonBit's wall clock and secure platform entropy.
///
/// Returns EntropyUnavailable when the runtime cannot supply secure randomness.
pub fn v7() -> Result[Uuid, V7Error] {
  v7_with(@env.now, @env.rand)
}

///|
fn V7Generator::seed(
  self : V7Generator,
  unix_ms : UInt64,
  entropy : (Int) -> Bytes?,
) -> Result[Uuid, V7Error] {
  if unix_ms > 0x0000FFFFFFFFFFFFUL {
    return Err(TimestampOutOfRange(unix_ms))
  }

  match entropy(10) {
    None => Err(EntropyUnavailable)
    Some(bytes) =>
      match v7_entropy_fields(bytes) {
        Err(error) => Err(error)
        Ok((rand_a, rand_b)) => {
          self.initialized = true
          self.last_ms = unix_ms
          self.rand_a = rand_a
          self.rand_b = rand_b
          v7_from_parts(self.last_ms, self.rand_a, self.rand_b)
        }
      }
  }
}

///|
/// Generate the next strictly monotonic UUIDv7 with injected providers.
///
/// RFC 9562 section 6.2 guidance is followed:
/// - a newer millisecond reseeds the random fields;
/// - the same millisecond increments the prior random payload;
/// - clock rollback reuses the previous timestamp and increments the payload;
/// - full 74-bit payload rollover returns MonotonicOverflow.
pub fn V7Generator::next_with(
  self : V7Generator,
  clock : () -> UInt64,
  entropy : (Int) -> Bytes?,
) -> Result[Uuid, V7Error] {
  let now = clock()

  if !self.initialized || now > self.last_ms {
    return self.seed(now, entropy)
  }

  if self.rand_b < 0x3FFFFFFFFFFFFFFFUL {
    self.rand_b = self.rand_b + 1UL
  } else if self.rand_a < 0xFFFUL {
    self.rand_a = self.rand_a + 1UL
    self.rand_b = 0UL
  } else {
    return Err(MonotonicOverflow)
  }

  v7_from_parts(self.last_ms, self.rand_a, self.rand_b)
}

///|
/// Generate the next strictly monotonic UUIDv7 using MoonBit platform providers.
pub fn V7Generator::next(self : V7Generator) -> Result[Uuid, V7Error] {
  self.next_with(@env.now, @env.rand)
}
