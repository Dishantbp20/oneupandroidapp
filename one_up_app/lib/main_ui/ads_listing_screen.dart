import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/list_item_layout/list_item_ad.dart';
import 'package:one_up_app/main_ui/create_ads_screen.dart';
import 'package:one_up_app/model/ad_details.dart';

import '../api_service/api_end_points.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/app_preferences.dart';
import '../utils/colors.dart';
import '../utils/common_utilies.dart';

class AdsListingScreen extends StatefulWidget {
  const AdsListingScreen({super.key});

  @override
  State<AdsListingScreen> createState() => _AdsListingScreenState();
}

class _AdsListingScreenState extends State<AdsListingScreen> {
  
  List<AdDetailsModel> adsDetails = [];
  List<AdDetailsModel> filteredAdsList = [];

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
    _fetchAds(); // Load first page
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
                        hintText: "Search Ads...",
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
                              const CreateAdsScreen(isEdit: false, id: "")));
                      // Handle add button press
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _fetchAds(refresh: true);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredAdsList.length + 1,
                    itemBuilder: (context, index) {
                      if (index < filteredAdsList.length) {
                        return ListItemAd(
                          adDetails: filteredAdsList[index],
                          onDelete: () {
                            _fetchAds(refresh: true); // reload from page 1
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
                                : const Text("No more ads"),
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
      _fetchAds(); // Load next page
    }
  }
  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredAdsList = List.from(adsDetails);
      } else {
        filteredAdsList = adsDetails.where((item) {
          return item.adName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }
  Future<void> _fetchAds({bool refresh = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (refresh) {
        currentPage = 1;
        adsDetails.clear();
        filteredAdsList.clear();
        hasMore = true;
      }
    });

    Map<String, dynamic> query = {"page": currentPage, "perPage": pageSize};
    try {
      final response = await DioClient().request(
          path: ApiEndPoints.getAdList,
          method: MethodType.get,
          queryParameters: query);

      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];
          final List<dynamic> badgeListJson = data['AddDetails'];

          List<AdDetailsModel> newBadges = badgeListJson
              .map((json) => AdDetailsModel.fromJson(json))
              .toList();

          setState(() {
            if (newBadges.isNotEmpty) {
              adsDetails
                  .addAll(newBadges.reversed); // ✅ Append instead of replace
              filteredAdsList = List.from(adsDetails);
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
