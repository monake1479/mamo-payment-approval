# Application Structure

Use a feature-first structure. The intended dependency direction is:

```text
presentation -> domain <- data
      |           ^        |
      +-----------+--------+
          dependency wiring
```

## Responsibilities

- `lib/app/`: app composition, router, root shell, global theme, and dependency wiring.
- `lib/core/`: small primitives shared by multiple features. Do not use it as a miscellaneous folder.
- `lib/features/payments/domain/`: payment entities, value rules, repository contracts, and use cases. It must not import Flutter.
- `lib/features/payments/data/`: deterministic demo data, DTO mapping, and repository implementations.
- `lib/features/payments/presentation/`: implemented screens, overlays, widgets, and state holders.

Create directories and abstractions when the first real type needs them; do not commit empty architecture ceremony.

## Boundary rules

- Presentation depends on domain contracts, not concrete data sources.
- Data implementations translate storage or platform failures before returning across the boundary.
- Device authentication is a capability behind a domain-facing interface. iOS and Android use native adapters; tests use deterministic fakes. No Web simulator is planned.
- Navigation is application infrastructure. Domain and data layers know nothing about routes or `BuildContext`.
- The payment collection has one authoritative state owner so decisions update the home summary, list, and details consistently.
- Temporary overlay concerns, such as revealing masked data, should not leak into the persisted payment entity.
- Prefer constructor injection and explicit composition in `lib/app/`. If `get_it` is introduced with a documented reason, resolve dependencies in composition/provider creation, not inside business methods.
- Use cases own meaningful business operations. A separate data source, DTO, or forwarding use case must justify its existence; an in-memory repository does not automatically require all three.

## Anchors

- `docs/decisions/0001-feature-first-clean-architecture.md`
- `docs/architecture/overview.md`
- `lib/app/app.dart` and `lib/app/payment_flow_layer.dart` (current composition and feature wiring)
