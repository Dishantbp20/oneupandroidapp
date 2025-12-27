import 'package:flutter/material.dart';
import 'package:one_up_app/main_ui/create_ads_screen.dart';
import 'package:one_up_app/model/ad_details.dart';

import '../utils/colors.dart';

class ListItemAd extends StatefulWidget {
  final AdDetailsModel adDetails;
  final Function() onDelete;

  const ListItemAd({super.key, required this.adDetails, required this.onDelete});

  @override
  State<ListItemAd> createState() => _ListItemAdState();
}

class _ListItemAdState extends State<ListItemAd> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      alignment: Alignment.topLeft,
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                            widget.adDetails.adName,
                            style: TextStyle(color: Colors.black, fontSize: 14,fontFamily: 'Lato'),
                          )),
                    ],
                  ),
                ],
              )),
          ElevatedButton(
            onPressed: () => {/*deleteBadge(widget.badgeDetails.id)*/},
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
                      builder: (context) => CreateAdsScreen(
                        isEdit: true,
                        id: widget.adDetails.id,
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
}
