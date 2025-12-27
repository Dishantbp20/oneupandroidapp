import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../api_service/api_end_points.dart';
import '../../api_service/dio_client.dart';
import '../../api_service/web_client.dart';
import '../../model/event_details_model.dart';
import '../../utils/app_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/common_code.dart';
import '../../utils/common_utilies.dart';
import '../../utils/image_path.dart';
import 'user_events_listing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<EventDetailsModel> eventDetails = [];
  Map<String, dynamic>? dashboardData;
  bool isLoading = false;
  bool isDashboardLoading = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    _fetchDashboardAndEvents();
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
      _fetchRegisteredEvents();
    }
  }

  Future<void> _fetchDashboardAndEvents() async {
    setState(() {
      isDashboardLoading = true;
    });
    await getDashboardDetails();
    // await _fetchRegisteredEvents(initialLoad: true);
    setState(() {
      isDashboardLoading = false;
    });
  }

  Future<void> getDashboardDetails() async {
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getUserDashboard,
        method: MethodType.get,
      );

      log("✅ Dashboard Response: ${response.status} - ${response.message}");
      if (response.data['status'] == 200) {
        setState(() {
          dashboardData = response.data['data'];
        });
      } else {
        _showError(response.data['message']);
      }
    } catch (ex) {
      log("❌ Dashboard Error: ${ex.toString()}");
      _showError("Something went wrong!");
    }
  }

  Future<void> _fetchRegisteredEvents({
    bool refresh = false,
    bool initialLoad = false,
  }) async {
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
        path: ApiEndPoints.getUserRegisteredEventsEndPoint,
        method: MethodType.get,
      );

      log("✅ Registered Events Response: ${response.status} - ${response.message}");

      if (response.data['status'] == 200) {
        final List<dynamic> eventTypeListJson = response.data['data'];
        List<EventDetailsModel> newItems =
        eventTypeListJson.map((json) => EventDetailsModel.fromJson(json)).toList();

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
    Map<String, dynamic> userData = jsonDecode(AppPreferences.getUserSession());

    final upcomingEvents = dashboardData?['upcomingEvents']?['data'] ?? [];
    final adDetails = dashboardData?['adDetails'];
    final registrationEvents = dashboardData?['registrationEvents']?['data'] ?? [];

    return isDashboardLoading
        ? Center(
      child: Lottie.asset(
        'assets/animations/loader.json',
        width: 120,
        height: 120,
        repeat: true,
      ),
    )
        : Column(
      children: [
        _buildHeader(userData),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _fetchDashboardAndEvents();
            },
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                _buildDashboardSection(
                  upcomingEvents,
                  adDetails,
                  registrationEvents,
                ),
                /*const SizedBox(height: 10),
                _buildRegisteredEventsSection(),*/
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Map<String, dynamic> userData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20, right: 25, left: 25, top: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome ${userData["name"]}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lato',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stay organized with your upcoming events',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSection(
      List upcomingEvents,
      dynamic adDetails,
      List registrationEvents,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Dashboard",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Lato'),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _dashboardCard(
              "Upcoming Events",
              "${dashboardData?['upcomingEvents']?['count']}",
              Icons.event,
              (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserEventsListing(id: dashboardData?['upcomingEvents']['id'],eventStatus: "Upcoming"),
                  ),
                );
              },
            ),
            _dashboardCard(
                "Registration",
                "${registrationEvents.length}",
                Icons.how_to_reg,
                (){}
            ),
            // _dashboardCard("Ads", adDetails != null ? "1" : "0", Icons.campaign),
          ],
        ),
        const SizedBox(height: 16),
        if (adDetails != null) _buildAdCard(adDetails),
      ],
    );
  }

  Widget _dashboardCard(String title, String count, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap, // 👈 Tap handler
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.blue.shade50,
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 28),
                const SizedBox(height: 6),
                Text(
                  count,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildAdCard(Map ad) {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.campaign, color: Colors.orange, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad['adName'] ?? '',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Lato')),
                  const SizedBox(height: 4),
                  Text(
                    ad['adDescription'] ?? '',
                    style: const TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'Lato'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRegisteredEventsSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10, top: 10),
          child: Text(
            "Registered Events",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Lato'),
          ),
        ),
        if (isLoading)
          Center(
            child: Lottie.asset('assets/animations/loader.json', width: 120, height: 120),
          )
        else if (eventDetails.isEmpty)
          const Center(child: Text("No events found"))
        else
          ...eventDetails.map((event) => _buildDetailTile(event)).toList(),
        if (isLoadingMore)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Lottie.asset('assets/animations/loader.json', width: 80, height: 80),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailTile(EventDetailsModel event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Image.asset(registeredEventImage, width: 32, height: 32),
        title: Text(
          event.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Lato'),
        ),
        subtitle: Text(
          CommonCode.setDateFormat(event.startDate),
          style: const TextStyle(color: Colors.black54, fontFamily: 'Lato'),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue),
          onPressed: () => eventDetailsView(event),
        ),
      ),
    );
  }

  void eventDetailsView(EventDetailsModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Event Details",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Lato')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.name,
                style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Lato')),
            const SizedBox(height: 10),
            Text(event.description ?? "No description available",
                style: const TextStyle(color: Colors.black54, fontFamily: 'Lato')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }
}
