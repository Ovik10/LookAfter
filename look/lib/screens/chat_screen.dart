import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; 

class ChatScreen extends StatelessWidget {
  final String chatId;
  
  const ChatScreen({required this.chatId});

  @override
  Widget build(BuildContext context) {
    TextEditingController _messageController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> messageDocs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messageDocs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData =
                        messageDocs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                        messageData['text'],
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        messageData['senderId'] ?? 'Unknown',
                        style: TextStyle(color: const Color.fromARGB(255, 175, 175, 175)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    _sendMessage(_messageController.text.trim());
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getUserName(String senderId) async {
    final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
    ).ref();
    final userRef = databaseRef.child('users/$senderId');
    final dataSnapshot = await userRef.once().catchError((error) {
      print("Error retrieving data from Firebase: $error");
    });
    final userData = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
    if (userData != null) {
      final displayName = userData['username'];
      return displayName;
    } else {
      return "";
    }
  }

  void _sendMessage(String message) async {
    final userName = await getUserName(FirebaseAuth.instance.currentUser!.uid);
    if (message.isNotEmpty && userName.isNotEmpty) {
      FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
        'text': message,
        'senderId': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}