import 'package:flutter/material.dart';
import 'package:buybox/models/product.dart';

class CustomDropDownButtons extends StatefulWidget {
  CustomDropDownButtons({
    super.key,
    required this.onCategoryChanged,
    required this.onConditionChanged,
    required this.selectedCategory,
    required this.selectedCondition,
  });
  final Function(Category) onCategoryChanged;
  final Function(Condition) onConditionChanged;
  Category selectedCategory;
  Condition selectedCondition;
  @override
  State<CustomDropDownButtons> createState() => _CustomDropDownButtonsState();
}

class _CustomDropDownButtonsState extends State<CustomDropDownButtons> {
  Icon _getConditionIcon(Condition condition) {
    switch (condition) {
      case Condition.excellent:
        return const Icon(Icons.check_circle, color: Colors.green);
      case Condition.good:
        return const Icon(Icons.check_circle_outline, color: Colors.blue);
      case Condition.fair:
        return const Icon(Icons.info, color: Colors.orange);
      case Condition.poor:
        return const Icon(Icons.warning, color: Colors.red);
      case Condition.damaged:
        return const Icon(Icons.error, color: Colors.brown);
    }
  }

  Icon _getCategoryIcon(Category category) {
    switch (category) {
      case Category.autoparts:
        return const Icon(Icons.build_outlined);
      case Category.vehicle:
        return const Icon(Icons.directions_car);
      case Category.suv:
        return const Icon(Icons.directions_car_filled_outlined);
      case Category.truck:
        return const Icon(Icons.local_shipping_outlined);
      case Category.motorcycle:
        return const Icon(Icons.motorcycle_outlined);
      case Category.boat:
        return const Icon(Icons.directions_boat_outlined);
      case Category.other:
        return const Icon(Icons.category_outlined);
      default:
        return const Icon(
            Icons.help_outline); // Default icon if none of the cases match
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
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
            child: DropdownButtonFormField<Category>(
              value: widget.selectedCategory,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1!.color,
                fontSize: 16.0,
              ),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
              ),
              items: Category.values.map((category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Row(
                    children: [
                      category == Category.other
                          ? const Icon(Icons.category_outlined)
                          : _getCategoryIcon(category),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        category.toString().split('.').last.toUpperCase(),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    widget.selectedCategory = value;
                    widget.onCategoryChanged(value);
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
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
            child: DropdownButtonFormField<Condition>(
              value: widget.selectedCondition,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1!.color,
                fontSize: 16.0,
              ),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
              ),
              items: Condition.values.map((condition) {
                return DropdownMenuItem<Condition>(
                  value: condition,
                  child: Row(
                    children: [
                      _getConditionIcon(condition),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        condition.toString().split('.').last.toUpperCase(),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    widget.selectedCondition = value;
                    widget.onConditionChanged(value);
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
