import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:look/screens/home_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<String> participantNames;

  @override
  void initState() {
    super.initState();
    _getChatParticipants().then((participants) {
      setState(() {
        _appBarTitle = participants;
      });
    });
  }

  Future<String> _getChatParticipants() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();

    final user1 = docSnapshot.data()?['name1'] ?? 'Unknown';
    final user2 = docSnapshot.data()?['name2'] ?? 'Unknown';

    return '$user1 and $user2';
  }

  String _appBarTitle = '';
  @override
  Widget build(BuildContext context) {
    TextEditingController _messageController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitle,
          style: TextStyle(fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Theme(
                    data: ThemeData(
                      brightness: Brightness.light,
                      backgroundColor: Colors.white,
                      textTheme: TextTheme(
                        bodyText1: TextStyle(color: Colors.black),
                        bodyText2: TextStyle(color: Colors.black),
                      ),
                    ),
                    child: AlertDialog(
                      title: Text('Delete Chat',
                          style: TextStyle(color: Colors.black)),
                      content: Text(
                          'Are you sure you want to delete this chat?',
                          style: TextStyle(color: Colors.black)),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel',
                              style: TextStyle(color: Colors.black)),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteChat();
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                            );
                          },
                          child: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
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
  Map<String, dynamic> messageData = messageDocs[index].data() as Map<String, dynamic>;
  bool isCurrentUser = messageData['senderId'] == FirebaseAuth.instance.currentUser!.displayName;

                    return Padding(
  padding: EdgeInsets.fromLTRB(
    isCurrentUser ? MediaQuery.of(context).size.width * 0.3 : 8.0,
    4.0,
    isCurrentUser ? 8.0 : MediaQuery.of(context).size.width * 0.3,
    4.0,
  ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrentUser ? const Color.fromARGB(255, 211, 211, 211) : Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            messageData['text'],
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              messageData['senderId'] ?? 'Unknown',
                              style: TextStyle(
                                color: Color.fromARGB(255, 83, 83, 83),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.black),
                    onPressed: () {
                      _sendMessage(_messageController.text.trim());
                      _messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void deleteChat() async {
    try {
      DocumentReference chatRef =
          FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
      await chatRef.delete();
      QuerySnapshot messagesSnapshot =
          await chatRef.collection('messages').get();
      for (DocumentSnapshot messageDoc in messagesSnapshot.docs) {
        await messageDoc.reference.delete();
      }
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        DocumentReference userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('chats')
            .doc(widget.chatId);
        await userRef.delete();
      }
    } catch (error) {
      print('Error deleting chat: $error');
    }
  }

  Future<String> getUserName(String senderId) async {
    final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
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
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': message,
        'senderId': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
