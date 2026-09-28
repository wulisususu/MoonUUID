fn main {
  let generator = @uuid.V7Generator::new()

  for i = 0; i < 3; i = i + 1 {
    match generator.next() {
      Err(_) => println("secure entropy unavailable")
      Ok(id) => println("record_id=" + @uuid.to_string(id))
    }
  }
}
