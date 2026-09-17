# Engineering Standards

- Keep changes small, cohesive, and easy to review.
- Prefer the simplest implementation that preserves the documented boundaries.
- Use precise domain names. Avoid generic `Manager`, `Helper`, and `Utils` types.
- Make illegal or incomplete states difficult to represent.
- Keep public APIs small and type annotated.
- Use UTC for stored instants and convert only for display. Inject time where tests depend on the current date.
- Catch infrastructure exceptions at the boundary and map them to explicit failures. Never use an empty catch block.
- Keep data fixtures deterministic. Do not let tests depend on wall-clock time, ordering accidents, or network access.
- Never log payment details, authentication results, or other sensitive data.
- Do not add speculative compatibility layers or abstractions for imagined future requirements.
- Prefer comments that explain a non-obvious decision. Do not narrate self-explanatory code.
- Verify review findings against current code and reproduce the failure when practical.
- Remove stale comments, commented-out code, debug output, and unused code. Preserve explanations of trade-offs and concurrency safeguards.
- Dependencies, code generation, generic value-object hierarchies, compatibility shims, and caches need a concrete reason.
- Keep accepted decisions distinct from proposals. Record significant trade-offs in ADRs, not one ADR per class.
