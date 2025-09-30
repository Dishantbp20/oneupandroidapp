import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:one_up_app/api_service/api_response.dart';
import 'package:one_up_app/main_ui/edit_user_screen.dart';
import 'package:one_up_app/main_ui/manage_user_screen.dart';
import 'package:one_up_app/model/user_list_data.dart';
import 'package:one_up_app/utils/colors.dart';

import '../api_service/api_end_points.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/common_utilies.dart';

class ListItemManageUser extends StatefulWidget {
  final UserListData user;
  final Function() onDelete;
  const ListItemManageUser({super.key, required this.user, required this.onDelete});

  @override
  State<ListItemManageUser> createState() => _ListItemManageUserState();
}

class _ListItemManageUserState extends State<ListItemManageUser> {
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
        border: Border.all(
          width: 1,
          color: Colors.white
        ),
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Name: ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,fontFamily: 'Lato'
                    ),
                  ),
                  Text(
                    widget.user.name.trim(),
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,fontFamily: 'Lato'
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Player ID: ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,fontFamily: 'Lato'
                    ),
                  ),
                  Text(
                    widget.user.playerId,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,fontFamily: 'Lato'
                    ),
                  ),
                ],
              ),

            ],
          ))
          ,ElevatedButton(
            onPressed: ()=>{
              deletePlayer(widget.user.id)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Button background
              foregroundColor: Colors.black, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                side: BorderSide(color: Colors.red, width: 1), // Border color & width
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
              elevation: 0, // Remove shadow if you want flat look
            ),
            child: Icon(Icons.delete,color: Colors.red,),
          ),
          SizedBox(
            width: 5,
          ),
          ElevatedButton(
            onPressed: ()=>{
              Navigator.push(context,
                MaterialPageRoute(builder: (context)=> EditUserScreen(id: widget.user.id,))
              )
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Button background
              foregroundColor: Colors.black, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                side: BorderSide(color: AppColors.primaryBlue, width: 1), // Border color & width
              ),
              padding: EdgeInsets.symmetric( vertical: 12),
              elevation: 0, // Remove shadow if you want flat look
            ),
            child: Icon(Icons.edit,color: AppColors.primaryBlue,),
          )
        ],
      ),
    );
  }
  Future<void> deletePlayer(String id) async{
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.deleteUserEndPoint+id,
        method: MethodType.patch,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });
      if(response.status == "200" || response.status == "201"){
        // final List<dynamic> jsonList = response.data["data"];

        if(response.data['status'] == 200){
          final data = response.data['data'];
           // extract the list
          setState(() {
            // your list variable
          });

          CommonUtilities.showAlertDialog(context, message: response.data['message'],icon: Icon(Icons.verified_outlined,color: Colors.green,size: 50,));
          widget.onDelete();
        }else{
          CommonUtilities.showAlertDialog(context, message: response.data['message'],icon: Icon(Icons.warning_amber,color: Colors.red,size: 50,));
        }


      }else{
        CommonUtilities.showAlertDialog(context, message: response.message.toString(),icon: Icon(Icons.warning_amber,color: Colors.red,size: 50,));
      }
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded successfully!')));
    } catch (e) {
      log("Error: ${e.toString()}");
      // print("Upload error: $e");
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed!')));
    }
  }
}
