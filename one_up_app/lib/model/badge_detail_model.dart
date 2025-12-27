class BadgeDetailsModel {
  final String id;
  final String bedgeName;
  final String image;
  final bool isActive;

  BadgeDetailsModel( {
    required this.isActive,
    required this.id,
    required this.bedgeName,
    required this.image,
  });

  factory BadgeDetailsModel.fromJson(Map<String, dynamic> json) {
    return BadgeDetailsModel(
      id: json['id'].toString(),
      bedgeName: json['bedgeName'] ?? '',
      image: json['image'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  // 👇 ADD THESE TWO
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BadgeDetailsModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => bedgeName;
}
