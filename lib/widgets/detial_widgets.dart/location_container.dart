// LocationContainer is a widget that displays the location of the product on a map.

import 'package:buybox/models/product.dart';
import 'package:buybox/screens/map.dart';
import 'package:flutter/material.dart';

class LocationContainer extends StatefulWidget {
  const LocationContainer({super.key, required this.currproduct});
  final ProductListing currproduct;

  @override
  State<LocationContainer> createState() => _LocationContainerState();
}

class _LocationContainerState extends State<LocationContainer> {
  String get locationImage {
    final lat = widget.currproduct.sellerLocation.latitude;
    final lng = widget.currproduct.sellerLocation.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=13&size=600x300&maptype=roadmap&key=your_api_key_here';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => MapScreen(
              location: widget.currproduct.sellerLocation,
              isSelecting: false,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.center,
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    locationImage,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
