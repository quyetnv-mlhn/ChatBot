import 'package:flutter/material.dart';

class UserCustom {
  var id;
  var email;
  var name;
  var photoURL;
  var sex;
  var phoneNumber;
  var birth;

  UserCustom(this.id, this.email, this.name, this.photoURL);

  UserCustom.fullInfo(this.id, this.email, this.name, this.photoURL, this.sex,
      this.phoneNumber, this.birth);

  factory UserCustom.fromJson(Map<dynamic, dynamic> json) {
    return UserCustom.fullInfo(json['id'], json['email'], json['fullName'],
        json['imagePath'], json['sex'], json['phoneNumber'], json['birthDay']);
  }
}