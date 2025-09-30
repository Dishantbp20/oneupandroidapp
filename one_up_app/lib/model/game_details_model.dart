
class GameDetailsModel{
  final String id;
  final String name;
  final String description;
  final bool status;

  GameDetailsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status
  });

  factory GameDetailsModel.fromJson(Map<String, dynamic> json) {
    return GameDetailsModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "status": status,
    };
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GameDetailsModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name; // (Optional, helps in debugging/logs)
}