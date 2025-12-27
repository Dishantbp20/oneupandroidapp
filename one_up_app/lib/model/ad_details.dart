import 'dart:developer';

class AdDetailsModel{
  final String id;
  final String adName;
  final String adDescription;
  final String image;
  final bool isActive;
  
  AdDetailsModel({
    required this.id,
    required this.adName,
    required this.adDescription,
    required this.image,
    required this.isActive
  });

  factory AdDetailsModel.fromJson(Map<String, dynamic> json){
    return AdDetailsModel(
        id: json['id'].toString(),
        adName: json['adName'] ?? '',
        adDescription: json['adDescription'] ?? '',
        image: json['image'] ?? '',
        isActive: json['isActive'] ?? false
    );
  }
}