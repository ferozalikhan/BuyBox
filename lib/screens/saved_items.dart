// ****************************************************************************************************
// The SavedItemsScreen class displays the items saved by the current user.
// The SavedItemsScreen class uses the ProductListing class to display the product details.
// The SavedItemsScreen class uses the FirebaseAuth and FirebaseFirestore classes to interact with Firebase.
// The SavedItemsScreen class uses the ProductList widget to display the list of saved items.
// ****************************************************************************************************

import 'package:buybox/models/product.dart';
import 'package:buybox/screens/item_detail.dart';
import 'package:buybox/widgets/home_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> {
  List<ProductListing> savedItems = [];
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // intialize the savedItems list

    fetchData();
  }

  // function to fetch data and update the list of products
  void fetchData() async {
    setState(() {
      isLoading = true;
    });
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        List<dynamic> savedIds = userDoc.data()!['saved_items'];
        for (dynamic itemId in savedIds) {
          // Fetch data from the 'categories' collection based on the current item ID
          final snapshot = await FirebaseFirestore.instance
              .collection('categories')
              .doc('vehicle')
              .collection('products')
              .doc(itemId)
              .get();

          if (snapshot.exists && snapshot.data() != null) {
            Map<String, dynamic>? productData = snapshot.data();
            final product = ProductListing.fromMap(productData!);
            setState(() {
              savedItems.add(product);
            });
          } else {
            if (kDebugMode) {
              print("Document with ID $itemId does not exist.");
            }
          }
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching data: $error");
      }
    }
  }

  void openItem(ProductListing product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => ItemDetailScreen(currproduct: product)),
    );
    setState(() {
      savedItems.clear();
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget dispalyWidget;
    if (isLoading) {
      dispalyWidget = Scaffold(
        appBar: AppBar(title: const Text("Saved Items")),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      dispalyWidget = savedItems.isEmpty == true
          ? Scaffold(
              appBar: AppBar(title: const Text("Saved Items")),
              body: const Center(
                  child: Center(
                child: Text("No Items Saved Yet"),
              )),
            )
          : Scaffold(
              appBar: AppBar(title: const Text("Saved Items")),
              body: ProductList(dummyData: savedItems, openItem: openItem));
    }
    return dispalyWidget;
  }
}
