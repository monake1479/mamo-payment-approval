import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/app/theme/app_motion.dart';

void main() {
  testWidgets('items enter from below in a staggered sequence', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStaggeredColumn(
            children: <Widget>[Text('First'), Text('Second'), Text('Third')],
          ),
        ),
      ),
    );

    List<Opacity> opacityWidgets() => tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(AppStaggeredColumn),
            matching: find.byType(Opacity),
          ),
        )
        .toList(growable: false);

    expect(
      opacityWidgets().map((Opacity item) => item.opacity),
      everyElement(0),
    );

    await tester.pump(const Duration(milliseconds: 80));
    final List<Opacity> entering = opacityWidgets();
    expect(entering[0].opacity, greaterThan(entering[1].opacity));
    expect(entering[1].opacity, greaterThanOrEqualTo(entering[2].opacity));

    await tester.pump(AppMotion.staggeredDuration(3));
    expect(
      opacityWidgets().map((Opacity item) => item.opacity),
      everyElement(1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion presents final content immediately', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: AppStaggeredColumn(
              startDelay: AppMotion.fast,
              children: <Widget>[Text('First'), Text('Second')],
            ),
          ),
        ),
      ),
    );

    final Iterable<Opacity> opacityWidgets = tester.widgetList<Opacity>(
      find.descendant(
        of: find.byType(AppStaggeredColumn),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacityWidgets.map((Opacity item) => item.opacity), everyElement(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('staggered content waits for an explicit entrance gate', (
    WidgetTester tester,
  ) async {
    late StateSetter updateState;
    bool startAnimation = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              updateState = setState;
              return AppStaggeredColumn(
                startAnimation: startAnimation,
                children: const <Widget>[Text('First'), Text('Second')],
              );
            },
          ),
        ),
      ),
    );

    Iterable<double> opacityValues() => tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(AppStaggeredColumn),
            matching: find.byType(Opacity),
          ),
        )
        .map((Opacity item) => item.opacity);

    await tester.pump(AppMotion.staggeredDuration(2));
    expect(opacityValues(), everyElement(0));

    updateState(() => startAnimation = true);
    await tester.pump();
    expect(opacityValues(), everyElement(0));
    await tester.pump(AppMotion.staggeredDuration(2));
    expect(opacityValues(), everyElement(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('staggered content waits for its configured entrance delay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStaggeredColumn(
            startDelay: AppMotion.fast,
            children: <Widget>[Text('First'), Text('Second')],
          ),
        ),
      ),
    );

    expect(_staggeredOpacityValues(tester), everyElement(0));
    await tester.pump(AppMotion.fast - const Duration(milliseconds: 1));
    expect(_staggeredOpacityValues(tester), everyElement(0));

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 80));
    final List<double> entering = _staggeredOpacityValues(tester)
        .toList(growable: false);
    expect(entering.first, greaterThan(0));
    expect(entering.first, greaterThan(entering.last));
    expect(tester.takeException(), isNull);
  });

  testWidgets('staggered columns preserve flexible children', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStaggeredColumn(
            children: <Widget>[
              Text('Heading'),
              Expanded(child: Text('Flexible content')),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Flexible content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('page content waits until its pushed route is visible', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () {
              Navigator.of(context).push<void>(
                PageRouteBuilder<void>(
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder:
                      (
                        BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                      ) => const Scaffold(
                        body: AppPageStaggeredColumn(
                          children: <Widget>[
                            Text('Detail summary'),
                            Text('Detail fields'),
                          ],
                        ),
                      ),
                ),
              );
            },
            child: const Text('Open details'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 240));
    expect(_staggeredOpacityValues(tester), everyElement(0));

    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump(const Duration(milliseconds: 80));
    expect(_staggeredOpacityValues(tester), everyElement(greaterThan(0)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dialog content waits until its route is visible', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                showGeneralDialog<void>(
                  context: context,
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder:
                      (
                        BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                      ) {
                        return const Dialog(
                          child: AppDialogStaggeredColumn(
                            children: <Widget>[
                              Text('Dialog content'),
                              Text('Dialog action'),
                            ],
                          ),
                        );
                      },
                );
              },
              child: const Text('Open dialog'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    expect(_staggeredOpacityValues(tester), everyElement(0));

    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump(const Duration(milliseconds: 80));
    expect(_staggeredOpacityValues(tester), everyElement(greaterThan(0)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom-sheet content waits until its route is visible', (
    WidgetTester tester,
  ) async {
    final AnimationController routeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
      vsync: tester,
    );
    late BuildContext hostContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            hostContext = context;
            return TextButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  transitionAnimationController: routeController,
                  builder: (BuildContext context) {
                    return const AppBottomSheetStaggeredColumn(
                      children: <Widget>[
                        Text('Bottom-sheet content'),
                        Text('Bottom-sheet action'),
                      ],
                    );
                  },
                );
              },
              child: const Text('Open bottom sheet'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open bottom sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 240));
    expect(_staggeredOpacityValues(tester), everyElement(0));

    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump(const Duration(milliseconds: 80));
    expect(_staggeredOpacityValues(tester), everyElement(greaterThan(0)));
    expect(tester.takeException(), isNull);
    Navigator.of(hostContext).pop();
    await tester.pumpAndSettle();
    routeController.dispose();
  });

  testWidgets('page switcher animates programmatic destination changes', (
    WidgetTester tester,
  ) async {
    late StateSetter updateState;
    int page = 0;
    int completedTransitions = 0;
    int startedTransitions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            updateState = setState;
            return AppPageTransitionSwitcher(
              currentIndex: page,
              onPageChanged: (int index) => updateState(() => page = index),
              onTransitionStarted: (int index) => startedTransitions += 1,
              onTransitionCompleted: (int index) => completedTransitions += 1,
              children: const <Widget>[
                SizedBox.expand(child: Text('Page 0')),
                SizedBox.expand(child: Text('Page 1')),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Page 0').hitTestable(), findsOneWidget);

    updateState(() => page = 1);
    await tester.pump();
    await tester.pump(AppMotion.standard ~/ 2);
    final double outgoingX = tester
        .getTopLeft(find.text('Page 0', skipOffstage: false))
        .dx;
    final double incomingX = tester
        .getTopLeft(find.text('Page 1', skipOffstage: false))
        .dx;
    expect(outgoingX, lessThan(0));
    expect(incomingX, greaterThan(0));
    expect(
      incomingX - outgoingX,
      closeTo(tester.view.physicalSize.width / tester.view.devicePixelRatio, 1),
    );
    expect(
      find.ancestor(
        of: find.text('Page 0', skipOffstage: false),
        matching: find.byType(ColoredBox),
      ),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.ancestor(
        of: find.text('Page 1', skipOffstage: false),
        matching: find.byType(ColoredBox),
      ),
      findsAtLeastNWidgets(1),
    );

    await tester.pump(
      AppMotion.standard ~/ 2 + const Duration(milliseconds: 1),
    );
    expect(find.text('Page 1').hitTestable(), findsOneWidget);
    expect(startedTransitions, 1);
    expect(completedTransitions, greaterThanOrEqualTo(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('page switcher completes immediately with reduced motion', (
    WidgetTester tester,
  ) async {
    late StateSetter updateState;
    int page = 0;
    int completedTransitions = 0;
    int startedTransitions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              updateState = setState;
              return AppPageTransitionSwitcher(
                currentIndex: page,
                onPageChanged: (int index) => updateState(() => page = index),
                onTransitionStarted: (int index) => startedTransitions += 1,
                onTransitionCompleted: (int index) => completedTransitions += 1,
                children: const <Widget>[
                  SizedBox.expand(child: Text('Page 0')),
                  SizedBox.expand(child: Text('Page 1')),
                ],
              );
            },
          ),
        ),
      ),
    );

    updateState(() => page = 1);
    await tester.pump();
    await tester.pump();

    expect(find.text('Page 1').hitTestable(), findsOneWidget);
    expect(startedTransitions, 1);
    expect(completedTransitions, greaterThanOrEqualTo(1));
    expect(tester.takeException(), isNull);
  });
}

Iterable<double> _staggeredOpacityValues(WidgetTester tester) => tester
    .widgetList<Opacity>(
      find.descendant(
        of: find.byType(AppStaggeredColumn),
        matching: find.byType(Opacity),
      ),
    )
    .map((Opacity item) => item.opacity);
