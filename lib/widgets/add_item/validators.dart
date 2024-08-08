String? _validateTitle(String? value) {
  if (value == null || value.isEmpty) {
    return 'Title is required';
  }
  return null;
}

String? _validatePrice(String? value) {
  if (value == null || value.isEmpty) {
    return 'Price is required';
  }
  if (double.tryParse(value) == null) {
    return 'Price must be a valid number';
  }
  return null;
}

String? _validateMileage(String? value) {
  if (value == null || value.isEmpty) {
    return 'Mileage is required';
  }
  if (int.tryParse(value) == null) {
    return 'Mileage must be a valid number';
  }
  return null;
}

String? _validateVehicleModel(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vehicle Model is required';
  }
  return null;
}

String? _validateOwners(String? value) {
  if (value == null || value.isEmpty) {
    return 'Number of Owners is required';
  }
  if (int.tryParse(value) == null) {
    return 'Number of Owners must be a valid number';
  }
  return null;
}

String? _validateDescription(String? value) {
  if (value == null || value.isEmpty) {
    return 'Description is required';
  }
  return null;
}
