# Configuration and dependency hygiene

- Commit `pubspec.lock` and use `fvm flutter pub get --enforce-lockfile` for
  verification. CI uses the same flag. Intentional dependency changes use
  `fvm flutter pub get`, inspect the lockfile diff, and rerun affected native builds.
- Before adding/updating a package, check its official release/API/platform
  support, license, maintenance, and actual need. Use `fvm flutter pub outdated`
  during explicit dependency reviews; do not update transitives merely because
  an informational warning exists. No external vulnerability service is configured.
- Configuration currently consists of the explicit flavor. Bootstrap rejects a
  missing/mismatched native flavor even in release. No speculative endpoints,
  secret values, or second environment selector are added.
- Mobile binaries are not secret stores. Do not ship server keys in Dart defines,
  ARB, native resources, or CI artifacts. Future endpoints must be validated at the
  configuration boundary; credentials require a separately designed runtime flow.
- Run `python3 tool/scan_secrets.py` before publication. The scanner requires
  Gitleaks 8.30.1 and accepts `--binary /path/to/gitleaks`; it does not change a global
  installation. CI downloads the official Linux archive and checks its pinned
  SHA-256. Local installations should use the official release and verified checksum.
- The working scan includes untracked publishable files and excludes Git-ignored
  build/cache/signing files. A separate scan covers all locally available history.
  Both use built-in rules, ignore inline allow comments, and report only exit status.
  A finding blocks publication. Inspect locally with redaction, remediate, and
  rerun; do not upload raw scanner context. Review remains necessary for information
  that generic secret patterns do not recognize.
- A shallow local clone cannot prove absent secrets in unavailable history. CI
  checks out full history. Local success does not mean current-head CI succeeded.

The selective pre-push test policy remains unchanged. Secret scanning is a separate
publication/CI gate, not an excuse to rerun all Flutter tests on every feature push.

Reference: [Gitleaks official releases](https://github.com/gitleaks/gitleaks/releases/tag/v8.30.1).
