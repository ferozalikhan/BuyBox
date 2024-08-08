// ****************************************************************************************************
// CustomeContainer widget
// A stateful widget that displays a container with a page view of images.
// The widget also displays indicators for the images.
// ****************************************************************************************************

import 'package:buybox/models/product.dart';
import 'package:flutter/material.dart';

class CustomeContainer extends StatefulWidget {
  const CustomeContainer({super.key, required this.currproduct});
  final ProductListing currproduct;

  @override
  State<CustomeContainer> createState() => _CustomeContainerState();
}

class _CustomeContainerState extends State<CustomeContainer> {
  int _currentPage = 0;
  // page controller
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  // indicators for images
  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < widget.currproduct.images_urls.length; i++) {
      indicators.add(
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
        ),
      );
    }
    return indicators;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
              controller: _pageController,
              itemCount: widget.currproduct.images_urls.length,
              itemBuilder: (context, index) {
                return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 63, 61, 61),
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Image.network(
                    widget.currproduct.images_urls[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              }),
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
