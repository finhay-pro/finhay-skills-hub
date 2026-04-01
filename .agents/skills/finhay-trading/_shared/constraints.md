# Shared Constraints

- **Read-only** — never send non-GET requests or mutating actions.
- **Credentials** — never display full keys; mask with `********`. Never send credentials outside the configured `BASE_URL`. Never bypass TLS (`--insecure`, `-k`).
- **Responses** — present results to the user immediately in a readable format. Never silently discard a response.
