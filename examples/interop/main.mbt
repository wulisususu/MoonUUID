fn main {
  let incoming =
    "urn:uuid:017f22e2-79b0-7cc3-98c4-dc0c0c07398f"

  match @uuid.parse_permissive(incoming) {
    Err(_) => println("invalid UUID")
    Ok(id) => {
      let bytes = @uuid.to_bytes(id)
      println("canonical=" + @uuid.to_string(id))
      println("byte_length=" + bytes.length().to_string())

      match @uuid.from_bytes(bytes) {
        Err(_) => println("binary decode failed")
        Ok(decoded) =>
          println("round_trip=" + @uuid.to_string(decoded))
      }
    }
  }
}
