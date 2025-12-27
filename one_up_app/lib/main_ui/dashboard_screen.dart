import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:one_up_app/auth/login_screen.dart';
import 'package:one_up_app/main_ui/ads_listing_screen.dart';
import 'package:one_up_app/main_ui/badge_listing_screen.dart';
import 'package:one_up_app/main_ui/create_event_screen.dart';
import 'package:one_up_app/main_ui/event_listing_screen.dart';
import 'package:one_up_app/main_ui/event_type_listing_screen.dart';
import 'package:one_up_app/main_ui/game_listing_screen.dart';
import 'package:one_up_app/main_ui/create_game_screen.dart';
import 'package:one_up_app/main_ui/edit_user_screen.dart';
import 'package:one_up_app/main_ui/manage_user_screen.dart';
import 'package:one_up_app/main_ui/profile/user_profile_screen.dart';
import 'package:one_up_app/main_ui/usermodule/user_badges_list_screen.dart';
import 'package:one_up_app/main_ui/usermodule/user_event_type_screen.dart';
import 'package:one_up_app/utils/app_preferences.dart';
import 'package:one_up_app/utils/common_utilies.dart';
import 'package:one_up_app/utils/image_path.dart';
import 'package:one_up_app/widgets/app_drawer.dart';
import 'package:one_up_app/widgets/custom_app_bar.dart';
import 'package:one_up_app/widgets/styled_button.dart';

import '../api_service/api_end_points.dart';
import '../api_service/api_response.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/colors.dart';
import 'usermodule/home_screeen.dart';

class DashboardScreen extends StatefulWidget {
  final bool isAdmin;
  final int selectedIndex; // 👈 add this

  const DashboardScreen({
    super.key,
    required this.isAdmin,
    this.selectedIndex = 0, // default
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Widget _currentScreen;
  late ApiResponse apiResponse;
  String activeBadge = "";
  late int _selectedIndex; // 👈 use late init
  late Map<String, dynamic> user; // initialize in initState

  @override
  void initState() {
    super.initState();
    AppPreferences.init();

    // initialize user after AppPreferences.init()
    try {
      user = jsonDecode(AppPreferences.getUserSession());
    } catch (e) {
      // fallback to an empty map to avoid crashes
      user = {};
      log('Warning: failed to read user session: $e');
    }

    // call api that depends on user
    getUserListByIDData();

    _selectedIndex = widget.selectedIndex; // 👈 use passed index
    _currentScreen = _getScreen(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData;
    try {
      userData = jsonDecode(AppPreferences.getUserSession());
    } catch (e) {
      userData = user;
    }

    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isAdmin ? "Admin Dashboard" : "Dashboard",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Lato',
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.apps_sharp, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_suggest, color: Colors.white),
            onSelected: (value) => _onMenuSelected(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_pin, color: Colors.blue),
                    SizedBox(width: 8),
                    Text("View Profile", style:  TextStyle( fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Logout",  style:  TextStyle( fontSize: 13),),
                  ],
                ),
              ),
            ],
          ),
        ],
        flexibleSpace: CustomAppBar(),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.getGradientColor(),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        /*child: Image.asset(widget.isAdmin ? admin : user),*/child: Image.asset(admin ),
                      ),
                      Visibility(
                          visible: widget.isAdmin ? false : true,
                          child:
                          Row(
                            children: [
                              Image(image: AssetImage(badgeImage),height: 30,width: 30,),
                              Text(
                                activeBadge,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          )
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userData["name"],
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    "Player ID: ${userData["playerId"]}",
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),

            /// Admin-only menus
            if (widget.isAdmin) ...[
              _buildDrawerItem(
                  icon: Icons.manage_accounts,
                  title: "Manage Users",
                  index: 0,
                  screen: ManageUserScreen()),
              _buildDrawerItem(
                  icon: Icons.type_specimen,
                  title: "Event Type",
                  index: 1,
                  screen: EventTypeListingScreen()),
              _buildDrawerItem(
                  icon: Icons.event,
                  title: "Event Management",
                  index: 2,
                  screen: EventListingScreen()),
              _buildDrawerItem(
                  icon: Icons.videogame_asset,
                  title: "Game Creation",
                  index: 3,
                  screen: GameListingScreen()),
              _buildDrawerItem(
                  icon: Icons.badge,
                  title: "Badges Creation",
                  index: 4,
                  screen: BadgeListingScreen()),
              _buildDrawerItem(
                  icon: Icons.ad_units,
                  title: "Ads Listing",
                  index: 5,
                  screen: AdsListingScreen()),
            ],

            /// User-only menus
            if (!widget.isAdmin) ...[
              _buildDrawerItem(
                  icon: Icons.home,
                  title: "Home",
                  index: 0,
                  screen: HomeScreen()),
              _buildDrawerItem(
                  icon: Icons.event_sharp,
                  title: "Event Types",
                  index: 1,
                  screen: UserEventTypeScreen()),
              _buildDrawerItem(
                  icon: Icons.badge,
                  title: "My Badges",
                  index: 2,
                  screen: UserBadgesListScreen( id: user['userId'],)),
            ],

            SizedBox(height: height * 0.05),
          ],
        ),
      ),

      body: _currentScreen,
    );
  }

  /// Drawer item builder
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required Widget screen,
  }) {
    bool isSelected = _selectedIndex == index;

    return Container(
      color: isSelected ? Colors.blue.shade100 : Colors.transparent,
      child: ListTile(
        leading: Icon(icon,
            color: isSelected ? AppColors.primaryBlue : Colors.black),
        title: Text(
          title,
          style: TextStyle(
              color: isSelected ? AppColors.primaryBlue : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14
          ),
        ),
        selected: isSelected,
        onTap: () {
          setState(() {
            _selectedIndex = index;
            _currentScreen = screen;
          });
          Navigator.pop(context); // close drawer
        },
      ),
    );
  }

  Widget _getScreen(int index) {
    if (widget.isAdmin) {
      switch (index) {
        case 0:
          return ManageUserScreen();
        case 1:
          return EventTypeListingScreen();
        case 2:
          return EventListingScreen();
        case 3:
          return GameListingScreen();
        case 4:
          return BadgeListingScreen();
        case 5:
          return AdsListingScreen();
        default:
          return ManageUserScreen();
      }
    } else {
      switch (index) {
        case 0:
          return HomeScreen();
        case 1:
          return UserEventTypeScreen();
        case 2:
          return UserBadgesListScreen(id: user['userId']);
        default:
          return HomeScreen();
      }
    }
  }

  Future<void> getUserListByIDData() async {
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getUserByIdEndPoint + user['userId'],
        method: MethodType.get,
      );

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];

          setState(() {
            try {
              activeBadge = data['bedgeDetails']?['bedgeName'] ?? '';
            } catch (e) {
              activeBadge = '';
              log('Warning: unable to parse bedgeDetails: $e');
            }
          });
        }
      }
    } catch (e) {
      log("❌ getUserListByIDData() error: $e");
    }
  }

  void _onMenuSelected(BuildContext context, String value) {
    if (value == 'profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfileScreen()),
      );
    } else if (value == 'logout') {
      showLogoutConfirmationDialog(context);
    }
  }
  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            "Confirm Logout",
            style: TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(fontFamily: 'Lato'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // close dialog
              },
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.grey, fontFamily: 'Lato')),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // close dialog first
                logOutUser(); // call actual logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text("Logout",
                  style: TextStyle(fontFamily: 'Lato', fontSize: 14)),
            ),
          ],
        );
      },
    );
  }


  Future<void> logOutUser() async {
    CommonUtilities.showLoadingDialog(context);
    Map<String, dynamic> query = {"id": AppPreferences.getToken()};
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.logoutEndPoint,
        payload: query,
        method: MethodType.post,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });
      if (response.status == "200" || response.status == "201") {
        if (response.data["status"] == 200) {
          CommonUtilities.hideLoadingDialog(context);
          AppPreferences.clearPref(); // implement clear() in your preferences class

          // 2. Navigate to login and remove all previous screens
          Future.microtask(() {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          });
        } else {
          CommonUtilities.hideLoadingDialog(context);
          CommonUtilities.showAlertDialog(context,
              message: response.data['message'],
              icon: const Icon(Icons.warning_amber,
                  color: Colors.red, size: 50));
        }
      } else {
        CommonUtilities.hideLoadingDialog(context);
        CommonUtilities.showAlertDialog(context,
            message: response.data['message'],
            icon: const Icon(Icons.warning_amber,
                color: Colors.red, size: 50));
      }
    } catch (e) {
      log("Error: ${e.toString()}");
      CommonUtilities.hideLoadingDialog(context);
    }
  }
}
