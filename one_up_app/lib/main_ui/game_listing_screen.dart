import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/list_item_layout/list_item_game_details.dart';
import 'package:one_up_app/main_ui/create_game_screen.dart';
import 'package:one_up_app/utils/app_preferences.dart';

import '../api_service/api_end_points.dart';
import '../api_service/api_response.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../model/game_details_model.dart';
import '../utils/colors.dart';
import '../utils/common_utilies.dart';

class GameListingScreen extends StatefulWidget {
  const GameListingScreen({super.key});

  @override
  State<GameListingScreen> createState() => _GameListingScreenState();
}

class _GameListingScreenState extends State<GameListingScreen> {
  late Future<void> _gameFuture;
  late ApiResponse apiResponse;
  List<GameDetailsModel> gameDetails = [];
  List<GameDetailsModel> filteredGameList = [];

  bool isLoading = false;
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _gameFuture = getGameDetailsModel(currentPage);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoading && hasMore) {
        _gameFuture = getGameDetailsModel(currentPage);
      }
    }
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGameList = gameDetails;
      } else {
        filteredGameList = gameDetails.where((item) {
          return item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        /*floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateGameScreen(
                      isEdit: false,
                      id: "",
                    )));
          },
          backgroundColor: AppColors.secondaryColor,
          child: Icon(Icons.add, color: Colors.white),
        ),*/
        body: FutureBuilder(
            future: _gameFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  gameDetails.isEmpty) {
                return  Center(child: Lottie.asset(
        'assets/animations/loader.json',
        width: 120,
        height: 120,
        repeat: true,
      ));
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                return Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                     /* Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        child: Text(
                          "Games",
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Lato'
                          ),
                        ),
                      ),*/
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  icon: Icon(Icons.search, color: Colors.white),
                                  hintText: "Search Game...",
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
                                        builder: (context) => CreateGameScreen(
                                          isEdit: false,
                                          id: "",
                                        )));
                                // Handle add button press
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: filteredGameList.length + 1,
                                // (isLoading && hasMore ? 1 : 0),
                            itemBuilder: (BuildContext context, int index) {
                              if (index == filteredGameList.length) {
                                return  Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                      child: Lottie.asset(
        'assets/animations/loader.json',
        width: 120,
        height: 120,
        repeat: true,
      ),),
                                );
                              }
                              return ListItemGameDetails(
                                gameDetails: filteredGameList[index],
                                onDelete: () {
                                  setState(() {
                                    currentPage = 1;
                                    hasMore = true;
                                    gameDetails.clear();
                                    filteredGameList.clear();
                                    _gameFuture = getGameDetailsModel(currentPage);
                                  });
                                },
                              );
                            },
                          ))
                    ],
                  ),
                );
              }
            }));
  }

  Future<void> getGameDetailsModel(int pageNo) async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> query = {"page": pageNo, "perPage": pageSize};

    try {
      final response = await DioClient().request(
          path: ApiEndPoints.getGameListEndPoint,
          method: MethodType.get,
          queryParameters: query);

      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];
          final List<dynamic> gamesListJson = data['gameDetails'];

          List<GameDetailsModel> gamesList = gamesListJson
              .map((json) => GameDetailsModel.fromJson(json))
              .toList();

          setState(() {
            currentPage++;
            isLoading = false;

            gameDetails.addAll(gamesList.reversed);
            filteredGameList = List.from(gameDetails);

            if (gamesList.length < pageSize) {
              hasMore = false;
            }
          });
        } else {
          isLoading = false;
          CommonUtilities.showAlertDialog(context,
              message: response.data['message'],
              icon: Icon(
                Icons.warning_amber,
                color: Colors.red,
                size: 50,
              ));
        }
      } else {
        isLoading = false;
        CommonUtilities.showAlertDialog(context,
            message: response.data['message'],
            icon: Icon(
              Icons.warning_amber,
              color: Colors.red,
              size: 50,
            ));
      }
    } catch (e) {
      isLoading = false;
      log("Error: ${e.toString()}");
    }
  }
}
