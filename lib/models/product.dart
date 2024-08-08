import 'dart:io';
import 'dart:ui';
import 'package:buybox/models/user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// ****************************************************************************************************
// ProductListing class is used to store the product listing data.
// It has properties for id, title, description, price, category, condition, transmission type, fuel type, color, year, owner, mileage, images, seller location, seller, created at, and updated at.
// The ProductListing class is used in the ProductRepository class to store the product listing data.
// ****************************************************************************************************

const uuid = Uuid();

// enum to hold the available catergories
enum Category {
  autoparts,
  vehicle,
  suv,
  sedan,
  truck,
  motorcycle,
  boat,
  other,
}

enum Condition {
  excellent,
  good,
  fair,
  poor,
  damaged,
}

// Define the ListingStatus enum
enum ListingStatus {
  active,
  sold,
  expired,
}

enum TransmissionType {
  manual,
  automatic,
  other,
}

enum FuelType {
  gasoline,
  diesel,
  electric,
  hybrid,
  other,
}

class SellerLocation {
  const SellerLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
  });

  final double latitude;
  final double longitude;
  final String city;
  final String state;
}

T enumFromString<T>(List<T> values, String value) {
  return values.firstWhere((type) => type.toString().split('.').last == value,
      orElse: () => throw ArgumentError('Unknown value: $value'));
}

class ProductListing {
  // add seller info
  // Location
  SellerLocation sellerLocation;
  // images
  List<File> images;
  List<String> images_urls;
  // Brand/Make and Model:
  final String id;
  String title;
  String description;

  int price;
  Category category;
  Condition condition;
  TransmissionType transType;
  FuelType fuelType;
  Color color;
  int year;
  int owner;
  int mileage;

  ListingStatus status;
  UserData seller;
  DateTime createdAt;
  DateTime? updatedAt;

  ProductListing({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.color, //
    required this.condition, //
    required this.fuelType,
    required this.transType,
    required this.year,
    required this.owner, //
    required this.mileage,
    required this.images,
    required this.sellerLocation,
    required this.seller,
    String? id,
  })  : id = id ?? const Uuid().v4(), // Generate a unique ID using Uuid
        images_urls = [],
        status = ListingStatus.active,
        createdAt = DateTime.now();

  // 2nd constructor
  ProductListing.fromMap(Map<String, dynamic> map)
      : id = map['id'] ?? '',
        title = map['title'] ?? '',
        description = map['description'] ?? '',
        price = map['price'] ?? 0,
        category = enumFromString(Category.values, map['category']),
        color = Color(map['color'] ?? 0xFF000000),
        condition = enumFromString(Condition.values, map['condition']),
        fuelType = enumFromString(FuelType.values, map['fuelType']),
        transType = enumFromString(TransmissionType.values, map['transType']),
        status = enumFromString(ListingStatus.values, map['status']),
        year = map['year'],
        owner = map['owner'],
        mileage = map['mileage'],
        images_urls = List<String>.from(map['images_urls'] ?? []),
        images = [],
        seller = UserData(
          userId: map['seller']['id'] ?? '',
          username: map['seller']['name'] ??
              '', // provide a default value if 'name' is null
          email: map['seller']['email'] ??
              '', // provide a default value if 'email' is null
          profilePictureUrl: map['seller']['image_url'] ??
              '', // provide a default value if 'image_url' is null
        ),
        sellerLocation = SellerLocation(
          city: map['sellerLocation']['city'] ??
              '', // provide a default value if 'city' is null
          latitude: map['sellerLocation']['latitude'] ??
              0.0, // provide a default value if 'latitude' is null
          longitude: map['sellerLocation']['longitude'] ??
              0.0, // provide a default value if 'longitude' is null
          state: map['sellerLocation']['state'] ??
              '', // provide a default value if 'state' is null
        ),
        createdAt = (map['createdAt'] as Timestamp).toDate(),
        updatedAt = map['updatedAt'] != null
            ? (map['updatedAt'] as Timestamp).toDate()
            : null;

  // Other methods and fields...

// method to be added ..
//1. update the listing date
//2. edit - support - update any attrubute that have been made

// returns a map format
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category.toString().split('.').last, // Convert enum to string
      'condition': condition.toString().split('.').last,
      'transType': transType.toString().split('.').last,
      'fuelType': fuelType.toString().split('.').last,
      'color': color.value,
      'year': year,
      'owner': owner,
      'mileage': mileage,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'sellerLocation': {
        'latitude': sellerLocation.latitude,
        'longitude': sellerLocation.longitude,
        'city': sellerLocation.city,
        'state': sellerLocation.state,
      },
      'seller': {
        'name': seller.username,
        'email': seller.email,
        'image_url': seller.profilePictureUrl,
        'id': seller.userId,
      }
      // Add other fields as needed
    };
  }
}
