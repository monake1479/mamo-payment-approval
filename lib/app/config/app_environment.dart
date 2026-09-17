enum AppEnvironment { dev, staging, prod }

class AppEnvironmentMismatch implements Exception {
  const AppEnvironmentMismatch();
}

void validateAppEnvironment(AppEnvironment expected, String? nativeFlavor) {
  // This must also run in release: assertions cannot protect flavor wiring.
  if (nativeFlavor != expected.name) {
    throw const AppEnvironmentMismatch();
  }
}
