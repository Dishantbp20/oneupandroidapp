
class UserSessionModel{
   String? name;
   String? username;
   String? dob;
   String? address;
   String? email;
   String? isPaid;
   String? isAdmin;
   String? token;
   String? playerId;

  UserSessionModel(this.name, this.username, this.dob, this.address, this.email,
      this.isPaid, this.isAdmin, this.token, this.playerId);

    /*factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }*/
    /*factory UserSessionModel.fromJson(Map<String, dynamic> json){
      return UserSessionModel(
          name: json['name'],
          username: json['username'],
          dob: json['dob'],
          address: json['name'],
          email: json['name'],
          isPaid: json['name'],
          isAdmin: json['name'],
          token: json['name'],
          playerId:json['name']);

    }*/
}