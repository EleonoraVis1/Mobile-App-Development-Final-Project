import 'package:flutter/material.dart';
import 'dart:io';

class UserData {
  UserData({required this.firstName, required this.lastName, required this.uid, required this.file}) : photo = 
    CircleAvatar(
      radius: 25,
      backgroundImage: file != null ? FileImage(file) : null,
      child: file == null
          ? (firstName.isEmpty || lastName.isEmpty)
              ? const Text('')
              : Text(
                  '${firstName.substring(0, 1)}${lastName.substring(0, 1)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
          : null,
    );    

  final String firstName;
  final String lastName;
  final String uid;
  final File? file;
  Widget photo;
}