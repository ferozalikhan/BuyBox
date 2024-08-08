// *******************************************************
// AddItemForm Widget
// Form widget to add a new item to the BuyBox app.
// *******************************************************

import 'dart:io';
import 'package:buybox/models/user_info.dart';
import 'package:buybox/widgets/add_item/buttons.dart';
import 'package:buybox/widgets/add_item/drop_buttons.dart';
import 'package:buybox/widgets/add_item/drop_buttons2.dart';
import 'package:buybox/widgets/add_item/imagepicker.dart';
import 'package:buybox/widgets/add_item/locationpicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buybox/models/product.dart'; // used for color picker
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

class AddItemForm extends StatefulWidget {
  const AddItemForm({super.key});

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Category _selectedCategory = Category.vehicle;
  Condition _selectedCondition = Condition.good;
  TransmissionType _selectedTransType = TransmissionType.automatic;
  FuelType _selectedFuelType = FuelType.gasoline;
  SellerLocation? _sellerLocation;
  bool resetLocation = false;
  var title = '';
  var description = '';
  var price = 0;
  var model = '';
  var owner = 1;
  var mileage = 000000;
  Color _color = const Color.fromARGB(255, 63, 61, 61);
  final formatter = DateFormat.yMd();
  DateTime _selectedDate = DateTime.now();

  // image picker
  List<File> _selectedImages = [];
  // flag for image picked list to be reset
  bool resetList = false;

  void _UpdateselectedImage(File? image) {
    setState(() {
      _selectedImages.add(image!);
      resetList = false;
    });
  }

  // function to remove the image from the list using index
  void removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _setLocation(SellerLocation location) {
    setState(() {
      _sellerLocation = location;
      resetLocation = false;
    });
  }

  // reset location picker
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
            // Need to use container to add size constraint.
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 100, 1),
              lastDate: DateTime(DateTime.now().year + 100, 1),
              initialDate: DateTime.now(),
              // save the selected date to _selectedDate DateTime variable.
              // It's used to set the previous selected date when
              // re-showing the dialog.
              selectedDate: _selectedDate,
              onChanged: (DateTime dateTime) {
                setState(() {
                  _selectedDate = dateTime;
                });
                // close the dialog when year is selected.
                Navigator.pop(context);

                // Do something with the dateTime selected.
                // Remember that you need to use dateTime.year to get the year
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
      if (_selectedImages.isEmpty && _sellerLocation == null) {
        // Show error message for images and location not picked
        _showErrorDialog("Please pick images & Location to continue");
        return;
      }
      if (_selectedImages.isEmpty) {
        // Show error message for images not picked
        _showErrorDialog("Please pick images");
        return;
      }

      if (_sellerLocation == null) {
        // Show error message for location not picked
        _showErrorDialog("Location is required.");
        return;
      }

      // If everything is fine, proceed to save the item
      final user = FirebaseAuth.instance.currentUser!;
      final usersnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      UserData seller = UserData(
          username: usersnapshot.data()!['username'],
          email: usersnapshot.data()!['email'],
          userId: user.uid,
          profilePictureUrl: usersnapshot.data()!['image_url']);

      Navigator.of(context).pop(ProductListing(
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
        seller: seller,
      ));
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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void resetForm() {
    // _formKey.currentState!.save();
    setState(() {
      _color = const Color.fromARGB(255, 63, 61, 61);
      _selectedDate = DateTime.now();
      _selectedCategory = Category.vehicle;
      _selectedCondition = Condition.good;
      _selectedFuelType = FuelType.gasoline;
      _selectedTransType = TransmissionType.automatic;
      _selectedImages.clear();
      _sellerLocation = null;
      resetList = true;
      resetLocation = true;
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
        title: const Text("Create Listing"),
        actions: [
          IconButton(
              onPressed: () {
                _formKey.currentState!.reset();
                resetForm();
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: saveItem, icon: const Icon(Icons.post_add_sharp)),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey, // Assign the form key
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
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
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 15.0),
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

                  const SizedBox(
                    height: 10,
                  ),

                  TextFormField(
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
                    validator: _validateDescription, // Add validation function
                    onSaved: (value) {
                      description = value ?? '';
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
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

                  const SizedBox(
                    height: 10,
                  ),

                  TextFormField(
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

                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // TextFormField(
                  //   decoration: InputDecoration(
                  //     labelText: "Vehicle Model",
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(16.0),
                  //     ),
                  //     prefixIcon: const Icon(Icons.directions_car),
                  //   ),
                  //   keyboardType: TextInputType.text,
                  //   validator: _validateVehicleModel, // Add validation
                  //   onSaved: (value) {
                  //     model = value.toString();
                  //   },
                  // ),

                  const SizedBox(
                    height: 10,
                  ),

                  TextFormField(
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

                  SizedBox(height: 10),
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
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
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

                  const SizedBox(
                    height: 10,
                  ),
                  CustomDropDownButtons(
                    onCategoryChanged: onCategoryChanged,
                    onConditionChanged: onConditionChanged,
                    selectedCategory: _selectedCategory,
                    selectedCondition: _selectedCondition,
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  CustomDropDownButtons2(
                      onTransTypeChanged: onTransmissionTypeChanged,
                      onFuelTypeChanged: onFuelTypeChanged,
                      selectedTransType: _selectedTransType,
                      selectedFuelType: _selectedFuelType),

                  const SizedBox(
                    height: 10,
                  ),

                  // Image Picker widget

                  ImagePickerContainer(
                    updateImagePicked: _UpdateselectedImage,
                    removeImage: removeImage,
                    resetList: resetList,
                    selectedImages: [],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // location picker
                  LocationPickerContainer(
                    setLocation: _setLocation,
                    resetLocation: resetLocation,
                    resetLocationfunction: resetLocationPicker,
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  CustomButtons(
                    formKey: _formKey,
                    resetForm: resetForm,
                    save: saveItem,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
