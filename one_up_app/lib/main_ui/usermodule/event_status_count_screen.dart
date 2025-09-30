import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/main_ui/usermodule/user_events_listing.dart';

import '../../api_service/api_end_points.dart';
import '../../api_service/api_response.dart';
import '../../api_service/dio_client.dart';
import '../../api_service/web_client.dart';
import '../../utils/app_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/common_utilies.dart';
import '../../widgets/custom_app_bar.dart';

class EventStatusCountScreen extends StatefulWidget {
  final String id;
  const EventStatusCountScreen({super.key, required this.id});

  @override
  State<EventStatusCountScreen> createState() => _EventStatusCountScreenState();
}

class _EventStatusCountScreenState extends State<EventStatusCountScreen> {
  bool isLoading = false;
  bool hasError = false;

  int upcomingEventCount = 0;
  int ongoingEventCount = 0;
  int completedEventCount = 0;

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    _fetchEventStatusCounts();
  }

  Future<void> _fetchEventStatusCounts() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.eventStatusCountEndPoint + widget.id,
        method: MethodType.get,
      );

      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];
          setState(() {
            completedEventCount = data['Completed'] ?? 0;
            ongoingEventCount = data['Ongoing'] ?? 0;
            // upcomingEventCount = data['Upcoming'] ?? 0;
          });
        } else {
          hasError = true;
          CommonUtilities.showAlertDialog(
            context,
            message: response.data['message'] ?? "Unexpected error",
            icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
          );
        }
      } else {
        hasError = true;
        CommonUtilities.showAlertDialog(
          context,
          message: response.data['message'] ?? "Server error",
          icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
        );
      }
    } catch (e) {
      log("❌ Error: ${e.toString()}");
      hasError = true;
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusList = [
      {
        "title": "Active Registration",
        "count": ongoingEventCount,
        "colors": AppColors.getRedColor(),
        "icon": Icons.event_note,
      },
      {
        "title": "Completed Events",
        "count": completedEventCount,
        "colors": AppColors.getGreenColor(),
        "icon": Icons.event_available_rounded,
      }
      /*{
        "title": "Upcoming Events",
        "count": upcomingEventCount,
        "colors": AppColors.getBlueColor(),
        "icon": Icons.,
      },*/
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Event Status",
          style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Lato'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: const CustomAppBar(),
      ),
      body: isLoading
          ?  Center(child: Lottie.asset(
        'assets/animations/loader.json',
        width: 120,
        height: 120,
        repeat: true,
      ),)
          : hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 10),
            const Text("Failed to load event status"),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchEventStatusCounts,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      )
          : statusList.every((item) => item["count"] == 0)
          ? const Center(child: Text("No event status data available"))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: statusList.length,
        itemBuilder: (context, index) {
          final item = statusList[index];
          return _buildDetailTile(
            item["title"] as String,
            item["count"] as int,
            item["colors"] as List<Color>,
            icon: item["icon"] as IconData?,
          );
        },
      ),
    );
  }

  Widget _buildDetailTile(
      String title,
      int count,
      List<Color> bgColor, {
        IconData? icon,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserEventsListing(id: widget.id,eventStatus:title.contains("Active") ?  "Active Registration" : "Completed"),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColor,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(3, 5),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            if (icon != null)
              Positioned(
                right: -12,
                bottom: -12,
                child: Icon(
                  icon,
                  size: 75,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      "$count",
                      key: ValueKey<int>(count),
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
