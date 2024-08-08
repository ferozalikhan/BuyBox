// This file contains the detail card widget which is used to display the details of the product in the product detail screen.

import 'package:buybox/models/product.dart';
import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  const DetailCard({Key? key, required this.currproduct}) : super(key: key);
  final ProductListing currproduct;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(
              currproduct.description,
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyText1!.color),
            ),
            const Divider(
              height: 24,
              thickness: 1,
              color: Colors.grey,
            ),
            _buildInfoRow(
                "Condition", currproduct.condition.name.toUpperCase()),
            _buildInfoRow("Category", currproduct.category.name.toUpperCase()),
            _buildInfoRow("Status", currproduct.status.name.toUpperCase()),
            _buildInfoRow(
                "Transmission", currproduct.transType.name.toUpperCase()),
            _buildInfoRow("Fuel Type", currproduct.fuelType.name.toUpperCase()),
            _buildInfoRow("Price", "\$${currproduct.price}"),
            _buildInfoRow("Year", "${currproduct.year}"),
            _buildInfoRow("Mileage", "${currproduct.mileage} miles"),
            _buildInfoRow("Owners", "${currproduct.owner}"),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Color", style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  width: 36,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: currproduct.color,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
          Text(value),
        ],
      ),
    );
  }
}
