// ****************************************************************************************************
// HomePage class is the main screen of the app
// It displays the list of products and provides the user with the ability to filter the products
// It also allows the user to search for products and add new products
// The HomePage class uses the ProductList widget to display the list of products
// The HomePage class uses the FilterDialog widget to display the filter dialog
// The HomePage class uses the CustomSearchDelegate class to implement search functionality
// The HomePage class uses the getUnreadMessageCountStream function to get the unread message count
// ****************************************************************************************************

import 'package:buybox/models/filter.dart';
import 'package:buybox/models/message.dart';
import 'package:buybox/models/product.dart';
import 'package:buybox/screens/add_item.dart';
import 'package:buybox/screens/item_detail.dart';
import 'package:buybox/screens/login.dart';
import 'package:buybox/screens/my_listing.dart';
import 'package:buybox/screens/my_messages.dart';
import 'package:buybox/widgets/filter_dialog.dart';
import 'package:buybox/widgets/home_list.dart';
import 'package:buybox/widgets/main_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

enum Category { autoparts, vehicle, suv, truck, motorcycle, boat, other }

// list of welcome messages for the user
final welcomeMessages = [
  'Welcome!',
  'Hello!',
  'Hi there!',
  'Greetings!',
  'Good day!',
  'Howdy!',
  'Hey!',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onThemeModeChange});
  final Function(bool darkmode) onThemeModeChange;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FilterCriteria _filterCriteria = FilterCriteria();
  // user locaiton
  Position? _currentPosition;
  // search bar query
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) {
      setState(() {
        user = newUser;
      });
    });
  }

// fetch user locatin
  Future<void> _getCurrentLocation() async {
    LocationPermission permission;

    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });
  }

  Stream<List<ProductListing>> fetchData() {
    return FirebaseFirestore.instance
        .collectionGroup('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductListing.fromMap(doc.data()))
            .toList());
  }

  // Bar: profile Icon
  void switchscreen(BuildContext context) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const LoginScreen()));
    setState(() {
      isLoading = true;
    });
    fetchData();
  }

  void switchToAddScreen() async {
    final newitem = await Navigator.of(context).push<ProductListing>(
        MaterialPageRoute(builder: (ctx) => const AddItemForm()));
    if (newitem == null) {
      return;
    }
    // upload all the images to FirebaseStorage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('products_images')
        .child(newitem.id);

    for (var imageFile in newitem.images) {
      final imageUuid = uuid.v4();
      await storageRef.child('$imageUuid.jpg').putFile(imageFile);
      final imageUrl =
          await storageRef.child('$imageUuid.jpg').getDownloadURL();
      newitem.images_urls.add(imageUrl);
    }

    newitem.images.clear();

    await FirebaseFirestore.instance
        .collection('categories')
        .doc(newitem.category.name)
        .collection('products')
        .doc(newitem.id)
        .set({...newitem.toMap(), 'images_urls': newitem.images_urls});

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'sale_items': FieldValue.arrayUnion([newitem.id])
    });
  }

  void openItem(ProductListing product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => ItemDetailScreen(currproduct: product)),
    );
    setState(() {
      isLoading = true;
    });
    fetchData();
  }

  void openMyListing() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const MyListingScreen()));
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openFilterDialog() async {
    final updatedFilters = await showDialog(
      context: context,
      builder: (context) => FilterDialog(initialCriteria: _filterCriteria),
    );

    if (updatedFilters != null) {
      setState(() {
        _filterCriteria = updatedFilters;
      });
    }
    // Fetch location if location range is specified
    if (_filterCriteria.locationRange != null) {
      // print location

      await _getCurrentLocation(); // Fetch current location
      // print debug info
      if (kDebugMode) {
        print('Current location: $_currentPosition');
      }
    }
  }

  Stream<List<ProductListing>> fetchDataWithFilter() {
    Query collectionReference =
        FirebaseFirestore.instance.collectionGroup('products');

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      collectionReference = collectionReference.where('title',
          isGreaterThanOrEqualTo: _searchQuery,
          isLessThanOrEqualTo: _searchQuery + '\uf8ff');
    }

    // Apply filters that do not have inequality
    if (_filterCriteria.category != null) {
      collectionReference = FirebaseFirestore.instance
          .collection('categories')
          .doc(_filterCriteria.category.toString().split('.').last)
          .collection('products');
    }
    if (_filterCriteria.condition != null) {
      collectionReference = collectionReference.where('condition',
          isEqualTo: _filterCriteria.condition.toString().split('.').last);
    }
    if (_filterCriteria.transmissionType != null) {
      collectionReference = collectionReference.where('transType',
          isEqualTo:
              _filterCriteria.transmissionType.toString().split('.').last);
    }
    if (_filterCriteria.fuelType != null) {
      collectionReference = collectionReference.where('fuelType',
          isEqualTo: _filterCriteria.fuelType.toString().split('.').last);
    }

    // Apply price filtering
    if (_filterCriteria.minPrice != null) {
      collectionReference = collectionReference.where('price',
          isGreaterThanOrEqualTo: _filterCriteria.minPrice);
    }
    if (_filterCriteria.maxPrice != null) {
      collectionReference = collectionReference.where('price',
          isLessThanOrEqualTo: _filterCriteria.maxPrice);
    }

    // Fetch data based on other criteria without inequality
    Stream<List<ProductListing>> filteredProductsStream = collectionReference
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              if (data is Map<String, dynamic>) {
                return ProductListing.fromMap(data);
              }
              throw Exception('Document data is not a Map<String, dynamic>');
            }).toList());

    // Apply year filtering locally after fetching data
    if (_filterCriteria.minYear != null || _filterCriteria.maxYear != null) {
      filteredProductsStream = filteredProductsStream.map((products) => products
          .where((product) =>
              (_filterCriteria.minYear == null ||
                  product.year >= _filterCriteria.minYear!) &&
              (_filterCriteria.maxYear == null ||
                  product.year <= _filterCriteria.maxYear!))
          .toList());
    }

    // Apply location filter if location range is specified and current position is available
    if (_filterCriteria.locationRange != null && _currentPosition != null) {
      final rangeInDegrees = _filterCriteria.locationRange! / 69.0;
      final minLatitude = _currentPosition!.latitude - rangeInDegrees;
      final maxLatitude = _currentPosition!.latitude + rangeInDegrees;

      filteredProductsStream = filteredProductsStream.map((products) => products
          .where((product) =>
              product.sellerLocation.latitude >= minLatitude &&
              product.sellerLocation.latitude <= maxLatitude)
          .toList());
    }

    return filteredProductsStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: true, // enable drag to open drawer
      key: _scaffoldKey,
      drawer: MainDrawer(
          isLogedin: user == null ? false : true,
          onThemeModeChange: widget.onThemeModeChange),
      appBar: AppBar(
        actionsIconTheme: IconThemeData(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        // display the logo saved in the assets folder
        title: Text(
          welcomeMessages[DateTime.now().minute % welcomeMessages.length],
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),

        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: openDrawer,
        ),
        actions: [
          IconButton(
            onPressed: _openFilterDialog, // this is the filter button
            icon: Icon(
              Icons.tune, // Updated filter icon
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          IconButton(
              onPressed: () {
                if (user == null) {
                  // prompt to Login Screen
                  switchscreen(context);
                } else {
                  switchToAddScreen();
                }
              },
              icon: Icon(
                Icons.add_box,
                color: Theme.of(context).appBarTheme.foregroundColor,
              )),
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(
                  onSearch: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
              );
            },
            icon: Icon(Icons.search,
                color: Theme.of(context).appBarTheme.foregroundColor),
          ),
          user != null
              ? IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    setState(() {
                      user = null;
                    });
                  },
                  icon: const Icon(Icons.logout),
                  color: Theme.of(context).appBarTheme.foregroundColor,
                )
              : IconButton(
                  onPressed: () {
                    switchscreen(context);
                  },
                  icon: const Icon(Icons.person),
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
        ],
      ),
      body: StreamBuilder<List<ProductListing>>(
        stream: _filterCriteria.isEmpty
            ? fetchData()
            : fetchDataWithFilter(), // Updated to use fetchDataWithFilter
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred!'),
            );
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No products found!'),
            );
          }
          final products = snapshot.data ?? [];
          return ProductList(
            dummyData: products,
            openItem: openItem,
          );
        },
      ),
      // display the floating action button with unread messages count
      // if the user is logged in

      floatingActionButton: user == null
          ? null
          : StreamBuilder<int>(
              stream: getUnreadMessageCountStream(user?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final unreadCount = snapshot.data ?? 0;

                return Stack(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => MyMessagesScreen(),
                        ));
                      },
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .background
                          .withOpacity(0.6), // Example: Use accent color
                      elevation: 2, // Example: Add elevation for shadow
                      tooltip: 'Chat', // Optional tooltip for accessibility
                      child: Icon(
                        Icons.chat,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                    ),
                    if (unreadCount > 0) // Display unread count badge
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red, // Customize color as needed
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  CustomSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement buildResults to display search results
    return StreamBuilder<List<ProductListing>>(
      stream: FirebaseFirestore.instance
          .collectionGroup('products')
          .where('title',
              isGreaterThanOrEqualTo: query,
              isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductListing.fromMap(doc.data()))
              .toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred!'),
          );
        }
        final products = snapshot.data ?? [];
        return ProductList(
          dummyData: products,
          openItem: (product) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => ItemDetailScreen(currproduct: product),
            ));
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement buildSuggestions to show search suggestions
    // print debug info

    return StreamBuilder<List<String>>(
      stream: FirebaseFirestore.instance
          .collectionGroup('products')
          .where('title',
              isGreaterThanOrEqualTo: query,
              isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => doc.get('title').toString()).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred!'),
          );
        }
        final suggestions = snapshot.data ?? [];
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              title: Text(suggestion),
              onTap: () {
                query = suggestion;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}
