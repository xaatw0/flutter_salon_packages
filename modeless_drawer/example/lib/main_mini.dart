import 'package:flutter/material.dart';
import 'package:modeless_drawer/modeless_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const MyHomePage(title: 'ModelessDrawer Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _kerDrawer = GlobalKey<ModelessDrawerState<String>>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final value in ['One', 'Two', 'Three'])
                TextButton(
                  onPressed: () {
                    _kerDrawer.currentState?.changeValue(value);
                    _kerDrawer.currentState?.open();
                  },
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
            ],
          ),
        ),
        ModelessDrawer<String>(
            key: _kerDrawer,
            builder: (BuildContext context, String? selectedValue) =>
                Text(selectedValue ?? 'Not selected')),
      ],
    );
  }
}
