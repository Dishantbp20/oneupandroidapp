import 'dart:io';

class RegistrationModel{
  final String? name;
  final String? username;
  final File? idCard;
  final DateTime? dob;
  final String? address;
  final String? email;
  final String? password;
  final String? confirmPassword;
  final bool? isPaid;

  RegistrationModel(
      this.name,
      this.username,
      this.idCard,
      this.dob,
      this.address,
      this.email,
      this.password,
      this.confirmPassword,
      this.isPaid
  );


  Map<String, dynamic> toMap(){
    return {
      'name':name,
      'username':username,
      'idCard': idCard,
      'dob':dob,
      'address':address,
      'email':email,
      'password':password,
      'confirmPassword':confirmPassword,
      'isPaid':isPaid,
    };
  }
}