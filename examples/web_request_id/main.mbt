fn main {
  match @uuid.v7() {
    Err(_) => println("secure entropy unavailable")
    Ok(id) => {
      let value = @uuid.to_string(id)
      println("request_id=" + value)
      println("X-Request-ID: " + value)
    }
  }
}
