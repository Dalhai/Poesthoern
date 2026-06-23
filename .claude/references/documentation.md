# Documentation references

Curated, canonical documentation links for the libraries, APIs, and related
projects this project uses. **Consult this before searching the web** —
`WebFetch` the relevant URL directly instead of `WebSearch`-ing from scratch.

Conventions:
- Prefer an `llms.txt` / `llms-full.txt` entry point where one exists.
- Links only — do not vendor doc copies into the repo.
- Found a genuinely useful page that isn't here? Append it (technology,
  version, URL, one-line note). Versions below match `mix.exs` at time of
  writing — bump them when deps change.

## Related projects

| Project | URL | Notes |
| --- | --- | --- |
| Örglbörg (Oergelboerg) | https://github.com/Dalhai/Oergelboerg | The first consuming app of this relay (Örglbörg issue #152). It codes against the `POST /report` contract and ships only the relay URL + its app token. Reference for the client side of the contract and the originating spike (Örglbörg #153). |
