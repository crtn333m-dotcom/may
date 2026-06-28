import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('اختر شخص للمحادثة')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs.where((doc) => doc.id != currentUid).toList();
          if (users.isEmpty) {
            return const Center(child: Text('لا يوجد مستخدمون آخرون بعد'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final otherUid = users[index].id;
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['name'] ?? 'بدون اسم'),
                subtitle: Text(data['email'] ?? ''),
                onTap: () {
                  final chatId = _getChatId(currentUid, otherUid);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chatId,
                        otherUserName: data['name'] ?? 'بدون اسم',
                        otherUid: otherUid,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _getChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }
}
