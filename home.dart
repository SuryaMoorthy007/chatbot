import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ChatUser> _typingUsers = <ChatUser>[];
  final Gemini _gemini = Gemini.instance;
  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: "Vishal", lastName: 'Kumar');
  final ChatUser _geminiUser =
      ChatUser(id: '2', firstName: 'Golden', lastName: 'MIC');
  List<ChatMessage> _messages = <ChatMessage>[];
  bool _isLoading = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user's message to the chat
    setState(() {
      _messages.insert(
        0,
        ChatMessage(user: _currentUser, text: text, createdAt: DateTime.now()),
      );
      _isLoading = true;
    });

    // Check if the message is related to medicine
    if (_isMedicineRelated(text)) {
      try {
        final response = await _gemini.chat([
          Content(parts: [Part.text(text)], role: 'user'),
        ]);

        if (response?.output != null) {
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                user: _geminiUser,
                text: response!.output ?? '',
                createdAt: DateTime.now(),
              ),
            );
          });
        }
      } catch (error) {
        print('Error occurred: $error');
      }
    } else {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            user: _geminiUser,
            text:
                "I'm sorry, but I can only respond to medicine-related queries.",
            createdAt: DateTime.now(),
          ),
        );
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  bool _isMedicineRelated(String text) {
    List<String> keywords = [
      'medicine',
      'drug',
      'pharmacy',
      'prescription',
      'doctor',
      'treatment',
      'tablet',
      'capsule',
      'pill',
      'dose',
      'infection',
      'symptoms'
    ];
    return keywords.any((keyword) => text.toLowerCase().contains(keyword));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Chat here",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: DashChat(
        messageOptions: const MessageOptions(
          currentUserContainerColor: Colors.blue,
          containerColor: Colors.blue,
          textColor: Colors.white,
        ),
        currentUser: _currentUser,
        onSend: (ChatMessage m) {
          _sendMessage(m.text);
        },
        messages: _messages,
        typingUsers: _typingUsers,
      ),
    );
  }
}
