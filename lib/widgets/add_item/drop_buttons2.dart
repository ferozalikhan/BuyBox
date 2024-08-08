import 'package:flutter/material.dart';
import 'package:buybox/models/product.dart';

class CustomDropDownButtons2 extends StatefulWidget {
  CustomDropDownButtons2({
    Key? key,
    required this.onTransTypeChanged,
    required this.onFuelTypeChanged,
    required this.selectedTransType,
    required this.selectedFuelType,
  }) : super(key: key);

  final Function(TransmissionType) onTransTypeChanged;
  final Function(FuelType) onFuelTypeChanged;
  TransmissionType selectedTransType;
  FuelType selectedFuelType;

  @override
  State<CustomDropDownButtons2> createState() => _CustomDropDownButtonsState();
}

class _CustomDropDownButtonsState extends State<CustomDropDownButtons2> {
  Icon _getTransTypeIcon(TransmissionType transType) {
    switch (transType) {
      case TransmissionType.manual:
        return const Icon(Icons.settings_outlined);
      case TransmissionType.automatic:
        return const Icon(Icons.drive_eta_outlined);
      case TransmissionType.other:
        return const Icon(Icons.drive_file_rename_outline);
      // Add more cases for different TransmissionType values
      default:
        return const Icon(
            Icons.help_outline); // Default icon if none of the cases match
    }
  }

  Icon _getFuelTypeIcon(FuelType fuelType) {
    switch (fuelType) {
      case FuelType.gasoline:
        return const Icon(Icons.local_gas_station_outlined);
      case FuelType.diesel:
        return const Icon(Icons.local_shipping_outlined);
      case FuelType.electric:
        return const Icon(Icons.battery_charging_full_outlined);
      case FuelType.hybrid:
        return const Icon(Icons.eco_outlined);
      case FuelType.other:
        return const Icon(Icons.info_outline);
      // Add more cases for different FuelType values
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
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<TransmissionType>(
              value: widget.selectedTransType,
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
              items: TransmissionType.values.map((transType) {
                return DropdownMenuItem<TransmissionType>(
                  value: transType,
                  child: Row(
                    children: [
                      _getTransTypeIcon(transType),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        transType.toString().split('.').last.toUpperCase(),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    widget.selectedTransType = value;
                    widget.onTransTypeChanged(value);
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
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<FuelType>(
              value: widget.selectedFuelType,
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
              items: FuelType.values.map((fuelType) {
                return DropdownMenuItem<FuelType>(
                  value: fuelType,
                  child: Row(
                    children: [
                      _getFuelTypeIcon(fuelType),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        fuelType.toString().split('.').last.toUpperCase(),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    widget.selectedFuelType = value;
                    widget.onFuelTypeChanged(value);
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
