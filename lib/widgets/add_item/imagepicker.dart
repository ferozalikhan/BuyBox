import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerContainer extends StatefulWidget {
  final Function(File image) updateImagePicked;
  final Function(int index) removeImage;
  final bool resetList;
  final List<File> selectedImages; // New property to accept selected images

  const ImagePickerContainer({
    Key? key,
    required this.updateImagePicked,
    required this.removeImage,
    required this.resetList,
    required this.selectedImages,
  }) : super(key: key);

  @override
  _ImagePickerContainerState createState() => _ImagePickerContainerState();
}

class _ImagePickerContainerState extends State<ImagePickerContainer> {
  List<File> selectedImages = [];

  @override
  void initState() {
    super.initState();
    selectedImages = widget.selectedImages;

    if (kDebugMode) {
      // print the widget selectedImages
      print('Widget Selected Images: ${widget.selectedImages}');
      print('Selected Images length: ${selectedImages.length}');
      print('Selected Images: $selectedImages');
      // length of selectedImages
      print('Selected Images Length: ${selectedImages.length}');
    }
  }

  void takePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      widget.updateImagePicked(File(pickedImage.path));
      setState(() {
        selectedImages.add(File(pickedImage.path));
      });
    }
  }

  void chooseFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      widget.updateImagePicked(File(pickedImage.path));
      setState(() {
        selectedImages.add(File(pickedImage.path));
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
    widget.removeImage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Images',
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
            ),
            const SizedBox(height: 8.0),
            selectedImages.isNotEmpty
                ? SizedBox(
                    height: 150.0, // Fixed height for image preview
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            Image.file(
                              selectedImages[index],
                              width: 150.0, // Fixed width for each image
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => removeImage(index),
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: takePhoto,
                  icon: const Icon(Icons.camera_alt_rounded),
                  label:
                      const Text('Take Photo', style: TextStyle(fontSize: 12)),
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
                ),
                ElevatedButton.icon(
                  onPressed: chooseFromGallery,
                  icon: const Icon(Icons.image),
                  label: const Text('Choose from Gallery',
                      style: TextStyle(fontSize: 12)),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
