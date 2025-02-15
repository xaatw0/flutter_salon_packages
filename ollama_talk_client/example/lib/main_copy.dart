import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const RefreshListView(),
    );
  }
}

class MockRepository {
  int counterPlus = 0;
  int counterMinus = -1;

  Future<List<String>> fetchOldData() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(10, (_) => (counterPlus++).toString());
  }

  Future<List<String>> fetchNewData() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(3, (_) => (counterMinus--).toString());
  }
}

class RefreshListView extends StatefulWidget {
  const RefreshListView({super.key});

  @override
  State<RefreshListView> createState() => _RefreshListViewState();
}

class _RefreshListViewState extends State<RefreshListView> {
  var _data = <String>[];
  var _isLoadingNewData = false;
  var _isLoadingOldData = false;
  bool get _isLoading => _isLoadingOldData || _isLoadingNewData;

  final _repository = MockRepository();

  @override
  void initState() {
    super.initState();

    _fetchOldData();
  }

  Future<void> _fetchOldData() async {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoadingOldData = true;
    });

    _repository.fetchOldData().then((data) {
      setState(() {
        _data = [..._data, ...data];
        _isLoadingOldData = false;
      });
    });
  }

  Future<void> _fetchNewData() async {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoadingNewData = true;
    });

    _repository.fetchNewData().then((data) {
      setState(() {
        _data = [...data.reversed, ..._data];
        _isLoadingNewData = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final dataLength = data.length;
    return RefreshIndicator(
      onRefresh: _fetchNewData,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (ScrollEndNotification notification) {
          final isScrollToEnd = notification.metrics.extentAfter == 0;

          if (isScrollToEnd) {
            _fetchOldData();
          }
          return isScrollToEnd;
        },
        child: ListView.builder(
          itemCount: dataLength + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if ((index == 0 && _isLoadingNewData) ||
                (index == dataLength && _isLoadingOldData)) {
              return const CircularProgressIndicator();
            }
            final currentIndex = (_isLoadingNewData ? 1 : 0) + index;
            return ListTile(title: Text(_data[currentIndex]));
          },
        ),
      ),
    );
  }
}
