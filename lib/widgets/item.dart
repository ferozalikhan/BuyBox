// This widget is used to display a single product item in the list of products

import 'package:flutter/material.dart';
import 'package:buybox/models/product.dart';

class Item extends StatelessWidget {
  final ProductListing currproduct;
  final void Function(ProductListing product) openItem;

  const Item({
    Key? key,
    required this.currproduct,
    required this.openItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openItem(currproduct),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        margin: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      currproduct.images_urls.isNotEmpty
                          ? currproduct.images_urls.first
                          : 'https://via.placeholder.com/150', // Placeholder image
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .cardColor
                              .withOpacity(0.7), // 80% opacity
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '\$${currproduct.price}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currproduct.title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1!.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Year: ${currproduct.year}',
                        style: TextStyle(
                          // pick a color that would be best for both light and dark theme
                          color: Theme.of(context).textTheme.bodyText1!.color,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '|',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${currproduct.mileage} Mi',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${currproduct.sellerLocation.city}, ${currproduct.sellerLocation.state}',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
