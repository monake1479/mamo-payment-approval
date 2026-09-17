import 'package:flutter/material.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';

class PaymentPageScaffold extends StatelessWidget {
  const PaymentPageScaffold({
    required this.title,
    required this.child,
    required this.semanticIdentifier,
    super.key,
  });

  final String title;
  final Widget child;
  final String semanticIdentifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double horizontalPadding =
                constraints.maxWidth >= AppTheme.expandedBreakpoint
                ? AppTheme.pagePadding
                : AppTheme.compactPadding;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTheme.expandedContentWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppTheme.sectionGap,
                    horizontalPadding,
                    0,
                  ),
                  child: Semantics(
                    identifier: semanticIdentifier,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Semantics(
                          header: true,
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: AppTheme.sectionGap),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
