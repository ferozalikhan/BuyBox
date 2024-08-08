// This file contains the main drawer widget
// The main drawer widget displays the app logo and a list of options for the user
// The main drawer widget uses the LoginScreen, MyListingScreen, MyMessagesScreen, ProfileScreen, and SavedItemsScreen classes

import 'package:buybox/screens/login.dart';
import 'package:buybox/screens/my_listing.dart';
import 'package:buybox/screens/my_messages.dart';
import 'package:buybox/screens/profile.dart';
import 'package:buybox/screens/saved_items.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import the fucntion to get unread message count
import 'package:buybox/models/message.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    Key? key,
    required this.isLogedin,
    required this.onThemeModeChange,
  }) : super(key: key);

  final bool isLogedin;
  final Function(bool darkMode) onThemeModeChange;

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,

            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            alignment: Alignment.centerLeft,
            // display the app logo
            child: Image.asset(
              'assets/app_logo2.png',
              fit: BoxFit.fitHeight,
              alignment: Alignment.centerRight,
            ),
          ),
          widget.isLogedin
              ? Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.bookmark,
                        size: 26,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      title: Text(
                        "Saved Items",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const SavedItemsScreen(),
                        ));
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.list,
                        size: 26,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      title: Text(
                        "My Listings",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const MyListingScreen(),
                        ));
                      },
                    ),
                    // add a new list tile for my messages screen
                    ListTile(
                      leading: Icon(
                        Icons.message,
                        size: 26,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      title: Text(
                        "My Messages",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      onTap: () async {
                        // Navigate to my messages screen
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => MyMessagesScreen(),
                        ));
                      },
                      // display unread message count

                      trailing: StreamBuilder(
                        stream: getUnreadMessageCountStream(
                            FirebaseAuth.instance.currentUser!.uid),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // return ... if the data is still loading
                            return SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            );
                          }
                          // if count is 0, return an empty container
                          if (snapshot.data == 0) {
                            return SizedBox();
                          }
                          return CircleAvatar(
                            radius: 15,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            child: Text(
                              snapshot.data.toString(),
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        size: 26,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      title: Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const ProfileScreen(),
                        ));
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.logout,
                        size: 26,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      title: Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      onTap: () {
                        // Logout the user
                        FirebaseAuth.instance.signOut();
                      },
                    ),
                  ],
                )
              : Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.login,
                        size: 26,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      title: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      onTap: () {
                        // Navigate to login screen
                        // Navigate to register screen
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => const LoginScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.person_add,
                        size: 26,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      title: Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      onTap: () {
                        // Navigate to register screen
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => const LoginScreen(
                                  isLogin: false,
                                ))); // isLogin is false for register
                      },
                    ),
                  ],
                ),
          Divider(),

          // Add about us and contact us
          ListTile(
            leading: Icon(
              Icons.info,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              "About Us",
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            onTap: () {
              // Navigate to about us screen or add about us functionality
            },
          ),
          ListTile(
            leading: Icon(
              Icons.contact_support,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            onTap: () {
              // Navigate to contact us screen or add contact us functionality
            },
          ),
          // another one for privacy policy
          ListTile(
            leading: Icon(
              Icons.privacy_tip,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            onTap: () {
              // Navigate to privacy policy screen or add privacy policy functionality
            },
          ),
          // divider
          Divider(),

          // display the theme switcher
          SwitchListTile(
            title: Text(
              "Dark Mode",
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              widget.onThemeModeChange(value);
            },
          ),
        ],
      ),
    );
  }
}
