// **************************************************************************
// Summary: This file contains the EditItemForm class, which is a StatefulWidget
// that displays a form for editing a product listing.
// **************************************************************************

import 'dart:io';
import 'package:buybox/models/user_info.dart';
import 'package:buybox/widgets/add_item/drop_buttons.dart';
import 'package:buybox/widgets/add_item/drop_buttons2.dart';
import 'package:buybox/widgets/add_item/imagepicker.dart';
import 'package:buybox/widgets/add_item/locationpicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:buybox/models/product.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class EditItemForm extends StatefulWidget {
  final ProductListing product;

  const EditItemForm({super.key, required this.product});

  @override
  State<EditItemForm> createState() => _EditItemFormState();
}

class _EditItemFormState extends State<EditItemForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Category _selectedCategory;
  late Condition _selectedCondition;
  late TransmissionType _selectedTransType;
  late FuelType _selectedFuelType;
  SellerLocation? _sellerLocation;
  bool resetLocation = false;
  late String title;
  late String description;
  late int price;
  late String model;
  late int owner;
  late int mileage;
  late Color _color;
  final formatter = DateFormat.yMd();
  late DateTime _selectedDate;

  // image picker
  List<File> _selectedImages = [];
  // images upload in string format
  List<String> _imagesUrls = [];
  bool resetList = false;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.product.category;
    _selectedCondition = widget.product.condition;
    _selectedTransType = widget.product.transType;
    _selectedFuelType = widget.product.fuelType;
    _sellerLocation = widget.product.sellerLocation;
    title = widget.product.title;
    description = widget.product.description;
    price = widget.product.price;
    owner = widget.product.owner;
    mileage = widget.product.mileage;
    _color = widget.product.color;
    _selectedDate = DateTime(widget.product.year);
    _selectedImages = [];
    _imagesUrls = widget.product.images_urls;
    // if (kDebugMode) {
    //   print('----------------------');
    //   print('Selected Images: $_selectedImages');
    //   print('Selected Images length: ${_selectedImages.length}');
    //   print('----------------------');
    // }
  }

  void _UpdateselectedImage(File? image) {
    setState(() {
      _selectedImages.add(image!);
      resetList = false;
    });
  }

  void removeImage(int index) async {
    // Remove image file from Firebase Storage
    if (_imagesUrls.isNotEmpty && index < _imagesUrls.length) {
      try {
        // Extract image filename from URL
        final imageUrl = _imagesUrls[index];
        // Split the URL by '%2F' to get segments
        List<String> segments = imageUrl.split('%2F');

        // The last segment contains the filename with its extension
        String lastSegment = segments.last;

        // Split the last segment by '?' to remove query parameters
        String fileName = lastSegment.split('?').first;
        if (kDebugMode) {
          print('----------------------');
          print('Deleting image: $fileName');
          print('----------------------');
        }

        // Delete image from Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('products_images')
            .child(widget.product.id);
        await storageRef.child(fileName).delete();

        // Remove image URL from _imagesUrls list
        setState(() {
          _imagesUrls.removeAt(index);
        });

        // Update Firestore document to remove image URL
        final productRef = FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.product.category.name)
            .collection('products')
            .doc(widget.product.id);

        await productRef.update({
          'images_urls': FieldValue.arrayRemove([imageUrl]),
        });
      } catch (e) {
        print('Error removing image: $e');
        // Handle error as needed
      }
    }
  }

  void _setLocation(SellerLocation location) {
    setState(() {
      _sellerLocation = location;
      resetLocation = false;
    });
  }

  void resetLocationPicker() {
    setState(() {
      _sellerLocation = null;
      resetLocation = true;
    });
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    } else if (value.trim().length > 40) {
      return 'Must be between 1 and 40 characters.';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    if (double.tryParse(value) == null || value.isEmpty) {
      return 'Price must be a valid number';
    } else if (value.trim().length > 14) {
      return 'Price should not exceed 14 digits.';
    }
    return null;
  }

  String? _validateMileage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mileage is required';
    }
    if (int.tryParse(value) == null) {
      return 'Mileage must be a valid number';
    } else if (value.trim().length > 14) {
      return 'Mileage should not exceed 14 digits.';
    }
    return null;
  }

  String? _validateOwners(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number of Owners is required';
    }
    if (int.tryParse(value) == null) {
      return 'Number of Owners must be a valid number';
    } else if (value.trim().length > 14) {
      return 'Number of Owners should not exceed 14 digits.';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    return null;
  }

  void showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _color,
              onColorChanged: (color) {
                setState(() => _color = color);
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void yearPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 100, 1),
              lastDate: DateTime(DateTime.now().year + 100, 1),
              initialDate: DateTime.now(),
              selectedDate: _selectedDate,
              onChanged: (DateTime dateTime) {
                setState(() {
                  _selectedDate = dateTime;
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  void saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedImages.isEmpty &&
          _imagesUrls.isEmpty &&
          _sellerLocation == null) {
        _showErrorDialog("Please select images & Location is required.");
        return;
      }
      if (_selectedImages.isEmpty && _imagesUrls.isEmpty) {
        _showErrorDialog("Please select images.");
        return;
      }

      if (_sellerLocation == null) {
        _showErrorDialog("Location is required.");
        return;
      }

      try {
        setState(() {
          isUpdating = true;
        });
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('products_images')
            .child(widget.product.id);

        // Upload new images to Firebase Storage
        List<String> updatedImageUrls = [];
        for (var imageFile in _selectedImages) {
          final imageUuid = const Uuid().v4();
          await storageRef.child('$imageUuid.jpg').putFile(imageFile);
          final imageUrl =
              await storageRef.child('$imageUuid.jpg').getDownloadURL();
          updatedImageUrls.add(imageUrl);
        }

        // Create updated ProductListing object
        ProductListing updatedProduct = ProductListing(
          id: widget.product.id,
          title: title,
          description: description,
          price: price,
          category: _selectedCategory,
          images: _selectedImages,
          sellerLocation: _sellerLocation!,
          fuelType: _selectedFuelType,
          transType: _selectedTransType,
          color: _color,
          condition: _selectedCondition,
          year: _selectedDate.year,
          owner: owner,
          mileage: mileage,
          seller: UserData(
              username: widget.product.seller.username,
              email: widget.product.seller.email,
              userId: widget.product.seller.userId,
              profilePictureUrl: widget.product.seller.profilePictureUrl),
        );

        // Update Firestore document
        final productRef = FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.product.category.name)
            .collection('products')
            .doc(widget.product.id);

        // combine the old and new image URLs
        List<String> newupdatedImageUrls = [];
        newupdatedImageUrls.addAll(_imagesUrls);
        newupdatedImageUrls.addAll(updatedImageUrls);

        await productRef.update({
          ...updatedProduct.toMap(),
          'images_urls': newupdatedImageUrls,
        });
        // navigate back to the previous screen
        Navigator.of(context).pop();
      } catch (e) {
        _showErrorDialog("Failed to save product: $e");
      }
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Incomplete Information"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void resetForm() {
    setState(() {
      _color = widget.product.color;
      _selectedDate = DateTime(widget.product.year);
      _selectedCategory = widget.product.category;
      _selectedCondition = widget.product.condition;
      _selectedFuelType = widget.product.fuelType;
      _selectedTransType = widget.product.transType;
      _selectedImages.clear();
      _imagesUrls = widget.product.images_urls;
      _sellerLocation = widget.product.sellerLocation;
      resetList = true;
    });
  }

  void onCategoryChanged(Category category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void onConditionChanged(Condition condition) {
    setState(() {
      _selectedCondition = condition;
    });
  }

  void onTransmissionTypeChanged(TransmissionType transType) {
    setState(() {
      _selectedTransType = transType;
    });
  }

  void onFuelTypeChanged(FuelType fuelType) {
    setState(() {
      _selectedFuelType = fuelType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Listing"),
        actions: [
          IconButton(
            onPressed: () {
              _formKey.currentState!.reset();
              resetForm();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: isUpdating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: widget.product.title,
                        decoration: InputDecoration(
                          labelText: "Title",
                          labelStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontSize: 16.0,
                          ),
                          hintText: "Enter the title",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.red.shade300,
                              width: 2.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.red.shade300,
                              width: 2.0,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8, horizontal: 15.0),
                          errorStyle: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 12.0,
                          ),
                        ),
                        validator: _validateTitle,
                        onSaved: (value) {
                          title = value ?? '';
                        },
                      ),
                      const SizedBox(height: 20),
                      // description
                      TextFormField(
                        initialValue: widget.product.description,
                        maxLines: 3,
                        textAlignVertical: TextAlignVertical.top,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          labelText: "Description",
                          labelStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontSize: 16.0,
                          ),
                          hintText: "Enter the description",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.red.shade300,
                              width: 2.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.red.shade300,
                              width: 2.0,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 15.0),
                          errorStyle: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 12.0,
                          ),
                        ),
                        validator:
                            _validateDescription, // Add validation function
                        onSaved: (value) {
                          description = value ?? '';
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: widget.product.price.toString(),
                        decoration: InputDecoration(
                          labelText: "Price",
                          labelStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontSize: 16.0,
                          ),
                          hintText: "Enter the price",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.red.shade300,
                              width: 2.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.red.shade300,
                              width: 2.0,
                            ),
                          ),
                          prefixIcon: Icon(Icons.attach_money),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 15.0),
                          errorStyle: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 12.0,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validatePrice, // Add validation function
                        onSaved: (value) {
                          if (value != null) {
                            price = int.parse(value);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: widget.product.mileage.toString(),
                        decoration: InputDecoration(
                          labelText: "Mileage",
                          labelStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontSize: 16.0,
                          ),
                          hintText: "Enter the mileage",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.red.shade300,
                              width: 2.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.red.shade300,
                              width: 2.0,
                            ),
                          ),
                          prefixIcon: Icon(Icons.speed),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 15.0),
                          errorStyle: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 12.0,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateMileage, // Add validation function
                        onSaved: (value) {
                          if (value != null) {
                            mileage = int.parse(value);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: widget.product.owner.toString(),
                        decoration: InputDecoration(
                          labelText: "Number of Owners",
                          labelStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontSize: 16.0,
                          ),
                          hintText: "Enter the number of owners",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.red.shade300,
                              width: 2.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: Colors.red.shade300,
                              width: 2.0,
                            ),
                          ),
                          prefixIcon: Icon(Icons.people),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 15.0),
                          errorStyle: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 12.0,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateOwners, // Add validation function
                        onSaved: (value) {
                          if (value != null) {
                            owner = int.parse(value);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomDropDownButtons(
                        onCategoryChanged: onCategoryChanged,
                        onConditionChanged: onConditionChanged,
                        selectedCategory: _selectedCategory,
                        selectedCondition: _selectedCondition,
                      ),
                      const SizedBox(height: 20),
                      CustomDropDownButtons2(
                        onTransTypeChanged: onTransmissionTypeChanged,
                        onFuelTypeChanged: onFuelTypeChanged,
                        selectedTransType: _selectedTransType,
                        selectedFuelType: _selectedFuelType,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              height: 50,
                              width: 30,
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _color,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                title: Text(
                                  "Color",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                    fontSize: 16.0,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.color_lens,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onTap: () {
                                  showColorPicker();
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 50,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .color,
                                ),
                                title: Text(
                                  "Year",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                    fontSize: 16.0,
                                  ),
                                ),
                                trailing: Text(
                                  _selectedDate.year.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                  ),
                                ),
                                onTap: yearPicker,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Display images from URLs
                      _imagesUrls.isEmpty
                          ? const SizedBox.shrink()
                          : Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Uploaded Images',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .color,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      SizedBox(
                                        height: 105,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _imagesUrls.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Stack(
                                                children: [
                                                  Image.network(
                                                    _imagesUrls[index],
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Positioned(
                                                    top: 3,
                                                    right: 3,
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          removeImage(index),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.black
                                                              .withOpacity(0.5),
                                                        ),
                                                        child: const Icon(
                                                          Icons.cancel_rounded,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ))),
                      _imagesUrls.isEmpty
                          ? const SizedBox.shrink()
                          : const SizedBox(height: 20),
                      ImagePickerContainer(
                        updateImagePicked: _UpdateselectedImage,
                        removeImage: removeImage,
                        resetList: resetList,
                        selectedImages: [],
                      ),
                      const SizedBox(height: 20),
                      LocationPickerContainer(
                        setLocation: _setLocation,
                        resetLocation: resetLocation,
                        resetLocationfunction: resetLocationPicker,
                        pickedLocation: SellerLocation(
                            latitude: widget.product.sellerLocation.latitude,
                            longitude: widget.product.sellerLocation.longitude,
                            city: widget.product.sellerLocation.city,
                            state: widget.product.sellerLocation.state),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red, // Background color
                              onPrimary: Colors.white, // Text color
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                          // Reset button
                          ElevatedButton(
                            onPressed: resetForm,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text("Reset"),
                          ),

                          ElevatedButton(
                            onPressed: saveItem,
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green, // Background color
                              onPrimary: Colors.white, // Text color
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text("Save"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
