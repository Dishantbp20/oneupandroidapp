import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/api_service/api_response.dart';
import 'package:one_up_app/list_item_layout/list_item_manage_user.dart';
import 'package:one_up_app/model/user_list_data.dart';
import 'package:one_up_app/utils/colors.dart';

import '../api_service/api_end_points.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/app_preferences.dart';
import '../utils/common_utilies.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({super.key});

  @override
  State<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  late Future<void> _eventFuture;
  late ApiResponse apiResponse;

  List<UserListData> users = [];
  List<UserListData> filteredUserList = [];

  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    _eventFuture = getUserListData(page: 1);

    // Listen for scroll events
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        loadMoreUsers();
      }
    });
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUserList = users;
      } else {
        filteredUserList = users
            .where((item) =>
                item.name.toLowerCase().contains(query.toLowerCase()) ||
                item.playerId.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> loadMoreUsers() async {
    setState(() => isLoadingMore = true);
    currentPage++;
    await getUserListData(page: currentPage, isLoadMore: true);
    setState(() => isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = jsonDecode(AppPreferences.getUserSession());
    return FutureBuilder(
      future: _eventFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            users.isEmpty) {
          return Center(
            child: Lottie.asset(
              'assets/animations/loader.json',
              width: 120,
              height: 120,
              repeat: true,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                // 🔍 Search box
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: Colors.white),
                      hintText: "Search User...",
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                    onChanged: _filterList,
                  ),
                ),
                const SizedBox(height: 20),

                // 📜 User list with pagination
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        filteredUserList.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == filteredUserList.length) {
                        return Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(
                            child: Lottie.asset(
                              'assets/animations/loader.json',
                              width: 120,
                              height: 120,
                              repeat: true,
                            ),
                          ),
                        );
                      }
                      return ListItemManageUser(
                        user: filteredUserList[index],
                        onDelete: () {
                          setState(() {
                            _eventFuture = getUserListData(page: 1);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> getUserListData({int page = 1, bool isLoadMore = false}) async {
    Map<String, dynamic> query = {"page": page, "perPage": 10};

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getUserListEndPoint,
        method: MethodType.get,
        queryParameters: query,
      );

      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];
          final List<dynamic> userListJson = data['userData'];

          List<UserListData> userList =
              userListJson.map((json) => UserListData.fromJson(json)).toList();

          setState(() {
            if (isLoadMore) {
              users.addAll(userList);
            } else {
              users = userList;
            }
            filteredUserList = users;

            hasMore = userList.isNotEmpty; // if empty → no more pages
          });
        } else {
          CommonUtilities.showAlertDialog(
            context,
            message: response.data['message'],
            icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
          );
        }
      } else {
        CommonUtilities.showAlertDialog(
          context,
          message: response.data['message'],
          icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
        );
      }
    } catch (e) {
      log("Error: ${e.toString()}");
    }
  }
}
