# modeless_drawer
This package provides a modeless dialog that can be displayed on top of the stack. By positioning it at the top of the stack, it achieves a modeless dialog that appears at the right edge of the screen. The modeless dialog supports manual and programmatic opening and closing of the drawer, as well as updating the values displayed within the dialog.

## Motivation

In Flutter, there are several types of drawers, including the native drawer and many customized drawers. Typically, the fundamental behavior of a drawer is to close when the user taps outside of it. However, in applications like Figma, where users need to view properties of selected items, the content within the drawer updates with each selection. Closing and reopening the drawer every time a new item is selected is inefficient and negatively impacts the user interface and experience.

Recognizing this inefficiency and the absence of an appropriate solution, ModelessDrawer was developed. This drawer has two main features:

1. **Modeless Behavior**: The drawer does not close when tapping outside of it, allowing for uninterrupted workflow.
2. **Dynamic Content Update**: The drawer content updates based on the selected widget's data, providing a seamless user experience.

These features address the need for a more efficient and user-friendly drawer in scenarios where frequent updates to the drawer content are necessary.

## Screenshot
https://github.com/user-attachments/assets/3f89059a-1979-49dd-8df9-521b0be4c9dc


## Usage
Here are small examples that show you how to use the API.

### Install
```dart
import 'package:modeless_drawer/modeless_drawer.dart';
```

### Setting the GlobalKey
First, set a `GlobalKey` for the `ModelessDrawer` to control its state. This key is necessary for programmatically opening, closing, and updating the drawer.

```dart
final _kerDrawer = GlobalKey<ModelessDrawerState<CountryInfo>>();
```

### Placing the Drawer Behind the Stack
Place the `ModelessDrawer` at the top of the stack, so it appears above the rest of the content.

```dart
return Stack(
  children: [
    Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // Your other content here
    ),
    ModelessDrawer<CountryInfo>(
      key: _kerDrawer,
      builder: (BuildContext context, CountryInfo? country) => ...
    ),
  ],
);
```

### Opening the Drawer
To open the `ModelessDrawer`, call the `open()` method on its state using the `GlobalKey`.

```dart
_kerDrawer.currentState?.open();
```

### Closing the Drawer
To close the `ModelessDrawer`, call the `close()` method on its state using the `GlobalKey`.

```dart
_kerDrawer.currentState?.close();
```


### Passing Data to the Drawer
To pass data to the `ModelessDrawer`, use the `changeValue()` method on its state. This updates the drawer's content with the provided data.

```dart
_kerDrawer.currentState?.changeValue(country);
```

### Setting the Drawer Content
The content of the `ModelessDrawer` is set using the `builder` parameter. This parameter takes a function that returns a widget based on the passed data.

```dart
ModelessDrawer<CountryInfo>(
  key: _kerDrawer,
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
)
```

### Showing/ Hiding the Drawer When Closed
To show or hide the drawer when it is closed, use the `widthWhenClose` parameter. If `widthWhenClose` is set to 0 (default), the drawer will be hidden when closed.

```dart
ModelessDrawer<CountryInfo>(
  widthWhenClose: _showWhenClosed ? 32 : 0,
)
```

### Simple Example
```dart
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

```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
This project is licensed under the [MIT](https://github.com/xaatw0/flutter_salon_packages/blob/modeless_drawer/modeless_drawer/LICENSE) License.
