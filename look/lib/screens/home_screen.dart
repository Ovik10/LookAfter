
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:look/reusable_widgets/my_drawer.dart';
import 'package:look/screens/add_contact.dart';
import 'package:look/screens/chat_screen';
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
                MaterialPageRoute(builder: (context) => ProfileDetail(auth: FirebaseAuth.instance,
  storage: FirebaseStorage.instance)),
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
        title: Text('Look After'),
      ),
      drawer: MyDrawer(
        onHomeTap: navigateToHome,
        onProfileTap: navigateToProfile,
        onLogoutTap: logoutUser,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.05, 20, 0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Map',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24, 
                ),),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Show Map'),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapSample()),
              );
            },
          ), 
          SizedBox(height: 20),
           Text('Contacts',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24, 
                ),),
                if (_contactList.isEmpty)
                  Text('You have no contacts yet.')
                else
                  ListView(
  shrinkWrap: true,
  children: _contactList.map((contact) {
    return ListTile(
  title: FutureBuilder<String>(
    future: getUserName(contact.toString()),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        print(contact.toString());
        return Text(snapshot.data ?? 'Unknown user');
      } else {
        
        return CircularProgressIndicator();
      }
    },
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailDiff(userId: contact.toString()),
        
      ),
    );
  },
);
  }).toList(),
)
                  ,
                ElevatedButton(
            child: Text('Add Contact'),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddContact()),
              );
            },
          ),
               SizedBox(height: 20),
                Text(
                  'Chats',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                if (_chatList.isEmpty)
                  Text('You have no chats yet.')
                else
                  ListView(
                    shrinkWrap: true,
                    children: _chatList.map((chat) {
                      return ListTile(
                        title: Text('Chat: $chat'), // Display chat information
                        onTap: () {
                          Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(chatId: chat)),
              );
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
Future<void> getContactList() async {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
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

  final List<String> chatIds = userChatsSnapshot.docs.map((doc) => doc.id).toList();

setState(() {
      _chatList = chatIds;
    });
}
Future<String> getUserName(String aUserId) async {
final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
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