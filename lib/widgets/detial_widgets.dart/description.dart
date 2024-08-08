// Description: Description card widget for product details

import 'package:buybox/models/product.dart';
import 'package:flutter/material.dart';

class DescriptionCard extends StatelessWidget {
  const DescriptionCard({super.key, required this.currproduct});
  final ProductListing currproduct;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 4,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [Text(currproduct.description)],
          )),
    );
  }
}
