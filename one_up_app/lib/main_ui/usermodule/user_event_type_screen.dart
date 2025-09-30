import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/main_ui/usermodule/user_events_listing.dart';
import 'package:one_up_app/utils/image_path.dart';
import '../../api_service/api_end_points.dart';
import '../../api_service/api_response.dart';
import '../../api_service/dio_client.dart';
import '../../api_service/web_client.dart';
import '../../model/event_type_details_model.dart';
import '../../utils/app_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/common_utilies.dart';
import 'event_status_count_screen.dart';

class UserEventTypeScreen extends StatefulWidget {
  const UserEventTypeScreen({super.key});

  @override
  State<UserEventTypeScreen> createState() => _UserEventTypeScreenState();
}

class _UserEventTypeScreenState extends State<UserEventTypeScreen> {
  List<EventTypeDetailsModel> eventDetails = [];
  bool isLoading = false; // initial loader
  bool isLoadingMore = false; // pagination loader
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    _fetchEventTypes(initialLoad: true);
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
      _fetchEventTypes();
    }
  }

  Future<void> _fetchEventTypes({bool refresh = false, bool initialLoad = false}) async {
    if (initialLoad) {
      setState(() => isLoading = true);
    } else {
      setState(() => isLoadingMore = true);
    }

    if (refresh) {
      currentPage = 1;
      eventDetails.clear();
      hasMore = true;
    }

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getEventTypeListEndPoint,
        method: MethodType.get,
        queryParameters: {
          "page": currentPage,
          "perPage": pageSize,
        },
      );

      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final List<dynamic> eventTypeListJson =
          response.data['data']['EventTypeDetails'];

          List<EventTypeDetailsModel> newItems = eventTypeListJson
              .map((json) => EventTypeDetailsModel.fromJson(json))
              .toList();

          setState(() {
            if (refresh || initialLoad) {
              eventDetails = newItems;
            } else {
              eventDetails.addAll(newItems);
            }

            if (newItems.isNotEmpty) currentPage++;
            if (newItems.length < pageSize) hasMore = false;
          });
        } else {
          _showError(response.data['message']);
        }
      } else {
        _showError(response.data['message']);
      }
    } catch (e) {
      log("❌ Error: ${e.toString()}");
      _showError("Something went wrong!");
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _showError(String message) {
    CommonUtilities.showAlertDialog(
      context,
      message: message,
      icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return  Center(child: Lottie.asset(
        'assets/animations/loader.json',
        width: 120,
        height: 120,
        repeat: true,
      ),);
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _fetchEventTypes(refresh: true, initialLoad: true),
            child: eventDetails.isEmpty
                ? const Center(child: Text("No event types found"))
                : GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              padding: const EdgeInsets.all(16),
              itemCount: eventDetails.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < eventDetails.length) {
                  return _buildDetailTile(
                    eventDetails[index].id,
                    eventDetails[index].eventTypeName,
                    icon: Icons.emoji_events,
                  );
                } else {
                  return  Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Lottie.asset(
        'assets/animations/loader.json',
        width: 120,
        height: 120,
        repeat: true,
      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTile(String id, String title, {IconData? icon}) {
    bool isUpcoming = title.contains("Upcoming");
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isUpcoming ? UserEventsListing(id: id,eventStatus: "Upcoming") :EventStatusCountScreen(id: id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isUpcoming ? AppColors.getGradientColor():AppColors.getTileColor(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
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
              Align(
                alignment: Alignment.center,
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(image: AssetImage(isUpcoming? upcomingevent:event),width: 48,height: 48,),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black38,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )    
                
              ),
            ],
          ),
        ),
      ),
    );
  }
}
