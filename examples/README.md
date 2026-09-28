# Runnable examples

These programs demonstrate realistic consumers of the MoonUUID library.

```bash
moon run examples/web_request_id --target native
moon run examples/database_key --target native
moon run examples/deterministic_resource_id --target native
moon run examples/interop --target native
```

- `web_request_id`: UUIDv7 correlation/request ID.
- `database_key`: monotonic UUIDv7 keys produced by one generator.
- `deterministic_resource_id`: stable UUIDv5 resource identifier.
- `interop`: URN parsing and 16-byte round trip.

Examples are repository verification material and are excluded from the
Mooncakes publication archive by `.moonignore`.
