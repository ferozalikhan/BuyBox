// This file contains the FilterDialog widget which is a dialog that allows the user to filter the products based on price, vehicle details, year range, and location range.

import 'package:buybox/models/filter.dart';
import 'package:buybox/models/product.dart';
import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final FilterCriteria initialCriteria;

  const FilterDialog({Key? key, required this.initialCriteria})
      : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late FilterCriteria criteria;
// lets create a key for the form
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    criteria = widget.initialCriteria;
  }

  // reset the form
  void resetForm() {
    setState(() {
      criteria = FilterCriteria();
    });
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: EdgeInsets.symmetric(horizontal: 13.0, vertical: 8),
      title: Text('Filter'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Price Range'),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceRangeFields(),
                ],
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            SizedBox(height: 15.0),
            _buildSectionHeader('Vehicle Details'),
            _buildVehicleDetailFields(),
            SizedBox(height: 15.0),
            _buildSectionHeader('Year Range'),
            _buildYearRangeFields(),
            SizedBox(height: 15.0),
            _buildSectionHeader('Location Range'),
            _buildLocationRangeField(),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(null); // Cancel button
          },
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).errorColor,
            onPrimary: Colors.white,
          ),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              resetForm();
            });
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
          ),
          child: Text('Reset'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(criteria); // Apply button
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
            onPrimary: Colors.white,
          ),
          child: Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
      ),
    );
  }

  Widget _buildPriceRangeFields() {
    return Column(
      children: [
        // Minimum Price TextFormField
        TextFormField(
          initialValue: criteria.minPrice?.toString() ?? '',
          decoration: InputDecoration(
            labelText: 'Min Price',
            prefixIcon: Icon(Icons.attach_money),
            labelStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyText1!.color,
              fontSize: 16.0,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            criteria.minPrice = int.tryParse(value);
          },
        ),

        SizedBox(height: 16.0),

        // Maximum Price TextFormField
        TextFormField(
          initialValue: criteria.maxPrice?.toString() ?? '',
          decoration: InputDecoration(
            labelText: 'Max Price',
            prefixIcon: Icon(Icons.attach_money),
            labelStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyText1!.color,
              fontSize: 16.0,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            criteria.maxPrice = int.tryParse(value);
          },
        ),
      ],
    );
  }

  Widget _buildVehicleDetailFields() {
    return Column(
      children: [
        // Category DropdownButtonFormField
        DropdownButtonFormField<Category>(
          value: criteria.category,
          decoration: InputDecoration(
            labelText: 'Category',
            labelStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyText1!.color,
              fontSize: 16.0,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
          ),
          items: Category.values.map((Category category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Text(category
                  .toString()
                  .substring(category.toString().indexOf('.') + 1)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              criteria.category = value!;
            });
          },
        ),

        SizedBox(height: 16.0),

        // Condition DropdownButtonFormField
        DropdownButtonFormField<Condition>(
          value: criteria.condition,
          decoration: InputDecoration(
            labelText: 'Condition',
            labelStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyText1!.color,
              fontSize: 16.0,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
          ),
          items: Condition.values.map((Condition condition) {
            return DropdownMenuItem<Condition>(
              value: condition,
              child: Text(condition
                  .toString()
                  .substring(condition.toString().indexOf('.') + 1)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              criteria.condition = value!;
            });
          },
        ),

        SizedBox(height: 16.0),

        // FuelType DropdownButtonFormField
        DropdownButtonFormField<FuelType>(
          value: criteria.fuelType,
          decoration: InputDecoration(
            labelText: 'Fuel Type',
            labelStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyText1!.color,
              fontSize: 16.0,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
          ),
          items: FuelType.values.map((FuelType fuelType) {
            return DropdownMenuItem<FuelType>(
              value: fuelType,
              child: Text(fuelType
                  .toString()
                  .substring(fuelType.toString().indexOf('.') + 1)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              criteria.fuelType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildYearRangeFields() {
    return Column(
      children: [
        // Year Range using RangeSlider
        RangeSlider(
          values: RangeValues(
            criteria.minYear?.toDouble() ?? 1900,
            criteria.maxYear?.toDouble() ?? DateTime.now().year.toDouble(),
          ),
          min: 1900,
          max: DateTime.now().year.toDouble(),
          divisions: DateTime.now().year - 1900,
          labels: RangeLabels(
            criteria.minYear?.toString() ?? '1900',
            criteria.maxYear?.toString() ?? DateTime.now().year.toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              criteria.minYear = values.start.toInt();
              criteria.maxYear = values.end.toInt();
            });
          },
        ),
        SizedBox(height: 8.0),
        Text(
          criteria.minYear == null && criteria.maxYear == null
              ? 'Year Range: All'
              : 'Year Range: ${criteria.minYear} - ${criteria.maxYear}',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1!.color,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRangeField() {
    return Column(
      children: [
        // Location Range Slider
        Slider(
          value: (criteria.locationRange ?? 0).toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: criteria.locationRange?.toString(),
          onChanged: (value) {
            setState(() {
              criteria.locationRange = value.toInt();
            });
          },
        ),
        SizedBox(height: 8.0),
        Text(
          criteria.locationRange == null
              ? 'Location Range: All'
              : 'Location Range: ${criteria.locationRange} miles',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1!.color,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}
