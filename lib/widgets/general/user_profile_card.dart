import 'dart:io';

import 'package:csc322_starter_app/screens/general/profile_info.dart';
import 'package:csc322_starter_app/widgets/general/activity.dart';
import 'package:flutter/material.dart';

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({super.key, required this.firstName, required this.lastName, required this.uid, required this.photo, required this.file, required this.activities}) : fullName = firstName + ' ' + lastName;

  final String firstName;
  final String lastName;
  final String fullName;
  final String uid;
  final Widget photo;
  final File? file;
  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        child: ListTile(
          leading: photo,
          tileColor: const Color.fromARGB(255, 198, 198, 198),
          title: Text(fullName,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ProfileInfo(uid: uid, firstName: firstName, lastName: lastName, file: file, activities: [],),
            )
          );
        },
      ),
    );
  }
}