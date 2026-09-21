import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({
    required this.amount,
    required this.approvedCount,
    required this.month,
    required this.reportingTimeZone,
    super.key,
  });

  final String amount;
  final int approvedCount;
  final String month;
  final String reportingTimeZone;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Semantics(
      identifier: 'home.summary',
      container: true,
      explicitChildNodes: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.sectionGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(l10n.currentMonthTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppTheme.smallGap),
              Text(
                l10n.reportingPeriodContext(month, reportingTimeZone),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTheme.sectionGap),
              Text(
                l10n.approvedAmountLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTheme.smallGap),
              Semantics(
                identifier: 'home.summary.amount',
                child: Text(amount, style: theme.textTheme.headlineLarge),
              ),
              const SizedBox(height: AppTheme.itemGap),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppTheme.smallGap),
                  Expanded(
                    child: Semantics(
                      identifier: 'home.summary.count',
                      child: Text(
                        l10n.approvedPaymentCount(approvedCount),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
