
class BadgeDetailsModel {
  final String id;
  final String bedgeName;

  BadgeDetailsModel({required this.id, required this.bedgeName});

  factory BadgeDetailsModel.fromJson(Map<String, dynamic> json) {
    return BadgeDetailsModel(
        id: json['id'],
        bedgeName: json['bedgeName']
    );

  }
}