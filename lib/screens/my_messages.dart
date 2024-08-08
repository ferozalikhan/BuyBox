// ****************************************************************************************************
// This file contains the MyMessagesScreen widget which displays the list of chats that the current user is a part of.
// The MyMessagesScreen widget uses the ChatScreen widget to display the chat messages.
// The MyMessagesScreen widget uses the Message class to display the messages.
// The MyMessagesScreen widget uses the FirebaseAuth and FirebaseFirestore classes to interact with Firebase.
// The MyMessagesScreen widget uses the StreamBuilder widget to listen for changes in the chat collection.
// The MyMessagesScreen widget uses the getUnreadMessageCountStream function to get the stream of unread messages.
// ****************************************************************************************************

import 'package:buybox/models/message.dart';
import 'package:buybox/screens/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyMessagesScreen extends StatefulWidget {
  @override
  State<MyMessagesScreen> createState() => _MyMessagesScreenState();
}

class _MyMessagesScreenState extends State<MyMessagesScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    // recheck the unread message count
    bool checkUnreadMessageCount = false;

    Future<int> getUnreadMessageCount(String chatId, String userId) async {
      final messages = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      int unreadCount = messages.docs
          .where((message) => !message['readBy'].contains(userId))
          .length;

      // update the unread message count
      checkUnreadMessageCount = false;
      return unreadCount;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser!.uid)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = chat['participants'];
              final otherUserId =
                  participants.firstWhere((id) => id != currentUser.uid);
              final lastMessage = chat['lastMessage'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chat.id,
                            sellerId: otherUserId,
                          ),
                        ),
                      );
                      // recheck the unread message count
                      setState(() {
                        checkUnreadMessageCount = true;
                      });
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(userData['image_url']),
                        ),
                        title: Text(
                          userData['username'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        subtitle: Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: StreamBuilder<int>(
                          stream: getUnreadMessageCountStream(
                              currentUser.uid ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            final unreadCount = snapshot.data ?? 0;

                            return unreadCount > 0
                                ? CircleAvatar(
                                    radius: 10,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    child: Text(
                                      unreadCount.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ),
                                    ),
                                  )
                                : SizedBox();
                          },
                        ),
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
}
