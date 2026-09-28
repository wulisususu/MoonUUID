///|
/// A UUID represented as two unsigned 64-bit words in network byte order.
///
/// `high` stores octets 0..7 and `low` stores octets 8..15.
pub struct Uuid {
  high : UInt64
  low : UInt64
} derive(Eq, Compare, Hash)

///|
pub extend Uuid with Eq::{not_equal, equal}

///|
pub extend Uuid with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend Uuid with Hash::{hash, hash_combine}

///|
/// UUID layout variant as defined by RFC 9562 section 4.1.
pub(all) enum Variant {
  Ncs
  Rfc9562
  Microsoft
  Future
} derive(Eq)

///|
pub extend Variant with Eq::{not_equal, equal}

///|
/// Error returned while parsing UUID text.
pub(all) enum ParseError {
  InvalidLength(Int)
  InvalidHyphen(Int)
  InvalidHexDigit(Int)
  InvalidWrapper
} derive(Eq)

///|
pub extend ParseError with Eq::{not_equal, equal}

///|
/// Error returned while converting binary UUID data.
pub(all) enum BytesError {
  InvalidByteLength(Int)
} derive(Eq)

///|
pub extend BytesError with Eq::{not_equal, equal}

///|
/// Construct a UUID directly from its high and low 64-bit words.
pub fn from_u64s(high : UInt64, low : UInt64) -> Uuid {
  { high, low, }
}

///|
/// Return the most-significant 64 bits.
pub fn high(uuid : Uuid) -> UInt64 {
  uuid.high
}

///|
/// Return the least-significant 64 bits.
pub fn low(uuid : Uuid) -> UInt64 {
  uuid.low
}

///|
/// RFC 9562 Nil UUID: all 128 bits are zero.
pub fn nil() -> Uuid {
  { high: 0UL, low: 0UL, }
}

///|
/// RFC 9562 Max UUID: all 128 bits are one.
pub fn max() -> Uuid {
  { high: 0xFFFFFFFFFFFFFFFFUL, low: 0xFFFFFFFFFFFFFFFFUL, }
}

///|
/// Return true when this is the RFC 9562 Nil UUID.
pub fn is_nil(uuid : Uuid) -> Bool {
  uuid.high == 0UL && uuid.low == 0UL
}

///|
/// Return true when this is the RFC 9562 Max UUID.
pub fn is_max(uuid : Uuid) -> Bool {
  uuid.high == 0xFFFFFFFFFFFFFFFFUL && uuid.low == 0xFFFFFFFFFFFFFFFFUL
}

///|
fn hex_value(code_unit : UInt16) -> Int? {
  let value = code_unit.to_int()
  if value >= 48 && value <= 57 {
    Some(value - 48)
  } else if value >= 65 && value <= 70 {
    Some(value - 65 + 10)
  } else if value >= 97 && value <= 102 {
    Some(value - 97 + 10)
  } else {
    None
  }
}

///|
fn parse_canonical_at(text : String, start : Int) -> Result[Uuid, ParseError] {
  let mut high = 0UL
  let mut low = 0UL
  let mut digit_index = 0

  for offset = 0; offset < 36; offset = offset + 1 {
    let index = start + offset
    let code_unit = text.code_unit_at(index)
    if offset == 8 || offset == 13 || offset == 18 || offset == 23 {
      if code_unit.to_int() != 45 {
        return Err(InvalidHyphen(index))
      }
    } else {
      match hex_value(code_unit) {
        None => return Err(InvalidHexDigit(index))
        Some(nibble) => {
          if digit_index < 16 {
            high = (high << 4) | nibble.to_uint64()
          } else {
            low = (low << 4) | nibble.to_uint64()
          }
          digit_index = digit_index + 1
        }
      }
    }
  }

  Ok({ high, low, })
}

///|
fn parse_compact_at(text : String, start : Int) -> Result[Uuid, ParseError] {
  let mut high = 0UL
  let mut low = 0UL

  for offset = 0; offset < 32; offset = offset + 1 {
    let index = start + offset
    match hex_value(text.code_unit_at(index)) {
      None => return Err(InvalidHexDigit(index))
      Some(nibble) =>
        if offset < 16 {
          high = (high << 4) | nibble.to_uint64()
        } else {
          low = (low << 4) | nibble.to_uint64()
        }
    }
  }

  Ok({ high, low, })
}

///|
fn ascii_eq_ignore_case(actual : UInt16, lowercase_ascii : Int) -> Bool {
  let value = actual.to_int()
  let folded = if value >= 65 && value <= 90 { value + 32 } else { value }
  folded == lowercase_ascii
}

///|
fn has_urn_uuid_prefix(text : String) -> Bool {
  text.length() >= 9 &&
  ascii_eq_ignore_case(text.code_unit_at(0), 117) &&
  ascii_eq_ignore_case(text.code_unit_at(1), 114) &&
  ascii_eq_ignore_case(text.code_unit_at(2), 110) &&
  text.code_unit_at(3).to_int() == 58 &&
  ascii_eq_ignore_case(text.code_unit_at(4), 117) &&
  ascii_eq_ignore_case(text.code_unit_at(5), 117) &&
  ascii_eq_ignore_case(text.code_unit_at(6), 105) &&
  ascii_eq_ignore_case(text.code_unit_at(7), 100) &&
  text.code_unit_at(8).to_int() == 58
}

///|
/// Parse only the canonical UUID text form: `8-4-4-4-12`.
///
/// Both uppercase and lowercase hexadecimal digits are accepted.
/// Other common wrappers and compact text are intentionally rejected here.
/// Use `parse_permissive` when interoperability with those forms is required.
pub fn parse(text : String) -> Result[Uuid, ParseError] {
  if text.length() != 36 {
    return Err(InvalidLength(text.length()))
  }
  parse_canonical_at(text, 0)
}

///|
/// Parse common interoperable UUID text forms.
///
/// Accepted forms:
/// - canonical: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
/// - compact: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
/// - URN: `urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
/// - braced: `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}`
pub fn parse_permissive(text : String) -> Result[Uuid, ParseError] {
  match text.length() {
    36 => parse_canonical_at(text, 0)
    32 => parse_compact_at(text, 0)
    38 =>
      if text.code_unit_at(0).to_int() == 123 &&
        text.code_unit_at(37).to_int() == 125 {
        parse_canonical_at(text, 1)
      } else {
        Err(InvalidWrapper)
      }
    45 =>
      if has_urn_uuid_prefix(text) {
        parse_canonical_at(text, 9)
      } else {
        Err(InvalidWrapper)
      }
    length => Err(InvalidLength(length))
  }
}

///|
/// Return true if `text` is a canonical UUID string accepted by `parse`.
pub fn is_valid(text : String) -> Bool {
  match parse(text) {
    Ok(_) => true
    Err(_) => false
  }
}

///|
/// Return true if `text` is accepted by `parse_permissive`.
pub fn is_valid_permissive(text : String) -> Bool {
  match parse_permissive(text) {
    Ok(_) => true
    Err(_) => false
  }
}

///|
fn hex_char(nibble : Int) -> Char {
  if nibble < 10 {
    (48 + nibble).unsafe_to_char()
  } else {
    (87 + nibble).unsafe_to_char()
  }
}

///|
/// Format a UUID as lowercase canonical `8-4-4-4-12` text.
pub fn to_string(uuid : Uuid) -> String {
  let builder = StringBuilder()

  for i = 0; i < 32; i = i + 1 {
    if i == 8 || i == 12 || i == 16 || i == 20 {
      builder.write_char('-')
    }

    let nibble = if i < 16 {
      let shift = (15 - i) * 4
      ((uuid.high >> shift) & 0xFUL).to_int()
    } else {
      let shift = (31 - i) * 4
      ((uuid.low >> shift) & 0xFUL).to_int()
    }
    builder.write_char(hex_char(nibble))
  }

  builder.to_string()
}

///|
/// Format a UUID as an RFC UUID URN.
pub fn to_urn(uuid : Uuid) -> String {
  "urn:uuid:" + to_string(uuid)
}

///|
/// Format a UUID using the common braced canonical form.
pub fn to_braced_string(uuid : Uuid) -> String {
  "{" + to_string(uuid) + "}"
}

///|
fn uuid_byte(uuid : Uuid, index : Int) -> Byte {
  if index < 8 {
    let shift = (7 - index) * 8
    ((uuid.high >> shift) & 0xFFUL).to_byte()
  } else {
    let shift = (15 - index) * 8
    ((uuid.low >> shift) & 0xFFUL).to_byte()
  }
}

///|
/// Encode the UUID as exactly 16 bytes in RFC network byte order.
pub fn to_bytes(uuid : Uuid) -> Bytes {
  let result : Bytes = [ for i in 0..<16 => uuid_byte(uuid, i) ]
  result
}

///|
/// Decode exactly 16 bytes in RFC network byte order into a UUID.
pub fn from_bytes(data : Bytes) -> Result[Uuid, BytesError] {
  if data.length() != 16 {
    return Err(InvalidByteLength(data.length()))
  }

  let mut high = 0UL
  let mut low = 0UL

  for i = 0; i < 8; i = i + 1 {
    high = (high << 8) | data[i].to_int().to_uint64()
  }
  for i = 8; i < 16; i = i + 1 {
    low = (low << 8) | data[i].to_int().to_uint64()
  }

  Ok({ high, low, })
}

///|
/// Return the UUID layout variant from the most-significant bits of octet 8.
pub fn variant(uuid : Uuid) -> Variant {
  let octet = ((uuid.low >> 56) & 0xFFUL).to_int()
  if (octet & 0x80) == 0 {
    Ncs
  } else if (octet & 0xC0) == 0x80 {
    Rfc9562
  } else if (octet & 0xE0) == 0xC0 {
    Microsoft
  } else {
    Future
  }
}

///|
/// Return the 4-bit UUID version for RFC 9562-layout UUIDs.
///
/// Non-RFC variants do not share the RFC version-field semantics and return None.
pub fn version(uuid : Uuid) -> Int? {
  if variant(uuid) == Rfc9562 {
    Some(((uuid.high >> 12) & 0xFUL).to_int())
  } else {
    None
  }
}
