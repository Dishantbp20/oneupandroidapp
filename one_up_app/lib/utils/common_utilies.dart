
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/widgets/styled_button.dart';

class CommonUtilities{
  static void showToast(String msg){
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: blackOp5(0.5),
      fontSize: 14,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
  static Color whiteOp5(double opacity){
    Color whiteop =Colors.white.withOpacity(opacity);
    return whiteop;
  }
  static Color blackOp5(double opacity){
    Color blackop =Colors.black.withOpacity(opacity);
    return blackop;
  }
  static void showAlertDialog(BuildContext context, {required String message, required Icon icon}) {

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              Text(
                message,
                style: TextStyle(fontSize: 14,fontFamily: 'Lato'),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            StyledButton(text: "Ok",onPressed: ()=>{
                Navigator.pop(context)
            })
          ],
        );
      },
    );
  }
  /*static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing
      builder: (BuildContext context) {
        return Center(
          child: Lottie.asset(
        'assets/animations/loader.json',
        width: 120,
        height: 120,
        repeat: true,
      ),,
        );
      },
    );
  }*/
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lottie animation
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Lottie.asset(
                    'assets/animations/loader.json', // your lottie file path
                    repeat: true,
                    reverse: false,
                    animate: true,
                    width: 1000,
                    height: 1000
                  ),
                ),
                /*const SizedBox(height: 20),
                const Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),*/
              ],
            ),
          ),
        );
      },
    );
  }
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
  }
}