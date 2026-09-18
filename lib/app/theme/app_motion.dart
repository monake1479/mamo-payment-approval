import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration stagger = Duration(milliseconds: 56);
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve pageCurve = Curves.easeInOutCubic;
  static const double entranceOffset = AppTheme.compactPadding;
  static const double bottomSheetContentStartFraction = 0.65;
  static const double dialogContentStartFraction = 0.45;
  static const double pageTransitionOffset = 1;

  static Duration resolve(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

  static Duration staggeredDuration(int itemCount) {
    if (itemCount <= 1) {
      return standard;
    }
    return Duration(
      milliseconds:
          standard.inMilliseconds + (itemCount - 1) * stagger.inMilliseconds,
    );
  }
}

class AppMotionPage<T> extends CustomTransitionPage<T> {
  AppMotionPage({
    required BuildContext context,
    required super.key,
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
         transitionDuration: AppMotion.resolve(context, AppMotion.standard),
         reverseTransitionDuration: AppMotion.resolve(context, AppMotion.fast),
         transitionsBuilder: _buildTransition,
       );

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    final double direction = Directionality.of(context) == TextDirection.ltr
        ? 1
        : -1;
    final Animation<double> primary = CurvedAnimation(
      parent: animation,
      curve: AppMotion.pageCurve,
      reverseCurve: AppMotion.pageCurve,
    );
    final Animation<double> secondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.pageCurve,
      reverseCurve: AppMotion.pageCurve,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: Offset(-AppMotion.pageTransitionOffset * direction, 0),
      ).animate(secondary),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(AppMotion.pageTransitionOffset * direction, 0),
          end: Offset.zero,
        ).animate(primary),
        child: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        ),
      ),
    );
  }
}

class AppPageTransitionSwitcher extends StatefulWidget {
  const AppPageTransitionSwitcher({
    required this.child,
    required this.direction,
    this.onTransitionCompleted,
    super.key,
  }) : assert(direction == -1 || direction == 1);

  final Widget child;
  final int direction;
  final VoidCallback? onTransitionCompleted;

  @override
  State<AppPageTransitionSwitcher> createState() =>
      _AppPageTransitionSwitcherState();
}

class _AppPageTransitionSwitcherState extends State<AppPageTransitionSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: AppMotion.standard,
    vsync: this,
  )..addStatusListener(_handleAnimationStatus);
  late Widget _currentChild = widget.child;
  Widget? _outgoingChild;
  int _direction = 1;
  bool _animationsDisabled = false;

  @override
  void initState() {
    super.initState();
    assert(widget.child.key != null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationsDisabled = MediaQuery.disableAnimationsOf(context);
    if (_animationsDisabled && _outgoingChild != null) {
      _controller.value = 1;
      _outgoingChild = null;
    }
  }

  @override
  void didUpdateWidget(AppPageTransitionSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child.key == _currentChild.key) {
      _currentChild = widget.child;
      return;
    }
    _outgoingChild = _currentChild;
    _currentChild = widget.child;
    _direction = widget.direction;
    if (_animationsDisabled) {
      _outgoingChild = null;
      _controller.value = 1;
      widget.onTransitionCompleted?.call();
    } else {
      _controller.forward(from: 0);
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed ||
        _outgoingChild == null ||
        !mounted) {
      return;
    }
    setState(() => _outgoingChild = null);
    widget.onTransitionCompleted?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget? outgoingChild = _outgoingChild;
    if (_animationsDisabled || outgoingChild == null) {
      return _currentChild;
    }
    final double textDirection = Directionality.of(context) == TextDirection.ltr
        ? 1
        : -1;
    final double offset =
        AppMotion.pageTransitionOffset * _direction * textDirection;
    final Color surfaceColor = Theme.of(context).scaffoldBackgroundColor;
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double progress = AppMotion.pageCurve.transform(
            _controller.value,
          );
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              FractionalTranslation(
                translation: Offset(-offset * progress, 0),
                child: ColoredBox(color: surfaceColor, child: outgoingChild),
              ),
              FractionalTranslation(
                translation: Offset(offset * (1 - progress), 0),
                child: ColoredBox(color: surfaceColor, child: _currentChild),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AppMotionSwitcher extends StatelessWidget {
  const AppMotionSwitcher({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.resolve(context, AppMotion.standard),
      reverseDuration: AppMotion.resolve(context, AppMotion.fast),
      switchInCurve: AppMotion.enterCurve,
      switchOutCurve: AppMotion.exitCurve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: child,
    );
  }
}

class AppStaggeredColumn extends StatefulWidget {
  const AppStaggeredColumn({
    required this.children,
    this.spacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.replayKey,
    this.startAnimation = true,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  /// Change this value when already-mounted content should replay its entrance.
  final Object? replayKey;
  final bool startAnimation;

  @override
  State<AppStaggeredColumn> createState() => _AppStaggeredColumnState();
}

class _AppStaggeredColumnState extends State<AppStaggeredColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: AppMotion.staggeredDuration(widget.children.length),
    vsync: this,
  );
  bool _started = false;
  bool _animationsDisabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool animationsDisabled = MediaQuery.disableAnimationsOf(context);
    if (animationsDisabled) {
      _controller.value = 1;
    } else if (widget.startAnimation && !_started) {
      _started = true;
      _controller.forward();
    }
    _animationsDisabled = animationsDisabled;
  }

  @override
  void didUpdateWidget(AppStaggeredColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool shouldReplay =
        oldWidget.replayKey != widget.replayKey ||
        oldWidget.children.length != widget.children.length;
    _controller.duration = AppMotion.staggeredDuration(widget.children.length);
    if (_animationsDisabled) {
      _controller.value = 1;
      return;
    }
    if (oldWidget.startAnimation && !widget.startAnimation) {
      _started = false;
      _controller.value = 0;
      return;
    }
    if (!oldWidget.startAnimation && widget.startAnimation) {
      _started = true;
      _controller.forward(from: 0);
      return;
    }
    if (!shouldReplay) {
      return;
    }
    if (widget.startAnimation) {
      _started = true;
      _controller.forward(from: 0);
    } else {
      _started = false;
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }
    final int totalMilliseconds = _controller.duration!.inMilliseconds;
    final List<Widget> animatedChildren = <Widget>[];

    for (int index = 0; index < widget.children.length; index += 1) {
      final int startMilliseconds = index * AppMotion.stagger.inMilliseconds;
      final double start = startMilliseconds / totalMilliseconds;
      final double end =
          (startMilliseconds + AppMotion.standard.inMilliseconds) /
          totalMilliseconds;
      final Animation<double> animation = CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: AppMotion.enterCurve),
      );
      if (index > 0 && widget.spacing > 0) {
        animatedChildren.add(SizedBox(height: widget.spacing));
      }
      animatedChildren.add(
        AnimatedBuilder(
          animation: animation,
          child: widget.children[index],
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: animation.value,
              child: Transform.translate(
                offset: Offset(
                  0,
                  AppMotion.entranceOffset * (1 - animation.value),
                ),
                child: child,
              ),
            );
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: animatedChildren,
    );
  }
}

class AppBottomSheetStaggeredColumn extends StatelessWidget {
  const AppBottomSheetStaggeredColumn({
    required this.children,
    this.spacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.replayKey,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final Object? replayKey;

  @override
  Widget build(BuildContext context) {
    return _AppRouteStaggeredColumn(
      startFraction: AppMotion.bottomSheetContentStartFraction,
      spacing: spacing,
      crossAxisAlignment: crossAxisAlignment,
      replayKey: replayKey,
      children: children,
    );
  }
}

class AppDialogStaggeredColumn extends StatelessWidget {
  const AppDialogStaggeredColumn({
    required this.children,
    this.spacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.replayKey,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final Object? replayKey;

  @override
  Widget build(BuildContext context) {
    return _AppRouteStaggeredColumn(
      startFraction: AppMotion.dialogContentStartFraction,
      spacing: spacing,
      crossAxisAlignment: crossAxisAlignment,
      replayKey: replayKey,
      children: children,
    );
  }
}

class _AppRouteStaggeredColumn extends StatefulWidget {
  const _AppRouteStaggeredColumn({
    required this.startFraction,
    required this.children,
    required this.spacing,
    required this.crossAxisAlignment,
    required this.replayKey,
  });

  final double startFraction;
  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final Object? replayKey;

  @override
  State<_AppRouteStaggeredColumn> createState() =>
      _AppRouteStaggeredColumnState();
}

class _AppRouteStaggeredColumnState extends State<_AppRouteStaggeredColumn> {
  Animation<double>? _routeAnimation;
  bool _startContentAnimation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Animation<double>? routeAnimation = ModalRoute.of(context)?.animation;
    if (identical(routeAnimation, _routeAnimation)) {
      return;
    }
    _routeAnimation?.removeListener(_handleRouteAnimation);
    _routeAnimation = routeAnimation;
    _startContentAnimation = _routeIsReady;
    _routeAnimation?.addListener(_handleRouteAnimation);
  }

  bool get _routeIsReady =>
      _routeAnimation == null || _routeAnimation!.value >= widget.startFraction;

  void _handleRouteAnimation() {
    if (_startContentAnimation || !_routeIsReady || !mounted) {
      return;
    }
    setState(() => _startContentAnimation = true);
  }

  @override
  void dispose() {
    _routeAnimation?.removeListener(_handleRouteAnimation);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStaggeredColumn(
      spacing: widget.spacing,
      crossAxisAlignment: widget.crossAxisAlignment,
      replayKey: widget.replayKey,
      startAnimation: _startContentAnimation,
      children: widget.children,
    );
  }
}
