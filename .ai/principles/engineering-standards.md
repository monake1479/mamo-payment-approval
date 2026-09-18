# Engineering Standards

- Keep changes small, cohesive, and easy to review.
- Prefer the simplest implementation that preserves the documented boundaries.
- Use precise domain names. Avoid generic `Manager`, `Helper`, and `Utils` types.
- Make illegal or incomplete states difficult to represent.
- Keep public APIs small and type annotated.
- Use UTC for stored instants and convert only for display. Inject time where tests depend on the current date.
- Catch infrastructure exceptions at the boundary and map them to explicit failures. Never use an empty catch block.
- Place reusable converters and cross-layer failure contracts in shared `common` modules, not inside a specific data domain. Keep domain-specific transport exception mapping beside the owning data source.
- When a runnable demo needs a backend substitute, keep it under `lib/mock_backend/<domain>/` behind a narrow backend-client contract. The mock returns transport-shaped values and backend errors; production-shaped data sources remain responsible for DTO validation and failure mapping. Keep mock timing and failures deterministic.
- Keep data fixtures deterministic. Do not let tests depend on wall-clock time, ordering accidents, or network access.
- Never log payment details, authentication results, or other sensitive data.
- Do not add speculative compatibility layers or abstractions for imagined future requirements.
- Prefer comments that explain a non-obvious decision. Do not narrate self-explanatory code.
- Verify review findings against current code and reproduce the failure when practical.
- Remove stale comments, commented-out code, debug output, and unused code. Preserve explanations of trade-offs and concurrency safeguards.
- Dependencies, code generation, generic value-object hierarchies, compatibility shims, and caches need a concrete reason.
- Model immutable data classes and sealed unions with Freezed and keep one authored model per file. Use dedicated Freezed DTOs for stored or transported shapes, validate at that boundary, and use typed `JsonConverter` classes for non-trivial values instead of field-level serialization functions or parallel handwritten codecs. Keep services and behaviour-only classes handwritten, and regenerate reviewed sources with the pinned toolchain after model changes.
- Keep accepted decisions distinct from proposals. Record significant trade-offs in ADRs, not one ADR per class.
