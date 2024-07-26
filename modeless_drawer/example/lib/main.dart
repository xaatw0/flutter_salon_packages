import 'package:flutter/material.dart';
import 'package:modeless_drawer/modeless_drawer.dart';

void main() {
  runApp(const MyApp());
}

class CountryInfo {
  const CountryInfo(this.code, this.name, this.capital);
  final String code;
  final String name;
  final String capital;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const MyHomePage(title: 'ModelessDrawer Demo Home Page'),
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
  final _countries = const [
    CountryInfo('JP', 'Japan', 'Tokyo'),
    CountryInfo('CA', 'Canada', 'Ottawa'),
    CountryInfo('US', 'United States of America', 'Washington'),
  ];

  final _kerDrawer = GlobalKey<ModelessDrawerState<CountryInfo>>();

  var _showWhenClosed = false;

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
              for (final country in _countries)
                TextButton(
                  onPressed: () {
                    _kerDrawer.currentState?.changeValue(country);
                    _kerDrawer.currentState?.open();
                  },
                  child: Text(
                    toFlag(country.code),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              FilledButton(
                onPressed: () {
                  _kerDrawer.currentState?.close().then((_) {
                    // Performed after Drawer closing animation is completed
                    _kerDrawer.currentState?.changeValue(null);
                  });
                },
                child: const Text('Initialize'),
              ),
              Row(
                children: [
                  const Text('Show the ModelessDrawer when closed'),
                  Checkbox(
                      value: _showWhenClosed,
                      onChanged: (value) =>
                          setState(() => _showWhenClosed = value ?? true))
                ],
              ),
            ],
          ),
        ),
        ModelessDrawer<CountryInfo>(
          key: _kerDrawer,
          widthWhenClose: _showWhenClosed ? 32 : 0,
          builder: (BuildContext context, CountryInfo? country) =>
              country == null
                  ? const Text('Not selected')
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          toFlag(country.code),
                          style: const TextStyle(fontSize: 64),
                        ),
                        Text(country.name),
                        Text('Capital: ${country.capital}'),
                      ],
                    ),
        ),
      ],
    );
  }

  String toFlag(String value) {
    final codes = value.codeUnits.map((e) => e + 127397);
    return String.fromCharCodes(codes.toList());
  }
}
