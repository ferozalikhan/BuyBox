import 'dart:convert';
import 'package:buybox/models/product.dart';
import 'package:buybox/screens/map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationPickerContainer extends StatefulWidget {
  LocationPickerContainer({
    super.key,
    required this.setLocation,
    required this.resetLocationfunction,
    required this.resetLocation,
    // accept the picked location
    this.pickedLocation = const SellerLocation(
      latitude: 0.0,
      longitude: 0.0,
      city: '',
      state: '',
    ),
  });
  final Function(SellerLocation location) setLocation;
  final Function resetLocationfunction;
  bool resetLocation;
  final SellerLocation pickedLocation;
  @override
  State<LocationPickerContainer> createState() =>
      _LocationPickerContainerState();
}

class _LocationPickerContainerState extends State<LocationPickerContainer> {
  double conHeight = 100;
  SellerLocation? _pickedLocation;
  var _isGettingLocation = false;

  // intialize the picked location if it is not null
  @override
  void initState() {
    super.initState();
    if (widget.pickedLocation.latitude != 0.0 &&
        widget.pickedLocation.longitude != 0.0) {
      _pickedLocation = widget.pickedLocation;
    }
  }

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=13&size=600x300&maptype=roadmap&key=AIzaSyC8lNFtDhIHNfZF2aCV_kc7O-qrF0oW12o';
  }

  Future<void> _savePlace(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyC8lNFtDhIHNfZF2aCV_kc7O-qrF0oW12o');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final city = resData['results'][0]['address_components'][2]['long_name'];
    final state = resData['results'][0]['address_components'][4]['short_name'];
    if (kDebugMode) {
      print(city);
      print(state);
      print(widget.resetLocation);
    }

    setState(() {
      _pickedLocation = SellerLocation(
        latitude: latitude,
        longitude: longitude,
        city: city,
        state: state,
      );
      widget.setLocation(_pickedLocation!);
      _isGettingLocation = false;
    });

    //widget.onSelectLocation(_pickedLocation!);
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
      conHeight = 300;
    });

    locationData = await location.getLocation();

    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }
    _savePlace(lat, lng);
  }

  void _selectOnMap() async {
    late final pickedLocation;
    if (_pickedLocation != null) {
      pickedLocation = await Navigator.of(context).push<LatLng>(
        MaterialPageRoute(
          builder: (ctx) => MapScreen(
            isSelecting: true,
            location: _pickedLocation!,
          ),
        ),
      );
    } else {
      pickedLocation = await Navigator.of(context).push<LatLng>(
        MaterialPageRoute(
          builder: (ctx) => const MapScreen(),
        ),
      );
    }

    if (pickedLocation == null) {
      return;
    }

    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  void _resetLocation() {
    setState(() {
      _pickedLocation = null;
      widget.resetLocation = true;
      conHeight = 150;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Location",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                elevation: 0, // No shadow
                side: const BorderSide(
                  color: Color.fromARGB(255, 63, 61, 61),
                  width: 0.8,
                ),
              ),
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on_outlined),
              label: const Text(
                "Select Current Location",
                style: TextStyle(fontSize: 12),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                elevation: 0, // No shadow
                side: const BorderSide(
                  color: Color.fromARGB(255, 63, 61, 61),
                  width: 0.8,
                ),
              ),
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text(
                "Select on Map",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );

    if (_pickedLocation != null && widget.resetLocation == false) {
      conHeight = 300;
      result = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Location",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    widget.resetLocationfunction();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Icon(
                      Icons.cancel_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _selectOnMap,
              child: Container(
                margin:
                    const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                width: double.infinity,
                height: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Image.network(
                  alignment: Alignment.center,
                  locationImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      widget.resetLocation = false;
      _pickedLocation = null;
      conHeight = 120;
    }

    if (_isGettingLocation) {
      conHeight = 200;
      result = Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on_outlined),
                  label: const Text("Select Current Location"),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map),
                  label: const Text("Select on Map"),
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 2,
            indent: 5,
            endIndent: 5,
            color: Colors.grey,
          ),
          const CircularProgressIndicator(),
        ],
      );
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      width: double.infinity,
      height: conHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: result,
    );
  }
}
