fn main {
  let logical_resource = "https://example.com/users/42"
  let id = @uuid.v5_string(@uuid.namespace_url(), logical_resource)

  println("resource=" + logical_resource)
  println("resource_id=" + @uuid.to_string(id))
}
