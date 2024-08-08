// ****************************************************
//  Chat Screen
// Offer a chat screen to users to communicate with each other.
// ****************************************************

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level handler for background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  showNotification(message);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void showNotification(RemoteMessage message) async {
  final imageUrl = message.data['imageUrl'];

  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    styleInformation: imageUrl != null
        ? BigPictureStyleInformation(
            FilePathAndroidBitmap(imageUrl),
            contentTitle: message.notification?.title,
            summaryText: message.notification?.body,
          )
        : null,
  );

  final platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: jsonEncode({
      'chatId': message.data['chatId'],
      'sellerId': message.data['senderId'],
    }),
  );
}

void _configureFirebaseListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigateToChatScreen({
      'chatId': message.data['chatId'],
      'sellerId': message.data['senderId'],
    });
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String sellerId;

  ChatScreen({required this.chatId, required this.sellerId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _configureFirebaseListeners();
  }

  void _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await _firebaseMessaging.getToken();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getSellerData(String sellerId) async {
    DocumentSnapshot sellerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerId)
        .get();
    return sellerDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<Map<String, dynamic>>(
      future: getSellerData(widget.sellerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
            ),
            body: Center(
              child: Text('Error loading seller data'),
            ),
          );
        } else {
          final sellerData = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(sellerData['image_url']),
                    ),
                    SizedBox(width: 8),
                    Text(sellerData['username']),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () {},
                  ),
                ]),
            body: Column(
              children: [
                Expanded(
                    child: MessageList(
                        chatId: widget.chatId, sellerId: widget.sellerId)),
                MessageInput(
                  chatId: widget.chatId,
                  currentUser: currentUser!,
                  sellerId: widget.sellerId,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class MessageList extends StatelessWidget {
  final String chatId;
  final String sellerId;

  const MessageList({super.key, required this.chatId, required this.sellerId});

  void markMessagesAsRead(String chatId, String userId) async {
    final messages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    for (var doc in messages.docs) {
      if (!doc['readBy'].contains(userId)) {
        FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(doc.id)
            .update({
          'readBy': FieldValue.arrayUnion([userId])
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder<QuerySnapshot>(
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

        final messages = snapshot.data!.docs;
        markMessagesAsRead(chatId, currentUser!.uid);

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isCurrentUser = message['senderId'] == currentUser.uid;
            bool isRead = message['readBy'].contains(sellerId);
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Align(
                alignment: isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.onSecondary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['text'],
                        style: TextStyle(
                          color: isCurrentUser
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyText1!.color,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        message['timestamp'] != null
                            ? (message['timestamp'] as Timestamp)
                                .toDate()
                                .toString()
                            : 'Sending...',
                        style: TextStyle(
                          color: isCurrentUser
                              ? Colors.white70
                              : Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color!
                                  .withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                      if (isCurrentUser)
                        Text(
                          isRead ? 'Read' : 'Delivered',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MessageInput extends StatefulWidget {
  final String chatId;
  final User currentUser;
  final String sellerId;

  MessageInput(
      {required this.chatId,
      required this.currentUser,
      required this.sellerId});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final message = {
        'text': _messageController.text,
        'senderId': widget.currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [widget.currentUser.uid],
      };

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .set({
        'lastMessage': _messageController.text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'participants':
            FieldValue.arrayUnion([widget.currentUser.uid, widget.sellerId]),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(message);

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

void navigateToChatScreen(Map<String, dynamic> payload) {
  // Implement navigation to chat screen based on the payload data
}
