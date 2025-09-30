
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:one_up_app/auth/login_screen.dart';
import 'package:one_up_app/main_ui/badge_listing_screen.dart';
import 'package:one_up_app/main_ui/create_event_screen.dart';
import 'package:one_up_app/main_ui/event_listing_screen.dart';
import 'package:one_up_app/main_ui/event_type_listing_screen.dart';
import 'package:one_up_app/main_ui/game_listing_screen.dart';
import 'package:one_up_app/main_ui/create_game_screen.dart';
import 'package:one_up_app/main_ui/edit_user_screen.dart';
import 'package:one_up_app/main_ui/manage_user_screen.dart';
import 'package:one_up_app/main_ui/profile/user_profile_screen.dart';
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

  late int _selectedIndex; // 👈 use late init

  @override
  void initState() {
    super.initState();
    AppPreferences.init();

    _selectedIndex = widget.selectedIndex; // 👈 use passed index
    _currentScreen = _getScreen(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = jsonDecode(AppPreferences.getUserSession());
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
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Image.asset(widget.isAdmin ? admin : user),
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
              /*_buildDrawerItem(
                  icon: Icons.settings,
                  title: "Settings",
                  index: 2,
                  screen: UserProfileScreen()),*/
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
        default:
          return ManageUserScreen();
      }
    } else {
      switch (index) {
        case 0:
          return HomeScreen();
        case 1:
          return UserProfileScreen();
        case 2:
          return UserProfileScreen(); // Settings placeholder
        default:
          return HomeScreen();
      }
    }
  }

  void _onMenuSelected(BuildContext context, String value) {
    if (value == 'profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfileScreen()),
      );
    } else if (value == 'logout') {
      logOutUser();
    }
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


