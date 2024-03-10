import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserInfoScreen(),
    );
  }
}

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();

  String _name = "";
  String _designation = "";

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatGPT App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name:',
              ),
              onChanged: (value) => setState(() => _name = value),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _designationController,
              decoration: InputDecoration(
                labelText: 'Job Designation:',
              ),
              onChanged: (value) => setState(() => _designation = value),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(name: _name, designation: _designation),
                ),
              ),
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String name;
  final String designation;

  const ChatScreen({Key? key, required this.name, required this.designation}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _questionController = TextEditingController();
  String _response = "";

  Future<void> _askChatGPT() async {
    String question = _questionController.text;
    if (question.isEmpty) return;

    String formulatedQuery = "Tell me $question. Answer it for the role of ${widget.designation}. Give the precise answer with an explainable example";

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions'); 
    final response = await http.post(
      uri,
      headers: {
        'Authorization': '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', 
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo', 
        'prompt': formulatedQuery,
        'max_tokens': 1024, 
        'temperature': 0.7, 
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _response = data['choices'][0]['text'].trim();
      });
    } else {
      // Handle API errors
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ask ChatGPT'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Ask a question:',
              ),
              maxLines: null, 
            ),
            SizedBox(height: 10.0),
                        ElevatedButton(
              onPressed: _askChatGPT,
              child: Text('Ask ChatGPT'),
            ),
            SizedBox(height: 20.0),
            Text(
              _response,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
