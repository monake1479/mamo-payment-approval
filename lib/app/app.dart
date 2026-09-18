import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/app/payment_flow_layer.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/device_authenticator.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class MamoPaymentApprovalApp extends StatefulWidget {
  const MamoPaymentApprovalApp({
    required this.router,
    required this.paymentsCubit,
    required this.deviceAuthenticator,
    super.key,
  });

  final MamoPaymentRouter router;
  final PaymentsCubit paymentsCubit;
  final DeviceAuthenticator deviceAuthenticator;

  @override
  State<MamoPaymentApprovalApp> createState() => _MamoPaymentApprovalAppState();
}

class _MamoPaymentApprovalAppState extends State<MamoPaymentApprovalApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleInitialLoad(widget.paymentsCubit);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(MamoPaymentApprovalApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.paymentsCubit, oldWidget.paymentsCubit)) {
      _scheduleInitialLoad(widget.paymentsCubit);
    }
  }

  void _scheduleInitialLoad(PaymentsCubit cubit) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && identical(cubit, widget.paymentsCubit)) {
        unawaited(cubit.load());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.paymentsCubit.refreshDerivedState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentsCubit>.value(
      value: widget.paymentsCubit,
      child: MaterialApp.router(
        routerConfig: widget.router.router,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context).appTitle,
        builder: (BuildContext context, Widget? navigator) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.systemUiOverlayStyle(Theme.of(context).colorScheme),
            child: PaymentFlowLayer(
              router: widget.router.router,
              authenticator: widget.deviceAuthenticator,
              child: navigator!,
            ),
          );
        },
      ),
    );
  }
}
