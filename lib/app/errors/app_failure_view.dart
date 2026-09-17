import 'package:flutter/material.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class AppFailureView extends StatelessWidget {
  const AppFailureView({required this.failure, super.key});

  final AppFailureCode failure;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.pagePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTheme.contentWidth,
              ),
              child: Semantics(
                identifier: 'app.failure',
                liveRegion: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(height: AppTheme.sectionGap),
                    Text(
                      l10n.appFailureTitle,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.itemGap),
                    Text(failure.message(l10n), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension AppFailureMessage on AppFailureCode {
  String message(AppLocalizations l10n) => switch (this) {
    AppFailureCode.environmentMismatch => l10n.appConfigurationFailure,
    AppFailureCode.startupFailed => l10n.appStartupFailure,
    AppFailureCode.unexpected => l10n.appUnexpectedFailure,
  };
}
