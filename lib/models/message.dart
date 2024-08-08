import 'package:cloud_firestore/cloud_firestore.dart';

// ****************************************************************************************************
// Message class is used to store the message data.
// It has properties for id, senderId, receiverId, text, and timestamp.
// The Message class is used in the ChatScreen and ChatListScreen classes to display the messages.
// ****************************************************************************************************

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final Timestamp timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      id: doc.id,
      senderId: doc['senderId'],
      receiverId: doc['receiverId'],
      text: doc['text'],
      timestamp: doc['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}

// fuction to keep track of unread messages
Future<int> getUnreadMessageCount(String userId) async {
  final chats = await FirebaseFirestore.instance
      .collection('chats')
      .where('participants', arrayContains: userId)
      .get();

  int unreadCount = 0;

  for (var chat in chats.docs) {
    final messages = await chat.reference.collection('messages').get();
    for (var message in messages.docs) {
      if (!message['readBy'].contains(userId)) {
        unreadCount++;
      }
    }
  }

  return unreadCount;
}

Stream<int> getUnreadMessageCountStream(String userId) async* {
  while (true) {
    yield await getUnreadMessageCount(userId);
  }
}
