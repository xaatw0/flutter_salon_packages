import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ollama_talk/ollama_talk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final OllamaTalkClient _ollamaClient;

  final _loadCompleted = Completer();

  // 表示用のメッセージ一覧
  List<Map<String, String>> chatHistories = [];

  String _responseMessage = '';

  final _messageController = TextEditingController(text: '坂本龍馬は誰ですか');

  var _waitingResponse = false;

  late final ChatEntity _chat;

  @override
  void initState() {
    super.initState();

    getApplicationDocumentsDirectory().then((dir) async {
      final directory = Directory('${dir.path}/object_box_data');
      if (directory.existsSync()) {
//        return;
        directory.delete(recursive: true);
      }

      final store = await openStore(directory: directory.path);

      _ollamaClient = OllamaTalkClient(
        http.Client(),
        'http://192.168.1.33:5050/api',
        store,
      );

      _chat = _ollamaClient.openChat(
        const LlmModel('elyza:jp8b'),
        'あなたは幕末の研究者です。語尾に「なり」「ござる」を付けてください',
      );

      _loadCompleted.complete();

      store.box<DocumentEmbeddingEntity>().removeAll();
      final fileNames = ['坂本龍馬_original.txt', '武市瑞山.txt'];
      for (final fileName in fileNames) {
        final fileData = rootBundle.loadString('assets/$fileName');

        _ollamaClient.insertDocument(fileName, await fileData, 'memo');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
                onPressed: () async {
                  final models = await _ollamaClient.loadLocalModels();
                  for (var model in models) {
                    print(model.name +
                        'isEmbedding: ${model.isEmbeddingModel()}');
                  }
                },
                child: Text('モデル')),
            TextField(
              controller: _messageController,
            ),
            FilledButton(
              onPressed: _waitingResponse ? null : sendMessage,
              child: _waitingResponse ? const Text('送信中...') : const Text('送信'),
            ),
            FutureBuilder(
                future: _loadCompleted.future,
                builder: (context, snapshot) {
                  if (!_loadCompleted.isCompleted) {
                    return const CircularProgressIndicator();
                  }
                  return Expanded(
                      child: StreamBuilder<Query<ChatMessageEntity>>(
                    stream: _ollamaClient.watchMessages(_chat),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final entities = snapshot.data?.find() ?? [];
                      return ListView.builder(
                        itemCount: entities.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(entities[index].message),
                          subtitle:
                              Text(entities[index].response ?? 'waiting..'),
                        ),
                      );
                    },
                  ));
                })
          ],
        ),
      ),
    );
  }

  void sendMessage() async {
    setState(() {
      _responseMessage = '';
      _waitingResponse = true;
    });

    final prompt = _messageController.text;
    await for (final responsePart
        in _ollamaClient.chatAndWaitResponse(_chat, prompt)) {
      setState(() {
        _responseMessage += responsePart;
      });
    }
    setState(() {
      _waitingResponse = false;
    });
  }
}
