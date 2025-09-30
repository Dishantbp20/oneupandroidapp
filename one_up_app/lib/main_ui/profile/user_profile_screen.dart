import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:one_up_app/utils/app_preferences.dart';
import 'package:one_up_app/utils/colors.dart';
import 'package:one_up_app/utils/constants.dart';

import '../../utils/image_path.dart';
import '../../widgets/custom_app_bar.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppPreferences.init();
  }
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = jsonDecode(AppPreferences.getUserSession());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,fontFamily: 'Lato',
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        flexibleSpace: CustomAppBar(),
      ),
      body:
      Column(
        children: [
          // HEADER SECTION
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(userData['isAdmin']?admin:user), // Replace with your image
                ),
                SizedBox(height: 10),
                Text(
                  userData['playerId'],
                  style: TextStyle(color: Colors.white, fontSize: 16,fontFamily: 'Lato', fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // BODY SECTION
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                _buildDetailTile(Icons.person, "Name", userData['name']),
                _buildDetailTile(Icons.email, "Email", userData['email']),
                _buildDetailTile(Icons.cake, "Date of Birth", userData['dob']),
                _buildDetailTile(Icons.home, "Address", userData['address']),

                SizedBox(height: 20),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text("Logout", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    // TODO: Add logout logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Logged out")),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info, color: Colors.blue),
                  title: Text("About Application"),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "One up App",
                      applicationVersion: "App version: $version",
                      applicationLegalese: "© 2025 MyCompany",
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
  // Reusable Tile Widget
  Widget _buildDetailTile(IconData icon, String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
