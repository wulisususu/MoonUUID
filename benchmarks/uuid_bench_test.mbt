///|
test "MoonUUID core microbenchmarks" (b : @bench.T) {
  let canonical = "017f22e2-79b0-7cc3-98c4-dc0c0c07398f"
  let parsed = match @uuid.parse(canonical) {
    Ok(id) => id
    Err(_) => fail("benchmark fixture must parse")
  }
  let entropy = b"\x91\x91\x08\xf7\x52\xd1\x43\x20\x9b\xac\xf8\x47\xdb\x41\x48\xa8"

  b.bench(name="parse_canonical", fn() {
    match @uuid.parse(canonical) {
      Ok(id) => b.keep(@uuid.high(id))
      Err(_) => ()
    }
  })

  b.bench(name="format_canonical", fn() { b.keep(@uuid.to_string(parsed)) })

  b.bench(name="v4_from_entropy", fn() {
    b.keep(@uuid.v4_from_entropy(entropy))
  })

  b.bench(name="v5_string", fn() {
    b.keep(@uuid.v5_string(@uuid.namespace_dns(), "www.example.com"))
  })

  b.bench(name="v7_from_parts", fn() {
    b.keep(@uuid.v7_from_parts(1645557742000UL, 0xCC3UL, 0x18C4DC0C0C07398FUL))
  })
}
