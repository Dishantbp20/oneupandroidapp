
class UserListData{
  final String id;
  final String playerId;
  final String username;
  final String name;

  UserListData({
    required this.id,
    required this.playerId,
    required this.username,
    required this.name,
  });

  factory UserListData.fromJson(Map<String, dynamic> json) {
    return UserListData(
      id: json['id'],
      playerId: json['playerId'],
      username: json['username'],
      name: json['name'],
    );
  }
}