
class EventTypeDetailsModel {
  final String id;
  final String eventTypeName;

  EventTypeDetailsModel({required this.id, required this.eventTypeName});

  factory EventTypeDetailsModel.fromJson(Map<String, dynamic> json) {
    return EventTypeDetailsModel(id: json['id'], eventTypeName: json['eventTypeName']);
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "eventTypeName": eventTypeName,
    };
  }
  // 👇 Equality based on ID
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EventTypeDetailsModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => eventTypeName;
}