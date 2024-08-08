// This file contains the custom list tile widget that is used to display the seller details in the product detail screen.

import 'package:buybox/models/product.dart';
import 'package:buybox/screens/chat.dart';
import 'package:buybox/screens/edit_form.dart';
import 'package:buybox/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatefulWidget {
  const CustomListTile({Key? key, required this.currproduct}) : super(key: key);
  final ProductListing currproduct;

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the current user is null
    if (currentUser == null) {
      // Handle the case when the user is not logged in
      return Card(
        margin: const EdgeInsets.all(10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 6,
        child: ListTile(
          titleAlignment: ListTileTitleAlignment.center,
          hoverColor: Colors.black12,
          contentPadding: const EdgeInsets.all(12),
          title: Text(
            widget.currproduct.seller.username,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Text(
            widget.currproduct.seller.email,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.7),
                  fontSize: 16,
                ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.chat,
                color: Theme.of(context).colorScheme.secondary, size: 30),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Login Required'),
                    content: const Text(
                        'Please login to chat with the seller and view more details.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: const Text('Login'),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      );
    }

    bool isSeller = widget.currproduct.seller.userId == currentUser!.uid;

    // Determine the trailing widget based on whether the user is the seller
    Widget trailingWidget = isSeller
        ? IconButton(
            icon: Icon(Icons.edit,
                color: Theme.of(context).colorScheme.secondary, size: 30),
            onPressed: () {
              // navigate to the edit screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditItemForm(product: widget.currproduct),
                ),
              );
            },
          )
        : IconButton(
            icon: Icon(Icons.chat,
                color: Theme.of(context).colorScheme.secondary, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: getChatId(
                        currentUser!.uid, widget.currproduct.seller.userId),
                    sellerId: widget.currproduct.seller.userId,
                  ),
                ),
              );
            },
          );

    return Card(
      margin: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      elevation: 6,
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.center,
        hoverColor: Colors.black12,
        contentPadding: const EdgeInsets.all(12),
        leading: Hero(
          tag: 'productImage${widget.currproduct.id}',
          child: CircleAvatar(
            radius: 35,
            backgroundImage:
                NetworkImage(widget.currproduct.seller.profilePictureUrl),
          ),
        ),
        title: Text(
          widget.currproduct.seller.username,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          widget.currproduct.seller.email,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                fontSize: 16,
              ),
        ),
        trailing: trailingWidget,
      ),
    );
  }

  String getChatId(String userId, String sellerId) {
    return userId.hashCode <= sellerId.hashCode
        ? '$userId-$sellerId'
        : '$sellerId-$userId';
  }
}
