import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ollama_talk/objectbox.g.dart';
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
      final fileNames = ['坂本龍馬.txt'];
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

  void test() {
    getApplicationDocumentsDirectory().then((dir) async {
      final directory = Directory('${dir.path}/object_box_test');
      if (directory.existsSync()) {
        directory.delete(recursive: true);
      }

      final store = await openStore(directory: directory.path);
      final chat = store.box<ChatEntity>();

      final chat1 = ChatEntity(title: 'title1', llmModel: 'model1');
      final chat2 = ChatEntity(title: 'title2', llmModel: 'model1');
      chat.putMany([chat1, chat2]);

      store.box<ChatMessageEntity>().putMany([
        ChatMessageEntity(dateTime: DateTime.now(), message: 'message1-1')
          ..chat.target = chat1,
        ChatMessageEntity(dateTime: DateTime.now(), message: 'message1-2')
          ..chat.target = chat1,
        ChatMessageEntity(dateTime: DateTime.now(), message: 'message2-1')
          ..chat.target = chat2,
      ]);
      final orderQuery2 = store.box<ChatMessageEntity>().query()
        ..link(ChatMessageEntity_.chat, ChatEntity_.id.equals(chat1.id));
      print('result:' + orderQuery2.build().find().length.toString());

      directory.delete();
    });
  }
}
