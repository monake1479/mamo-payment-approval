import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/authentication/device_authenticator.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/approval_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/debug_action_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/approval_overlay.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/debug_payment_action.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class PaymentFlowLayer extends StatefulWidget {
  const PaymentFlowLayer({
    required this.router,
    required this.authenticator,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final DeviceAuthenticator authenticator;
  final Widget child;

  @override
  State<PaymentFlowLayer> createState() => _PaymentFlowLayerState();
}

class _PaymentFlowLayerState extends State<PaymentFlowLayer>
    with WidgetsBindingObserver {
  late final DebugActionCubit _debugActionCubit;
  ApprovalCubit? _approvalCubit;
  ApprovalOverlayRoute? _approvalRoute;
  StreamSubscription<ApprovalState>? _approvalSubscription;
  bool _foreground = true;
  bool _completionInProgress = false;

  @override
  void initState() {
    super.initState();
    _debugActionCubit = DebugActionCubit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _synchronizeRequest(context.read<PaymentsCubit>().state);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _foreground = true;
        _consumeCompletionIfReady();
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (_foreground) {
          _foreground = false;
          final ApprovalCubit? cubit = _approvalCubit;
          if (cubit != null) {
            unawaited(cubit.backgrounded());
          }
        }
      case AppLifecycleState.inactive:
        // Native authentication can make the app inactive without actually
        // backgrounding it. Hidden/paused are the disclosure boundary.
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_approvalSubscription?.cancel());
    final ApprovalCubit? approvalCubit = _approvalCubit;
    if (approvalCubit != null) {
      unawaited(approvalCubit.close());
    }
    unawaited(_debugActionCubit.close());
    super.dispose();
  }

  void _synchronizeRequest(PaymentsState state) {
    if (_approvalCubit != null) {
      return;
    }
    final Payment? request = state.activeRequest;
    if (request == null) {
      return;
    }
    final ApprovalCubit cubit = ApprovalCubit(
      request: request,
      authenticator: widget.authenticator,
      decide:
          ({required String paymentId, required PaymentDecision decision}) =>
              context.read<PaymentsCubit>().decide(
                paymentId: paymentId,
                decision: decision,
              ),
    );
    final ApprovalOverlayRoute route = ApprovalOverlayRoute(
      approvalCubit: cubit,
      semanticLabel: AppLocalizations.of(context).approvalModalLabel,
    );
    _approvalCubit = cubit;
    _approvalRoute = route;
    _approvalSubscription = cubit.stream.listen(_approvalStateChanged);
    widget.router.routerDelegate.navigatorKey.currentState?.push(route);
  }

  void _approvalStateChanged(ApprovalState state) {
    if (state.phase == ApprovalPhase.completed) {
      _consumeCompletionIfReady();
    }
  }

  Future<void> _consumeCompletionIfReady() async {
    final ApprovalCubit? cubit = _approvalCubit;
    final PaymentDecision? decision = cubit?.state.completedDecision;
    if (!_foreground ||
        _completionInProgress ||
        cubit == null ||
        decision == null) {
      return;
    }
    _completionInProgress = true;
    final ApprovalOverlayRoute? route = _approvalRoute;
    if (route?.isActive ?? false) {
      route!.navigator?.removeRoute(route);
    }
    if (decision == PaymentDecision.approve && mounted) {
      widget.router.goNamed(AppRoutes.payments);
    }
    await _approvalSubscription?.cancel();
    await cubit.close();
    if (!mounted) {
      return;
    }
    setState(() {
      _approvalCubit = null;
      _approvalRoute = null;
      _approvalSubscription = null;
      _completionInProgress = false;
    });
    _synchronizeRequest(context.read<PaymentsCubit>().state);
  }

  Future<void> _createRequest() async {
    final PaymentsResult<Payment> result = await context
        .read<PaymentsCubit>()
        .createRequest();
    if (!mounted || result is PaymentsSuccess<Payment>) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).requestCreateFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentsCubit, PaymentsState>(
      listener: (BuildContext context, PaymentsState state) =>
          _synchronizeRequest(state),
      child: BlocBuilder<PaymentsCubit, PaymentsState>(
        buildWhen: (PaymentsState previous, PaymentsState current) =>
            previous.canCreateRequest != current.canCreateRequest,
        builder: (BuildContext context, PaymentsState state) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              widget.child,
              DebugPaymentAction(
                positionCubit: _debugActionCubit,
                enabled: state.canCreateRequest,
                onPressed: _createRequest,
              ),
            ],
          );
        },
      ),
    );
  }
}
