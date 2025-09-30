import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/list_item_layout/list_item_badge_details.dart';
import 'package:one_up_app/main_ui/create_badges_screen.dart';
import 'package:one_up_app/model/badge_detail_model.dart';

import '../api_service/api_end_points.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/app_preferences.dart';
import '../utils/colors.dart';
import '../utils/common_utilies.dart';

class BadgeListingScreen extends StatefulWidget {
  const BadgeListingScreen({super.key});

  @override
  State<BadgeListingScreen> createState() => _BadgeListingScreenState();
}

class _BadgeListingScreenState extends State<BadgeListingScreen> {
  List<BadgeDetailsModel> badgeDetails = [];
  List<BadgeDetailsModel> filteredBadgeList = [];
  bool isLoading = false; // API loading
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchBadges(); // Load first page
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    const BoxShadow(
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
                    hintText: "Search Badge...",
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onChanged: _filterList,
                ),
              ),
            ),
            const SizedBox(width: 10), // spacing
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryColor, // button background
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const CreateBadgesScreen(isEdit: false, id: "")));
                  // Handle add button press
                },
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _fetchBadges(refresh: true);
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: filteredBadgeList.length + 1,
                itemBuilder: (context, index) {
                  if (index < filteredBadgeList.length) {
                    return ListItemBadgeDetails(
                      badgeDetails: filteredBadgeList[index],
                      onDelete: () {
                        _fetchBadges(refresh: true); // reload from page 1
                      },
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: hasMore
                            ? Lottie.asset(
                                'assets/animations/loader.json',
                                width: 120,
                                height: 120,
                                repeat: true,
                              )
                            : const Text("No more badges"),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore) {
      _fetchBadges(); // Load next page
    }
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBadgeList = List.from(badgeDetails);
      } else {
        filteredBadgeList = badgeDetails.where((item) {
          return item.bedgeName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _fetchBadges({bool refresh = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (refresh) {
        currentPage = 1;
        badgeDetails.clear();
        filteredBadgeList.clear();
        hasMore = true;
      }
    });

    Map<String, dynamic> query = {"page": currentPage, "perPage": pageSize};
    try {
      final response = await DioClient().request(
          path: ApiEndPoints.getBadgeListEndPoint,
          method: MethodType.get,
          queryParameters: query);

      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];
          final List<dynamic> badgeListJson = data['BedgeDetails'];

          List<BadgeDetailsModel> newBadges = badgeListJson
              .map((json) => BadgeDetailsModel.fromJson(json))
              .toList();

          setState(() {
            if (newBadges.isNotEmpty) {
              badgeDetails
                  .addAll(newBadges.reversed); // ✅ Append instead of replace
              filteredBadgeList = List.from(badgeDetails);
              currentPage++; // ✅ Increment page
            }

            if (newBadges.length < pageSize) {
              hasMore = false; // No more data
            }
          });
        } else {
          CommonUtilities.showAlertDialog(context,
              message: response.data['message'],
              icon:
                  const Icon(Icons.warning_amber, color: Colors.red, size: 50));
        }
      } else {
        CommonUtilities.showAlertDialog(context,
            message: response.data['message'],
            icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50));
      }
    } catch (e) {
      log("Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
