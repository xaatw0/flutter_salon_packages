import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_client/ollama_talk_client.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ollama_talk Demo'),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final infraInfo = InfraInfo(http.Client(), '192.168.1.33:8080');
  static const systemMessage = '日本語で答えて';

  late final _chatList = Completer<List<ChatModel>>();
  late final _llmModels = Completer<List<LlmModel>>();

  LlmModel? _selectedModel;
  final _messageController = TextEditingController(text: '坂本龍馬は誰ですか');

  var _waitingResponse = false;
  String _responseMessage = '';

  int? _chatId;

  ChatModel? _currentChat;

  late final _chatApi = ChatApi(infraInfo);

  @override
  void initState() {
    super.initState();

    ModelApi(infraInfo).loadLlmModelList().then((data) {
      _llmModels.complete(data);
    });

    _chatApi.loadChatList().then((data) {
      _chatList.complete(data);
      _scaffoldKey.currentState?.openDrawer();
    });
  }

  Future<void> _loadChatMessage(int chatId) async {
    final loadedChat = await _chatApi.loadChat(chatId);

    final model = (await _llmModels.future)
        .where((e) => e() == loadedChat.llmModel)
        .firstOrNull;

    setState(() {
      _chatId = chatId;
      _currentChat = loadedChat;
      _selectedModel = model;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: FutureBuilder(
            future: _chatList.future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final chatList = snapshot.data!;

              return ListView(
                children: <Widget>[
                  ListTile(
                    title: const Text('新しい会話を始める'),
                    onTap: () {
                      _selectNewChat();
                      Navigator.pop(context);
                    },
                  ),
                  for (final chat in chatList)
                    ListTile(
                      title: Text(chat.title),
                      onTap: () {
                        _selectChat(chat);
                        Navigator.pop(context);
                      },
                    ),
                ],
              );
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
                future: _llmModels.future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return Row(
                    children: [
                      const Text('LLMモデル'),
                      const SizedBox(width: 16),
                      DropdownButton<LlmModel>(
                        value: _selectedModel,
                        onChanged: _canChangeLlmModel()
                            ? (newValue) {
                                setState(() {
                                  _selectedModel = newValue;
                                });
                              }
                            : null,
                        items: snapshot.data!.map((value) {
                          return DropdownMenuItem(
                              value: value, child: Text(value()));
                        }).toList(),
                      ),
                    ],
                  );
                }),
            Expanded(
                child: ListView.builder(
                    itemCount: (_currentChat?.messages.length ?? 0) * 2,
                    itemBuilder: (context, index) {
                      final isMessage = (index % 2 == 0);
                      final message =
                          _currentChat!.messages[(index / 2).floor()];
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            if (isMessage) const SizedBox(width: 32),
                            Flexible(
                                child: Align(
                              alignment: isMessage
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Text(isMessage
                                  ? message.message
                                  : message.response),
                            )),
                            if (!isMessage) const SizedBox(width: 32),
                          ],
                        ),
                      );
                    })),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                  ),
                ),
                FilledButton(
                  onPressed: _selectedModel == null || _waitingResponse
                      ? null
                      : sendMessage,
                  child: _waitingResponse
                      ? const Text('送信中...')
                      : const Text('送信'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage() async {
    final message = ChatMessageModel(
        dateTime: DateTime.now(),
        message: _messageController.text,
        response: '');
    _chatId ??= await _openNewChat();
    setState(() {
      _responseMessage = '';
      _waitingResponse = true;
      _currentChat!.messages.add(message);
    });

    final chatApi = ChatApi(infraInfo);
    await for (final responsePart in chatApi.sendMessage(
      _chatId!,
      _messageController.text,
    )) {
      _responseMessage += responsePart;
      _currentChat!.messages.removeLast();

      setState(() {
        _currentChat!.messages.add(message.withResponse(_responseMessage));
      });
    }

    setState(() {
      _waitingResponse = false;
    });
  }

  bool _canChangeLlmModel() {
    return _currentChat?.messages.isEmpty ?? true;
  }

  Future<int> _openNewChat() async {
    final chatId = await _chatApi.openChat(_selectedModel!, systemMessage);
    _currentChat = ChatModel(
        id: chatId,
        title: 'No title',
        llmModel: _selectedModel!(),
        system: systemMessage,
        messages: []);
    return chatId;
  }

  Future<void> _selectChat(ChatModel chat) async {
    final model =
        (await (_llmModels.future)).firstWhere((e) => e() == chat.llmModel);

    _loadChatMessage(chat.id);

    setState(() {
      _currentChat = chat;
      _selectedModel = model;
    });
  }

  Future<void> _selectNewChat() async {
    setState(() {
      _currentChat = null;
      _selectedModel = null;
    });
  }
}
