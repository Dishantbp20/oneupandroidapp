import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:one_up_app/api_service/api_response.dart';
import 'package:one_up_app/main_ui/create_game_screen.dart';
import 'package:one_up_app/model/game_details_model.dart';

import '../api_service/api_end_points.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/colors.dart';
import '../utils/common_utilies.dart';

class ListItemGameDetails extends StatefulWidget {
  final GameDetailsModel gameDetails;
  final Function() onDelete;

  const ListItemGameDetails(
      {super.key, required this.gameDetails, required this.onDelete});

  @override
  State<ListItemGameDetails> createState() => _ListItemGameDetailsState();
}

class _ListItemGameDetailsState extends State<ListItemGameDetails> {
  late ApiResponse apiResponse;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(50), // Shadow color with opacity
              spreadRadius: 5, // How far the shadow spreads
              blurRadius: 7, // How blurred the shadow is
              offset: const Offset(0, 3), // X and Y offset of the shadow
            ),
          ],
          border: Border.all(width: 1, color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.gameDetails.name,
              style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: 'Lato',fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () => {deleteGame(widget.gameDetails.id)},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              // Button background
              foregroundColor: Colors.black,
              // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                side: BorderSide(
                    color: Colors.red, width: 1), // Border color & width
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
              elevation: 0, // Remove shadow if you want flat look
            ),
            child: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          ElevatedButton(
            onPressed: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateGameScreen(
                            isEdit: true,
                            id: widget.gameDetails.id,
                          )))
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              // Button background
              foregroundColor: Colors.black,
              // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                side: BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1), // Border color & width
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
              elevation: 0, // Remove shadow if you want flat look
            ),
            child: Icon(
              Icons.edit,
              color: AppColors.primaryBlue,
            ),
          )
        ],
      ),
    );
  }

  Future<void> deleteGame(String id) async {
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.deleteGameEndPoint + id,
        method: MethodType.patch,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });
      if (response.status == "200" || response.status == "201") {
        // final List<dynamic> jsonList = response.data["data"];

        if (response.data['status'] == 200) {
          final data = response.data['data'];
          // extract the list
          CommonUtilities.showAlertDialog(context,
              message: response.data['message'],
              icon: Icon(
                Icons.verified_outlined,
                color: Colors.green,
                size: 50,
              ));

          setState(() {
            // your list variable
          });
          widget.onDelete();
        } else {
          CommonUtilities.showAlertDialog(context,
              message: response.data['message'],
              icon: Icon(
                Icons.warning_amber,
                color: Colors.red,
                size: 50,
              ));
        }
      } else {
        CommonUtilities.showAlertDialog(context,
            message: response.message.toString(),
            icon: Icon(
              Icons.warning_amber,
              color: Colors.red,
              size: 50,
            ));
      }
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded successfully!')));
    } catch (e) {
      log("Error: ${e.toString()}");
      // print("Upload error: $e");
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed!')));
    }
  }
}
