
class UserDetailsModel{
  /*"data": {
        "dob": "2025-08-12",
        "playerId": "0PD0002",
        "name": "Prem Darji",
        "address": "Meghaninagar",
        "email": "darjiprem619@gmail.com",
        "id": "zDOTD9VWpAWo7iiX3e7J",
        "role": "USER"
    },*/
  final String id;
  final String playerId;
  final String role;
  final String name;
  final String image;
  final String dob;
  final String address;
  final String email;

  UserDetailsModel( {
    required this.dob,
    required this.address,
    required this.email,
    required this.id,
    required this.playerId,
    required this.role,
    required this.name,
    required this.image,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      id: json['id'],
      playerId: json['playerId'],
      role: json['role'],
      name: json['name'],
      dob: json['dob'],
      address: json['address'],
      image: json['image'],
      email: json['email'],
    );
  }
}