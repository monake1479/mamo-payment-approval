# ADR 0001: Feature-first clean architecture

- Status: Partially superseded by ADR 0011
- Date: 2026-09-15

## Context

The challenge is small enough for a simple app, but its payment decisions, authentication boundary, cross-screen consistency, and review handover benefit from explicit separation. A package-per-layer structure would add navigation overhead, while a single widget tree would make business behaviour difficult to test.

## Decision

Use a feature-first structure. Within the payments feature, separate presentation, domain, and data concerns only where concrete types exist. Keep dependency composition in `lib/app/` and platform-independent business rules in the domain layer.

Use BLoC/Cubit for asynchronous or cross-screen state. Keep purely visual, ephemeral state local to a widget.

ADR 0011 replaces the data-placement part of this decision with domain-grouped shared data under `lib/common/data/<domain>/`. Feature-local presentation remains under `lib/features/`.

## Consequences

- Reviewers can follow one feature from UI to business rules and data.
- The in-memory payment repository is concrete; native authentication uses its required platform boundary. Tests provide deterministic collaborators. The initial Web-simulator proposal was superseded by ADR 0003.
- Business rules can be covered by fast unit tests.
- The project avoids a multi-package setup and speculative generic abstractions.
- Some mapping and wiring code is accepted in exchange for explicit boundaries.
