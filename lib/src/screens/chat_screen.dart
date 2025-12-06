import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String rideId;
  const ChatScreen({super.key, required this.rideId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await FirebaseFirestore.instance.collection('rides').doc(widget.rideId).collection('messages').add({
      'senderId': 'demo-user',
      'text': text,
      'createdAt': DateTime.now().toUtc(),
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesStream = FirebaseFirestore.instance.collection('rides').doc(widget.rideId).collection('messages').orderBy('createdAt', descending: true).snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    return ListTile(
                      title: Text(d['text'] ?? ''),
                      subtitle: Text(d['senderId'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _controller)),
                  IconButton(onPressed: _send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
