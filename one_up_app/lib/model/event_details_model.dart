import 'package:intl/intl.dart';
import 'package:one_up_app/model/event_type_details_model.dart';
import 'package:one_up_app/model/game_details_model.dart';

class EventDetailsModel {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final String registrationStartDate;
  final String registrationEndDate;
  final String description;
   List<GameDetailsModel> games=[];
   List<EventTypeDetailsModel> eventtypes=[];
  final bool isShowName;
  final bool isShowDescription;
  final bool isShowStartDate;
  final bool isShowEndDate;
  final bool isShowRegistrationStartDate;
  final bool isShowRegistrationEndDate;

  EventDetailsModel({required this.id, required this.name, required this.startDate, required this.endDate,required this.registrationStartDate, required this.registrationEndDate, required this.description,   this.games = const [],  this.eventtypes = const [],
  required this.isShowName,required this.isShowDescription, required this.isShowStartDate, required this.isShowEndDate, required this.isShowRegistrationStartDate,
  required this.isShowRegistrationEndDate});
  factory EventDetailsModel.fromJson(Map<String, dynamic> json) {
    return EventDetailsModel(
        id: json['id'],
        name: json['name'] ?? "",
      startDate: json['startDate'] ?? DateFormat("dd-MM-yyyy").format(DateTime.now()),
      endDate: json['endDate'] ?? DateFormat("dd-MM-yyyy").format(DateTime.now()),
      registrationStartDate: json['registrationStartDate'] ?? DateFormat("dd-MM-yyyy").format(DateTime.now()),
      registrationEndDate: json['registrationEndDate'] ?? DateFormat("dd-MM-yyyy").format(DateTime.now()),
      description: json['description'] ?? "",
      games: json['games'] != null
          ? (json['games'] as List<dynamic>)
          .map((g) => GameDetailsModel.fromJson(g))
          .toList()
          : [],
      eventtypes: json['eventtypes'] != null
          ? (json['eventtypes'] as List<dynamic>)
          .map((g) => EventTypeDetailsModel.fromJson(g))
          .toList()
          : [],
      isShowName: json['isShowName'] ?? false,
      isShowDescription: json['isShowDescription'] ?? false,
      isShowStartDate: json['isShowStartDate'] ?? false,
      isShowEndDate: json['isShowEndDate'] ?? false,
      isShowRegistrationStartDate: json['isShowRegistrationStartDate'] ?? false,
      isShowRegistrationEndDate: json['isShowRegistrationEndDate'] ?? false
    );
  }

}