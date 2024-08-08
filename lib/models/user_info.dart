// **************************************************************************
// Summary: This file contains the user data model.
// The UserData class is used to store the user data.
// It has properties for userId, username, email, profilePictureUrl, favoriteListingIds, and postedListingIds.
// The UserData class is used in the UserRepository class to store the user data.
// **************************************************************************

class UserData {
  String userId;
  String username;
  String email;
  String profilePictureUrl;
  List<String> favoriteListingIds; // IDs of the listings marked as favorites
  final List<String> postedListingIds; // IDs of the listings posted by the user
  // final String currentLocation; // New attribute for the user's current location

  UserData({
    required this.userId,
    required this.username,
    required this.email,
    required this.profilePictureUrl,
    //required this.currentLocation, // Initialize the current location
  })  : favoriteListingIds = [],
        postedListingIds = [];

  // methods to be added....
  // 1. update the postedListingIds whenever new listing has be posted
  // 2. edit , update any change to userinfo that has been made by user
  // 3.
  // to map method
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'favoriteListingIds': favoriteListingIds,
      'postedListingIds': postedListingIds,
      // 'currentLocation': currentLocation,
    };
  }
}
