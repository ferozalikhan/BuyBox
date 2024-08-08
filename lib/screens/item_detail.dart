// This file contains the ItemDetailScreen class which is a StatefulWidget.
// The ItemDetailScreen class displays the details of a product listing.
// The user can save the listing to their saved items list by clicking on the bookmark icon.
// The ItemDetailScreen class uses the ProductListing class to display the product details.
// The ItemDetailScreen class uses the FirebaseAuth and FirebaseFirestore classes to interact with Firebase.
// The ItemDetailScreen class uses the CustomeContainer, DetailCard, LocationContainer, and CustomListTile classes to display the product details.
// ****************************************************************************************************

import 'package:buybox/models/product.dart';
import 'package:buybox/widgets/detial_widgets.dart/custome_container.dart';
import 'package:buybox/widgets/detial_widgets.dart/detai_card.dart';
import 'package:buybox/widgets/detial_widgets.dart/lis_tile.dart';
import 'package:buybox/widgets/detial_widgets.dart/location_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({Key? key, required this.currproduct})
      : super(key: key);
  final ProductListing currproduct;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool saveItem = false;

  @override
  void initState() {
    super.initState();
    if (isUserLoggedIn()) {
      checkSavedItem(widget.currproduct.id);
    }
  }

  bool isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  Future<void> checkSavedItem(String curritem) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        List<dynamic> savedItems = (userDoc.data()?['saved_items']);

        if (savedItems != null && savedItems.contains(curritem)) {
          setState(() {
            saveItem = true;
          });
        } else {
          setState(() {
            saveItem = false;
          });
        }
      } else {
        setState(() {
          saveItem = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error checking saved items: $e");
      }
    }
  }

  void saveToList() async {
    setState(() {
      saveItem = !saveItem;
    });
    try {
      if (saveItem) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'saved_items': FieldValue.arrayUnion([widget.currproduct.id])
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'saved_items': FieldValue.arrayRemove([widget.currproduct.id])
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error updating saved items: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currproduct.title,
          softWrap: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (FirebaseAuth.instance.currentUser != null)
            IconButton(
              icon: Icon(
                saveItem == false ? Icons.bookmark_border : Icons.bookmark,
              ),
              onPressed: saveToList,
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Section
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: CustomeContainer(currproduct: widget.currproduct),
              ),
              SizedBox(height: 16),

              // Divider
              Divider(),

              // About Category Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About this ${widget.currproduct.category.name}:",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  DetailCard(currproduct: widget.currproduct),
                ],
              ),
              SizedBox(height: 16),

              // Divider
              Divider(),

              // Location Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Location: ${widget.currproduct.sellerLocation.city}, ${widget.currproduct.sellerLocation.state}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  LocationContainer(currproduct: widget.currproduct),
                ],
              ),
              SizedBox(height: 16),

              // Divider
              Divider(),

              // Seller Information Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Seller Information:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  CustomListTile(currproduct: widget.currproduct),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
