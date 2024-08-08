// ****************************************************************************************************
// This file contains the code for the map screen which is used to display the location of the seller and the buyer.
// The MapScreen class is a StatefulWidget that displays a Google Map with a marker at the seller's location.
// The user can select a location on the map by tapping on it.
// The MapScreen class uses the SellerLocation class to store the location details.
// ****************************************************************************************************

import 'package:buybox/models/product.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const SellerLocation(
        latitude: 37.422, longitude: -122.084, city: '', state: ''),
    this.isSelecting = true,
  });

  final SellerLocation location;
  final bool isSelecting;

  @override
  State<MapScreen> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.isSelecting ? 'Pick your Location' : 'Location'),
            actions: [
              if (widget.isSelecting)
                IconButton(
                  icon: const Icon(Icons.bookmark),
                  onPressed: () {
                    Navigator.of(context).pop(_pickedLocation);
                  },
                ),
            ]),
        body: GoogleMap(
            onTap: !widget.isSelecting
                ? null
                : (position) {
                    setState(() {
                      _pickedLocation = position;
                    });
                  },
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.location.latitude,
                widget.location.longitude,
              ),
              zoom: 12,
            ),
            circles: (widget.isSelecting == false)
                ? {
                    Circle(
                      circleId: const CircleId('c1'),
                      center: LatLng(
                          widget.location.latitude, widget.location.longitude),

                      radius: 1200, // Adjust the radius as needed
                      fillColor:
                          Colors.blue.withOpacity(0.3), // Circle fill color
                      strokeWidth: 2, // Border width of the circle
                      strokeColor: Colors.blue, // Border color of the circle
                    ),
                  }
                : {
                    Circle(
                      circleId: const CircleId('c1'),
                      center: _pickedLocation == null
                          ? LatLng(widget.location.latitude,
                              widget.location.longitude)
                          : _pickedLocation!,

                      radius: 1200, // Adjust the radius as needed
                      fillColor:
                          Colors.blue.withOpacity(0.3), // Circle fill color
                      strokeWidth: 2, // Border width of the circle
                      strokeColor: Colors.blue, // Border color of the circle
                    ),
                  }));
  }
}
