// Usage: navigateToChatScreen(data)

import 'package:flutter/material.dart';
import 'package:buybox/screens/chat.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void navigateToChatScreen(Map<String, dynamic> data) {
  final chatId = data['chatId'] ?? '';
  final sellerId = data['sellerId'] ?? '';

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        chatId: chatId,
        sellerId: sellerId,
      ),
    ),
  );
}
