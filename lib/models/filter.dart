import 'package:buybox/models/product.dart';

// ****************************************************************************************************
// FilterCriteria class is used to store the filter criteria selected by the user.
// It has properties for category, condition, fuel type, price range, year range, mileage, transmission type, and location range.
// The isEmpty property is used to check if the filter criteria is empty.
// The FilterCriteria class is used in the ProductRepository class to filter the products based on the selected criteria.
// ****************************************************************************************************

class FilterCriteria {
  Category? category;
  Condition? condition;
  FuelType? fuelType;
  int? minPrice;
  int? maxPrice;
  int? minYear;
  int? maxYear;
  int? mileage;
  TransmissionType? transmissionType;
  int? locationRange; // Range in miles for location filter

  FilterCriteria({
    this.category,
    this.condition,
    this.fuelType,
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.mileage,
    this.transmissionType,
    this.locationRange,
  });
  bool get isEmpty {
    return category == null &&
        condition == null &&
        transmissionType == null &&
        fuelType == null &&
        minPrice == 0 &&
        maxPrice == null &&
        minYear == 0 &&
        maxYear == null &&
        mileage == null &&
        locationRange == null;
  }
}
