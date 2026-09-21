import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/payment_flow_layer.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/local_authentication_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/stop_local_authentication_use_case.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/settings/states/theme_mode/theme_mode_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/settings/states/theme_mode/theme_mode_state.dart';
import 'package:mamo_payment_approval_challenge/features/settings/theme_mode_presentation.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

typedef GlobalAppLayerBuilder = Widget Function(
  BuildContext context,
  Widget navigator,
);

class MamoPaymentApprovalApp extends StatefulWidget {
  const MamoPaymentApprovalApp({
    required this.router,
    required this.paymentsCubit,
    required this.themeModeCubit,
    required this.authenticate,
    required this.stopAuthentication,
    this.globalLayerBuilder,
    super.key,
  });

  final GoRouter router;
  final PaymentsCubit paymentsCubit;
  final ThemeModeCubit themeModeCubit;
  final LocalAuthenticationUseCase authenticate;
  final StopLocalAuthenticationUseCase stopAuthentication;
  final GlobalAppLayerBuilder? globalLayerBuilder;

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
      child: BlocProvider<ThemeModeCubit>.value(
        value: widget.themeModeCubit,
        child: BlocBuilder<ThemeModeCubit, ThemeModeState>(
          builder: (BuildContext context, ThemeModeState themeState) {
            return MaterialApp.router(
              routerConfig: widget.router,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeState.preference.materialThemeMode,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              onGenerateTitle: (BuildContext context) =>
                  AppLocalizations.of(context).appTitle,
              builder: (BuildContext context, Widget? navigator) {
                final Widget routedContent = widget.globalLayerBuilder == null
                    ? navigator!
                    : widget.globalLayerBuilder!(context, navigator!);
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: AppTheme.systemUiOverlayStyle(
                    Theme.of(context).colorScheme,
                  ),
                  child: PaymentFlowLayer(
                    router: widget.router,
                    authenticate: widget.authenticate,
                    stopAuthentication: widget.stopAuthentication,
                    child: routedContent,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
