import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/utils/image_path.dart';

import '../../api_service/api_end_points.dart';
import '../../api_service/dio_client.dart';
import '../../api_service/web_client.dart';
import '../../model/badge_detail_model.dart';
import '../../utils/app_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/common_utilies.dart';

class UserBadgesListScreen extends StatefulWidget {
  final String id;
  const UserBadgesListScreen({super.key, required this.id});

  @override
  State<UserBadgesListScreen> createState() => _UserBadgesListScreenState();
}

class _UserBadgesListScreenState extends State<UserBadgesListScreen> {

  List<BadgeDetailsModel> badgeDetails = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;

  String activeBadge = "";

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    _fetchBadgeTypes(initialLoad: true);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMore) {
      _fetchBadgeTypes();
    }
  }

  void _showError(String message) {
    CommonUtilities.showAlertDialog(
      context,
      message: message,
      icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
    );
  }

  // -------------------------------------------------------------------------
  // ✔ API CALL — SET ACTIVE BADGE
  // -------------------------------------------------------------------------
  Future<void> _setActiveBadge(String badgeId) async {
    _removeActiveBadge();
  }
  Future<void> _callActiveBadge(String badgeId, bool isActive) async {
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getActiveBadgeEndPoint, // /active-bedge
        method: MethodType.patch,
        payload: {
          "bedgeId": badgeId,
          "isActive": isActive,
        },
      );

      log("Set Active Badge Response: ${response.data}");

      if (response.data['status'] == 200) {
        if(!isActive){
          _callActiveBadge(badgeId, true);
        }else{
          setState(() {
            activeBadge = badgeId;
          });
        }

      } else {
        // _showError(response.data["message"]);
      }

    } catch (e) {
      log("❌ Failed to activate badge: $e");
      _showError("Failed to set badge active!");
    }
  }
  Future<void> _removeActiveBadge() async {
    for(int i = 0; i<=badgeDetails.length; i++ ){
      _callActiveBadge(badgeDetails.elementAt(i).id, false);
    }
  }

  // -------------------------------------------------------------------------
  // ✔ FETCH BADGES WITH PAGINATION
  // -------------------------------------------------------------------------
  Future<void> _fetchBadgeTypes({bool refresh = false, bool initialLoad = false}) async {
    if (initialLoad) {
      setState(() => isLoading = true);
    } else {
      setState(() => isLoadingMore = true);
    }

    if (refresh) {
      currentPage = 1;
      badgeDetails.clear();
      hasMore = true;
    }

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getBadgesOfUsersEndPoint + widget.id,
        queryParameters: {
          "page": currentPage,
          "perPage": pageSize,
        },
        method: MethodType.get,
      );

      log("API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final List<dynamic> data = response.data['data'];

          List<BadgeDetailsModel> newItems = data.map((b) {
            return BadgeDetailsModel(
              id: b['bedgeId'],
              bedgeName: b['bedgeName'],
              image: b['image'],
              isActive: b['isActive'],
            );
          }).toList();

          setState(() {
            if (refresh || initialLoad) {
              badgeDetails = newItems;
            } else {
              badgeDetails.addAll(newItems);
            }

            if (newItems.isNotEmpty) currentPage++;
            if (newItems.length < pageSize) hasMore = false;

            // Set active badge ID if list contains active one
            final active = newItems.firstWhere(
                  (e) => e.isActive == true,
              orElse: () => BadgeDetailsModel(id: "", bedgeName: "", image: "", isActive: false),
            );

            if (active.id.isNotEmpty) {
              activeBadge = active.id;
            }
          });

        } else {
          _showError(response.data['message']);
        }
      } else {
        _showError(response.data['message']);
      }

    } catch (e) {
      log("Error: $e");
      _showError("Something went wrong!");
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  // -------------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
        child: Lottie.asset('assets/animations/loader.json', width: 120, height: 120))
        : Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _fetchBadgeTypes(refresh: true, initialLoad: true),
            child: badgeDetails.isEmpty
                ? const Center(child: Text("No badges found"))
                : GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              padding: const EdgeInsets.all(16),
              itemCount: badgeDetails.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < badgeDetails.length) {
                  return _buildDetailTile(
                    badgeDetails[index].id,
                    badgeDetails[index].bedgeName,
                    badgeDetails[index].image,
                    badgeDetails[index].isActive,
                    icon: Icons.emoji_events,
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Lottie.asset(
                        'assets/animations/loader.json',
                        width: 90,
                        height: 90,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        )
      ],
    );
  }

  // -------------------------------------------------------------------------
  // ✔ BADGE TILE UI
  // -------------------------------------------------------------------------
  Widget _buildDetailTile(String id, String title, String imageStr, bool isActive, {IconData? icon}) {
    return InkWell(
      onTap: () async {
        setState(() {
          activeBadge = id; // update UI immediately
        });

        await _setActiveBadge(id); // API Call
      },
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [

              // Background icon (decorative)
              if (icon != null)
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    icon,
                    size: 75,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),

              // ACTIVE BADGE GREEN TICK
              if (activeBadge == id)
                const Positioned(
                  top: 8,
                  left: 8,
                  child: Icon(Icons.check_circle, color: Colors.green, size: 24),
                ),

              // MAIN CONTENT
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // ---------------------------------------------------------
                    // 🚀 ROUND IMAGE ADDED
                    // ---------------------------------------------------------
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activeBadge == id ? Colors.green : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          imageStr,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            return ClipOval(
                              child: Image.asset(
                                badgeImage,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
