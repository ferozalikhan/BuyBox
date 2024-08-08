// ****************************************************************************************************
// This file contains the MyListingScreen class which is a StatefulWidget.
// The MyListingScreen class displays the listings posted by the current user.
// The MyListingScreen class uses the ProductListing class to display the product details.
// The MyListingScreen class uses the FirebaseAuth and FirebaseFirestore classes to interact with Firebase.
// The MyListingScreen class uses the EditItemForm class to edit the product details.
// ****************************************************************************************************

import 'package:buybox/screens/edit_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:buybox/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Category { autoparts, vehicle, suv, truck, motorcycle, boat, other }

class MyListingScreen extends StatefulWidget {
  const MyListingScreen({Key? key}) : super(key: key);

  @override
  _MyListingScreenState createState() => _MyListingScreenState();
}

class _MyListingScreenState extends State<MyListingScreen> {
  final List<ProductListing> _userListings = [];
  bool _isLoading = false;
  User? user;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    fetchUserListings();
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) {
      setState(() {
        user = newUser;
      });
    });
  }

  Future<void> fetchUserListings() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return;
      }

      final saleItems = List<String>.from(userDoc.data()!['sale_items']);
      if (kDebugMode) {
        print('-- Sale Items --');
        print('length $saleItems');
        print(saleItems.length);
        print('-- Sale Items --');
      }

      _userListings.clear();
      for (var category in Category.values) {
        final snapshot = await FirebaseFirestore.instance
            .collection('categories')
            .doc(category.toString().split('.').last)
            .collection('products')
            .get();

        for (var doc in snapshot.docs) {
          final productData = doc.data();
          final product = ProductListing.fromMap(productData);
          if (saleItems.contains(product.id)) {
            _userListings.add(product);
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching user listings: $error");
      }
    }
  }

  void _editListing(ProductListing product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditItemForm(product: product),
      ),
    );
    setState(() {
      _isLoading = true;
    });
    fetchUserListings();
  }

  void _deleteListing(ProductListing product) async {
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(product.category.name)
        .collection('products')
        .doc(product.id)
        .delete();

    setState(() {
      _userListings.remove(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Listings",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _userListings.length,
              itemBuilder: (ctx, index) {
                final product = _userListings[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black38,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      title: Text(
                        product.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyText1!.color,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyText2!.color,
                          ),
                        ),
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.images_urls.isEmpty
                              ? 'https://via.placeholder.com/150'
                              : product.images_urls[0].toString(),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.blueAccent,
                            onPressed: () => _editListing(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.redAccent,
                            onPressed: () => _deleteListing(product),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
