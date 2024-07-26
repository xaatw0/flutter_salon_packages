import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modeless_drawer/modeless_drawer.dart';

void main() {
  group('open close test', () {
    testWidgets('Drawer opens and closes correctly',
        (WidgetTester tester) async {
      final GlobalKey<ModelessDrawerState<String>> drawerKey =
          GlobalKey<ModelessDrawerState<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Text('Test'),
                ModelessDrawer<String>(
                  key: drawerKey,
                  widthWhenClose: 32,
                  builder: (context, value) => Text(value ?? 'No data'),
                ),
              ],
            ),
          ),
        ),
      );

      final ModelessDrawerState<String> drawerState =
          tester.state(find.byType(ModelessDrawer<String>));

      expect(drawerState.widget.width, 200);

      RenderBox drawerBox = tester.renderObject(find.byType(Drawer));
      expect(drawerBox.localToGlobal(Offset.zero).dx, 25);

      drawerState.open();
      await tester.pumpAndSettle();
      expect(drawerBox.localToGlobal(Offset.zero).dx, -175.0);

      drawerState.close();
      await tester.pumpAndSettle();
      expect(drawerBox.localToGlobal(Offset.zero).dx, 25);
    });

    testWidgets('Drawer opened initially', (WidgetTester tester) async {
      final GlobalKey<ModelessDrawerState<String>> drawerKey =
          GlobalKey<ModelessDrawerState<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Text('Test'),
                ModelessDrawer<String>(
                  key: drawerKey,
                  widthWhenClose: 32,
                  initiallyClosed: false,
                  builder: (context, value) => Text(value ?? 'No data'),
                ),
              ],
            ),
          ),
        ),
      );

      final ModelessDrawerState<String> drawerState =
          tester.state(find.byType(ModelessDrawer<String>));

      RenderBox drawerBox = tester.renderObject(find.byType(Drawer));
      expect(drawerBox.localToGlobal(Offset.zero).dx, -175.0);

      drawerState.close();
      await tester.pumpAndSettle();
      expect(drawerBox.localToGlobal(Offset.zero).dx, 25);
    });

    testWidgets('onToggleChange', (WidgetTester tester) async {
      final GlobalKey<ModelessDrawerState<String>> drawerKey =
          GlobalKey<ModelessDrawerState<String>>();

      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Text('Test'),
                ModelessDrawer<String>(
                  key: drawerKey,
                  onToggleChange: (value) {
                    result = value;
                  },
                  builder: (context, value) => Text(value ?? 'No data'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(result, isNull);

      drawerKey.currentState!.open();
      await tester.pumpAndSettle();
      expect(result, isFalse);

      drawerKey.currentState!.close();
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  });

  group('ModelessDrawer change Value', () {
    testWidgets('change value', (WidgetTester tester) async {
      final GlobalKey<ModelessDrawerState<String>> drawerKey =
          GlobalKey<ModelessDrawerState<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Column(
                  children: [
                    FilledButton(
                        onPressed: () =>
                            drawerKey.currentState!.changeValue('1'),
                        child: const Text('1')),
                    FilledButton(
                        onPressed: () =>
                            drawerKey.currentState!.changeValue('2'),
                        child: const Text('2')),
                    FilledButton(
                        onPressed: () =>
                            drawerKey.currentState!.changeValue(null),
                        child: const Text('NULL')),
                  ],
                ),
                ModelessDrawer<String>(
                  key: drawerKey,
                  builder: (context, value) => Text('Data: $value'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Data: null'), findsOneWidget);
      expect(find.text('Data: 1'), findsNothing);
      expect(find.text('Data: 2'), findsNothing);

      await tester.tap(find.text('1'));
      await tester.pump();
      expect(find.text('Data: null'), findsNothing);
      expect(find.text('Data: 1'), findsOneWidget);
      expect(find.text('Data: 2'), findsNothing);

      await tester.tap(find.text('2'));
      await tester.pump();
      expect(find.text('Data: null'), findsNothing);
      expect(find.text('Data: 1'), findsNothing);
      expect(find.text('Data: 2'), findsOneWidget);

      await tester.tap(find.text('NULL'));
      await tester.pump();
      expect(find.text('Data: null'), findsOneWidget);
      expect(find.text('Data: 1'), findsNothing);
      expect(find.text('Data: 2'), findsNothing);
    });
  });

  group('widthWhenClose default test', () {
    testWidgets('Drawer opens and closes correctly',
        (WidgetTester tester) async {
      final GlobalKey<ModelessDrawerState<String>> drawerKey =
          GlobalKey<ModelessDrawerState<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Text('Test'),
                ModelessDrawer<String>(
                  key: drawerKey,
                  builder: (context, value) => Text(value ?? 'No data'),
                ),
              ],
            ),
          ),
        ),
      );

      final ModelessDrawerState<String> drawerState =
          tester.state(find.byType(ModelessDrawer<String>));

      expect(drawerState.widget.width, 200);

      RenderBox drawerBox = tester.renderObject(find.byType(Drawer));
      expect(drawerBox.localToGlobal(Offset.zero).dx, 57);

      drawerState.open();
      await tester.pumpAndSettle();
      expect(drawerBox.localToGlobal(Offset.zero).dx, -143.0);

      drawerState.close();
      await tester.pumpAndSettle();
      expect(drawerBox.localToGlobal(Offset.zero).dx, 57);
    });
  });
}
