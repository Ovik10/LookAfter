import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:look/reusable_widgets/my_drawer.dart';
import 'package:look/screens/add_contact.dart';
import 'package:look/screens/chat_screen.dart';
import 'package:look/screens/map.dart';
import 'package:look/screens/profile_change.dart';
import 'package:look/screens/profile_detail.dart';
import 'package:look/screens/profile_detail_diff.dart';
import 'package:look/screens/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    getContactList();
    getChatList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getContactList();
    getChatList();
  }

  void navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void navigateToProfile() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfileDetail(
                auth: FirebaseAuth.instance,
                storage: FirebaseStorage.instance,
              )),
    );
  }

  void logoutUser() {
    FirebaseAuth.instance.signOut().then((value) {
      print("Signed Out");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    }).onError((error, stackTrace) {
      print("Error ${error.toString()}");
    });
  }

  List<Object> _contactList = [];
  List<String> _chatList = [];

  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Look After',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.5,
          ),
        ),
      ),
      drawer: MyDrawer(
        onHomeTap: navigateToHome,
        onProfileTap: navigateToProfile,
        onLogoutTap: logoutUser,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.05, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Map',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Divider(
                  color: Colors.white,
                  thickness: 2.0,
                ),
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    child: Text(
                      'Show Map',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapSample()),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Contacts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Divider(
                  color: Colors.white,
                  thickness: 2.0,
                ),
                if (_contactList.isEmpty)
                  Text(
                    'You have no contacts yet.',
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontStyle: FontStyle.italic, // Add italic style
                    ),
                  )
                else
                  ListView(
  shrinkWrap: true,
  children: _contactList.map((contact) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 22, 22, 22),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: FutureBuilder<String>(
              future: getProfileImageUrl(contact.toString()),
              builder: (BuildContext context,
                  AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState ==
                        ConnectionState.done &&
                    snapshot.hasData) {
                  return CircleAvatar(
                    backgroundImage: NetworkImage(
                        snapshot.data!), // Use the fetched URL
                    radius: 20, // Adjust the radius as needed
                  );
                } else {
                  return CircleAvatar(
                    backgroundColor: Colors
                        .white, // Placeholder background color while loading
                    radius: 20,
                  );
                }
              },
            ),
            title: FutureBuilder<String>(
              future: getUserName(contact.toString()),
              builder: (BuildContext context,
                  AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.done) {
                  print(contact.toString());
                  return Text(
                    snapshot.data ?? 'Unknown user',
                    style: TextStyle(
                      color: Colors.white, // Text color
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileDetailDiff(
                      userId: contact.toString()),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }).toList(),
),
                Container(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    child: Text(
                      'Add Contact',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddContact()),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Chats',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white, // Text color
                    letterSpacing: 1.2, // Adjust the letter spacing as needed
                  ),
                ),
                Divider(
                  // Add a white divider
                  color: Colors.white,
                  thickness: 2.0,
                ),
                if (_chatList.isEmpty)
                  Text(
                    'You have no chats yet.',
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontStyle: FontStyle.italic, // Add italic style
                    ),
                  )
                else
                  ListView(
  shrinkWrap: true,
  children: _chatList.map((chat) {
    return FutureBuilder<Map<String, String>>(
      future: _getChatParticipants(chat),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          final user1 = snapshot.data!['user1'];
          final user2 = snapshot.data!['user2'];
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 22, 22, 22),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.white, // White circle background
                    radius: 6, // Adjust the radius as needed
                  ),
                  title: Text(
                    '$user1 and $user2',
                    style: TextStyle(
                      color: Colors.white, // Text color
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatScreen(chatId: chat),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
            ],
          );
        } else {
          return Container(); // Placeholder for empty chat
        }
      },
    );
  }).toList(),
),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getProfileImageUrl(String userId) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
    try {
      final url = await storageRef.getDownloadURL();
      return url;
    } catch (e) {
      print('Error fetching profile image URL: $e');
      return '';
    }
  }

  Future<Map<String, String>> _getChatParticipants(String chatId) async {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

    final user1 = docSnapshot.data()?['name1'] ?? 'Unknown';
    final user2 = docSnapshot.data()?['name2'] ?? 'Unknown';

    return {'user1': user1, 'user2': user2};
  }

  Future<void> getContactList() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userDocRef.get();
    final contacts = List<String>.from(snapshot.get('contacts'));
    print(contacts);
    setState(() {
      _contactList = contacts;
    });
  }

  Future<void> getChatList() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    final userChatsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chats')
        .get();

    final List<String> chatIds =
        userChatsSnapshot.docs.map((doc) => doc.id).toList();

    setState(() {
      _chatList = chatIds;
    });
  }

  Future<String> getUserName(String aUserId) async {
    final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
    ).ref();
    final auserId = aUserId;
    final userRef = databaseRef.child('users/$auserId');
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
}
