///|
/// Errors that can occur while generating a UUID.
pub(all) enum GenerateError {
  EntropyUnavailable
  InvalidEntropyLength(Int)
} derive(Eq)

pub extend GenerateError with Eq::{not_equal, equal}

///|
/// Apply the RFC 9562 UUIDv4 version and variant bits to exactly 16 entropy bytes.
///
/// This function is deterministic and does not obtain randomness itself. It is
/// useful for tests, protocol adapters, and runtimes that already own a secure
/// entropy source.
pub fn v4_from_entropy(entropy : Bytes) -> Result[Uuid, GenerateError] {
  if entropy.length() != 16 {
    return Err(InvalidEntropyLength(entropy.length()))
  }

  let mut high = 0UL
  let mut low = 0UL

  for i = 0; i < 8; i = i + 1 {
    high = (high << 8) | entropy[i].to_int().to_uint64()
  }
  for i = 8; i < 16; i = i + 1 {
    low = (low << 8) | entropy[i].to_int().to_uint64()
  }

  // RFC 9562 UUIDv4:
  // - version field (bits 48..51 / octet 6 high nibble) = 0100
  // - variant field (octet 8 high bits) = 10
  high = (high & 0xFFFFFFFFFFFF0FFFUL) | 0x0000000000004000UL
  low = (low & 0x3FFFFFFFFFFFFFFFUL) | 0x8000000000000000UL

  Ok({ high, low })
}

///|
/// Generate a UUIDv4 using an injected entropy provider.
///
/// The provider is asked for exactly 16 secure random bytes. Returning `None`
/// reports `EntropyUnavailable`; returning a byte string of another length
/// reports `InvalidEntropyLength`.
pub fn v4_with_entropy(
  provider : (Int) -> Bytes?,
) -> Result[Uuid, GenerateError] {
  match provider(16) {
    None => Err(EntropyUnavailable)
    Some(entropy) => v4_from_entropy(entropy)
  }
}

///|
/// Generate an RFC 9562 UUIDv4 using MoonBit's platform entropy source.
///
/// `@env.rand` uses a secure platform entropy source when available. This
/// function returns `EntropyUnavailable` instead of falling back to a weak PRNG.
///
/// Current MoonBit target behavior includes:
/// - native: runtime platform entropy
/// - js: `globalThis.crypto.getRandomValues`
/// - wasm: WASI `random_get` when the host provides it
/// - wasm-gc: currently unavailable in the MoonBit core runtime
pub fn v4() -> Result[Uuid, GenerateError] {
  v4_with_entropy(@env.rand)
}
