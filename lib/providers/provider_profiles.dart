import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc322_starter_app/models/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';

class ProfilesNotifier extends StateNotifier<List<UserData>> {
  ProfilesNotifier() : super([]);

  List<String> _uids = [];

  void clean() {
    state = [];
  }

  Future<void> updateUserData(String currentUid) async {
    try {
      state = [];

      final snapshot = await FirebaseFirestore.instance
          .collection('userDirectory')
          .get();

      if (snapshot.docs.isEmpty) return;

      _uids = snapshot.docs.map((doc) => doc.id).toList();

      final users = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        final uid = doc.id;

        if (uid == currentUid) return null;

        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';

        File? file;
        try {
          final ref = FirebaseStorage.instance
              .ref('users/$uid/profile_picture/userProfilePicture.jpg');

          final dir = await getTemporaryDirectory();
          final localFile = File('${dir.path}/$uid-profile.jpg');

          await ref.writeToFile(localFile)
              .timeout(const Duration(seconds: 5));

          file = localFile;
        } catch (e) {}

        return UserData(
          firstName: firstName,
          lastName: lastName,
          uid: uid,
          file: file,
        );
      }));

      state = users.whereType<UserData>().toList();
    } catch (e) {}
  }
}

final profilesProvider =
    StateNotifierProvider<ProfilesNotifier, List<UserData>>((ref) {
  return ProfilesNotifier();
});