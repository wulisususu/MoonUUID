///|
/// A UUID represented as two unsigned 64-bit words in network byte order.
///
/// `high` stores octets 0..7 and `low` stores octets 8..15.
pub struct Uuid {
  high : UInt64
  low : UInt64
} derive(Eq, Compare, Hash)

///|
/// UUID layout variant as defined by RFC 9562 section 4.1.
pub(all) enum Variant {
  Ncs
  Rfc9562
  Microsoft
  Future
} derive(Eq)

///|
/// Error returned when parsing the canonical 8-4-4-4-12 UUID text form.
pub(all) enum ParseError {
  InvalidLength(Int)
  InvalidHyphen(Int)
  InvalidHexDigit(Int)
} derive(Eq)

///|
/// Construct a UUID directly from its high and low 64-bit words.
pub fn from_u64s(high : UInt64, low : UInt64) -> Uuid {
  { high, low }
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
  { high: 0UL, low: 0UL }
}

///|
/// RFC 9562 Max UUID: all 128 bits are one.
pub fn max() -> Uuid {
  { high: 0xFFFFFFFFFFFFFFFFUL, low: 0xFFFFFFFFFFFFFFFFUL }
}

///|
/// Return true when this is the RFC 9562 Nil UUID.
pub fn is_nil(uuid : Uuid) -> Bool {
  uuid.high == 0UL && uuid.low == 0UL
}

///|
/// Return true when this is the RFC 9562 Max UUID.
pub fn is_max(uuid : Uuid) -> Bool {
  uuid.high == 0xFFFFFFFFFFFFFFFFUL &&
  uuid.low == 0xFFFFFFFFFFFFFFFFUL
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
/// Parse a canonical UUID string in 8-4-4-4-12 form.
///
/// Both uppercase and lowercase hexadecimal digits are accepted.
/// Formatting always emits lowercase hexadecimal digits.
pub fn parse(text : String) -> Result[Uuid, ParseError] {
  if text.length() != 36 {
    return Err(InvalidLength(text.length()))
  }

  let mut high = 0UL
  let mut low = 0UL
  let mut digit_index = 0

  for i = 0; i < 36; i = i + 1 {
    let code_unit = text.code_unit_at(i)
    if i == 8 || i == 13 || i == 18 || i == 23 {
      if code_unit.to_int() != 45 {
        return Err(InvalidHyphen(i))
      }
    } else {
      match hex_value(code_unit) {
        None => return Err(InvalidHexDigit(i))
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

  Ok({ high, low })
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
fn hex_char(nibble : Int) -> Char {
  if nibble < 10 {
    (48 + nibble).unsafe_to_char()
  } else {
    (87 + nibble).unsafe_to_char()
  }
}

///|
/// Format a UUID as lowercase canonical 8-4-4-4-12 text.
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
