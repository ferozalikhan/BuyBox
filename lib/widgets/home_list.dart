// This file contains the ProductList widget which is used to display the list of products in the home screen.

import 'package:flutter/material.dart';
import 'package:buybox/models/product.dart';
import 'package:buybox/widgets/item.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    Key? key,
    required this.dummyData,
    required this.openItem,
  }) : super(key: key);

  final List<ProductListing> dummyData;
  final void Function(ProductListing product) openItem;

  @override
  Widget build(BuildContext context) {
    if (dummyData.isEmpty) {
      return Center(
        child: Text(
          'No items available.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.80, // Adjusted aspect ratio for a better fit
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        return Item(
          currproduct: dummyData[index],
          openItem: openItem,
        );
      },
    );
  }
}
