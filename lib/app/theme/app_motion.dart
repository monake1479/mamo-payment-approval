import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
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
  static const double pageContentStartFraction = 0.65;
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

class AppMotionPage<T> extends MaterialPage<T> {
  const AppMotionPage({
    required super.key,
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(allowSnapshotting: false);

  @override
  Route<T> createRoute(BuildContext context) =>
      _AppMotionPageRoute<T>(page: this);
}

class _AppMotionPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _AppMotionPageRoute({required AppMotionPage<T> page})
    : super(settings: page, allowSnapshotting: page.allowSnapshotting);

  AppMotionPage<T> get _page => settings as AppMotionPage<T>;

  bool get _animationsDisabled {
    final NavigatorState? navigatorState = navigator;
    return navigatorState != null &&
        MediaQuery.disableAnimationsOf(navigatorState.context);
  }

  @override
  Duration get transitionDuration =>
      _animationsDisabled ? Duration.zero : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration =>
      _animationsDisabled ? Duration.zero : super.reverseTransitionDuration;

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;
}

class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.standard;

  @override
  Duration get reverseTransitionDuration => AppMotion.fast;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
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

class AppCupertinoPageTransitionsBuilder
    extends CupertinoPageTransitionsBuilder {
  const AppCupertinoPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.standard;

  @override
  Duration get reverseTransitionDuration => AppMotion.fast;
}

class AppPageTransitionSwitcher extends StatefulWidget {
  const AppPageTransitionSwitcher({
    required this.currentIndex,
    required this.children,
    required this.onPageChanged,
    this.onTransitionStarted,
    this.onTransitionCompleted,
    super.key,
  });

  final int currentIndex;
  final List<Widget> children;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onTransitionStarted;
  final ValueChanged<int>? onTransitionCompleted;

  @override
  State<AppPageTransitionSwitcher> createState() =>
      _AppPageTransitionSwitcherState();
}

class _AppPageTransitionSwitcherState extends State<AppPageTransitionSwitcher> {
  late final PageController _controller = PageController(
    initialPage: widget.currentIndex,
  );
  bool _userScrollInProgress = false;
  int? _transitionTarget;

  @override
  void didUpdateWidget(AppPageTransitionSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex ||
        _userScrollInProgress) {
      return;
    }
    _startTransition(widget.currentIndex);
    if (_controller.hasClients) {
      _moveTo(widget.currentIndex);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _moveTo(widget.currentIndex);
    });
  }

  void _startTransition(int targetIndex) {
    if (_transitionTarget == targetIndex ||
        targetIndex < 0 ||
        targetIndex >= widget.children.length) {
      return;
    }
    _transitionTarget = targetIndex;
    widget.onTransitionStarted?.call(targetIndex);
  }

  void _moveTo(int index) {
    if (!_controller.hasClients) {
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(
        index,
        duration: AppMotion.standard,
        curve: AppMotion.pageCurve,
      );
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.idle) {
        _userScrollInProgress = false;
      } else {
        _userScrollInProgress = true;
        final int targetIndex =
            notification.direction == ScrollDirection.reverse
            ? widget.currentIndex + 1
            : widget.currentIndex - 1;
        _startTransition(targetIndex);
      }
    }
    if (notification is ScrollEndNotification && _controller.hasClients) {
      _userScrollInProgress = false;
      final int settledIndex = _controller.page!.round();
      _transitionTarget = null;
      widget.onTransitionCompleted?.call(settledIndex);
    }
    return false;
  }

  void _handlePageChanged(int index) {
    if (index != widget.currentIndex) {
      widget.onPageChanged(index);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = Theme.of(context).scaffoldBackgroundColor;
    return Semantics(
      identifier: 'navigation.swipeRegion',
      container: true,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: PageView(
          controller: _controller,
          onPageChanged: _handlePageChanged,
          allowImplicitScrolling: true,
          physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
          children: <Widget>[
            for (final (int index, Widget child) in widget.children.indexed)
              ColoredBox(
                key: ValueKey<int>(index),
                color: surfaceColor,
                child: ExcludeSemantics(
                  excluding: index != widget.currentIndex,
                  child: child,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AppIndexedPageMotionScope extends InheritedWidget {
  const AppIndexedPageMotionScope({
    required this.activation,
    required this.startAnimation,
    required super.child,
    super.key,
  });

  final int activation;
  final bool startAnimation;

  static AppIndexedPageMotionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppIndexedPageMotionScope>();

  @override
  bool updateShouldNotify(AppIndexedPageMotionScope oldWidget) =>
      activation != oldWidget.activation ||
      startAnimation != oldWidget.startAnimation;
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
    this.startDelay = Duration.zero,
    this.restartDelay = Duration.zero,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  /// Change this value when already-mounted content should replay its entrance.
  final Object? replayKey;
  final bool startAnimation;
  final Duration startDelay;
  final Duration restartDelay;

  @override
  State<AppStaggeredColumn> createState() => _AppStaggeredColumnState();
}

class _AppStaggeredColumnState extends State<AppStaggeredColumn>
    with SingleTickerProviderStateMixin {
  late Duration _activeDelay = widget.startDelay;
  late final AnimationController _controller = AnimationController(
    duration: _durationFor(_activeDelay),
    vsync: this,
  );
  bool _started = false;
  bool _animationsDisabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool animationsDisabled = MediaQuery.disableAnimationsOf(context);
    _animationsDisabled = animationsDisabled;
    if (animationsDisabled) {
      _started = true;
      _controller.value = 1;
    } else if (widget.startAnimation && !_started) {
      _startEntrance(widget.startDelay);
    }
  }

  @override
  void didUpdateWidget(AppStaggeredColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool shouldReplay =
        oldWidget.replayKey != widget.replayKey ||
        oldWidget.children.length != widget.children.length;
    if (_animationsDisabled) {
      _started = true;
      _controller.value = 1;
      return;
    }
    if (oldWidget.startAnimation && !widget.startAnimation) {
      _started = false;
      _controller.value = 0;
      return;
    }
    if (!oldWidget.startAnimation && widget.startAnimation) {
      _startEntrance(widget.restartDelay);
      return;
    }
    if (!shouldReplay) {
      return;
    }
    if (widget.startAnimation) {
      _startEntrance(widget.restartDelay);
    } else {
      _started = false;
      _controller.value = 0;
    }
  }

  Duration _durationFor(Duration delay) =>
      delay + AppMotion.staggeredDuration(widget.children.length);

  void _startEntrance(Duration delay) {
    _started = true;
    _activeDelay = delay;
    _controller.duration = _durationFor(delay);
    _controller.forward(from: 0);
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
      final int startMilliseconds =
          _activeDelay.inMilliseconds +
          index * AppMotion.stagger.inMilliseconds;
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
      animatedChildren.add(_animatedChild(widget.children[index], animation));
    }

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: animatedChildren,
    );
  }

  Widget _animatedChild(Widget child, Animation<double> animation) {
    final Widget transition = AnimatedBuilder(
      animation: animation,
      child: child is Flexible ? child.child : child,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, AppMotion.entranceOffset * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
    return switch (child) {
      Expanded(:final Key? key, :final int flex) => Expanded(
        key: key,
        flex: flex,
        child: transition,
      ),
      Flexible(:final Key? key, :final int flex, :final FlexFit fit) =>
        Flexible(key: key, flex: flex, fit: fit, child: transition),
      _ => transition,
    };
  }
}

class AppPageStaggeredColumn extends StatelessWidget {
  const AppPageStaggeredColumn({
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
      startFraction: AppMotion.pageContentStartFraction,
      deferInitialReadiness: true,
      spacing: spacing,
      crossAxisAlignment: crossAxisAlignment,
      replayKey: replayKey,
      children: children,
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
      deferInitialReadiness: false,
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
      deferInitialReadiness: false,
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
    required this.deferInitialReadiness,
    required this.children,
    required this.spacing,
    required this.crossAxisAlignment,
    required this.replayKey,
  });

  final double startFraction;
  final bool deferInitialReadiness;
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
  bool _readinessEnabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Animation<double>? routeAnimation = ModalRoute.of(context)?.animation;
    if (identical(routeAnimation, _routeAnimation)) {
      return;
    }
    _routeAnimation?.removeListener(_handleRouteAnimation);
    _routeAnimation = routeAnimation;
    _routeAnimation?.addListener(_handleRouteAnimation);
    _readinessEnabled = !widget.deferInitialReadiness;
    if (_readinessEnabled) {
      _startContentAnimation = _routeIsReady;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(_routeAnimation, routeAnimation)) {
        return;
      }
      _readinessEnabled = true;
      if (!_startContentAnimation && _routeIsReady) {
        setState(() => _startContentAnimation = true);
      }
    });
  }

  bool get _routeIsReady =>
      _routeAnimation == null || _routeAnimation!.value >= widget.startFraction;

  void _handleRouteAnimation() {
    if (!_readinessEnabled ||
        _startContentAnimation ||
        !_routeIsReady ||
        !mounted) {
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
