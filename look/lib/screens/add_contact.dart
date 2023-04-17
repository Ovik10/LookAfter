import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddContact extends StatefulWidget {
  const AddContact({Key? key}) : super(key: key);
  

  @override
  State<AddContact> createState() => _AddContactState();
}


class _AddContactState extends State<AddContact> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _errorMessage;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: _addContact,
                child: const Text('Add Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addContact() async {

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      try {
        final user = FirebaseAuth.instance.currentUser;
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        final contacts = List<String>.from(userSnapshot['contacts']);
        if (contacts.contains(email)) {
          setState(() {
            _errorMessage = 'Contact already added';
          });
        } else {
          final userQuerySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();
          if (userQuerySnapshot.docs.isEmpty) {
            setState(() {
              _errorMessage = 'User not found';
            });
          } else {
            final contactUid = userQuerySnapshot.docs.first.id;
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({
              'contacts': FieldValue.arrayUnion([contactUid]),
            });
            Navigator.pop(context);
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred';
        });
      }
    }
  }
}
