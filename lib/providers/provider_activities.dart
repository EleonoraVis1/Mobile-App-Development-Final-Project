import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc322_starter_app/data/categories.dart';
import 'package:csc322_starter_app/models/category.dart';
import 'package:csc322_starter_app/widgets/general/activity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';


final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

class ActivitiesNotifier extends StateNotifier<List<Activity>> {
  ActivitiesNotifier(this._user) : super([]) {
    _loadInitialActivities();
  }
  
  final User? _user;
  List<File> photos = [];
  Map<String, Map<String, dynamic>> profileData = {};
  List<Activity> toShare = [];
  bool isLoading = true;

  Future<void> _loadInitialActivities() async {
    if (_user == null) {
      state = [];
      isLoading = false;   
      return;
    }
    await getActivities(_user.uid);
    isLoading = false;    
  }

  List<File> getPhotos() {
    return photos;
  }

  Future<void> getActivities(String uid) async {
    isLoading = true;
    state = [];
    photos = [];
    profileData = {}; 

    List<Activity> allActivities = [];


    try {
      final firestore = FirebaseFirestore.instance;
      final tempDir = await getTemporaryDirectory();

      final followingSnapshot = await firestore
          .collection('userDirectory')
          .doc(uid)
          .collection('following')
          .get();

      List<String> followingUids =
          followingSnapshot.docs.map((doc) => doc.id).toList();

      followingUids.insert(0, uid);

      for (final userId in followingUids) {
        String? username;

        try {
          final userDoc = await FirebaseFirestore.instance
              .collection("userDirectory")
              .doc(userId)
              .get();

          if (userDoc.exists) {
            final data = userDoc.data()!;
            final firstName = data["firstName"] ?? "";
            final lastName  = data["lastName"] ?? "";

            username = "$firstName $lastName".trim();
          }
        } catch (e) {
          print("Error fetching name: $e");
        }

        File? profileFile;
        try {
          final pfpRef = FirebaseStorage.instance
              .ref()
              .child("users/$userId/profile_picture/userProfilePicture.jpg");

          final bytes = await pfpRef.getData();
          if (bytes != null) {
            profileFile = File("${tempDir.path}/pfp_$userId.jpg");
            await profileFile.writeAsBytes(bytes);
          }
        } catch (_) {}

        profileData[userId] = {
          "username": username,
          "photo": profileFile,
        };
      }

      final futures = followingUids.map((userId) async {
        final querySnapshot = await firestore
            .collection('userDirectory')
            .doc(userId)
            .collection('posts')
            .get();

        List<Activity> userActivities = [];

        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;

          if (data == null ||
              data["title"] == null ||
              data["description"] == null ||
              data["mileage"] == null ||
              data["time"] == null ||
              data["category"] == null) continue;

          final storageRef = FirebaseStorage.instance
              .ref()
              .child("users/$userId/posts/${doc.id}");
          final listResult = await storageRef.listAll();
          final List<File> imageFiles = [];

          for (var fileRef in listResult.items) {
            final fileBytes = await fileRef.getData();
            if (fileBytes != null) {
              final file = File("${tempDir.path}/${doc.id}_${fileRef.name}");
              await file.writeAsBytes(fileBytes);
              imageFiles.add(file);

              if (userId == uid) {
                photos.add(file);
              }
            }
          }

          final activity = Activity(
            uid: userId,
            id: doc.id,
            title: data['title'],
            description: data['description'],
            mileage: data['mileage'],
            time: data['time'],
            category: categories.values.firstWhere(
              (cat) => cat.title == data['category'],
              orElse: () => categories.values.first,
            ),
            createdAt: data['createdAt'],
            images: imageFiles,
            image: CircleAvatar(
                      radius: 22,
                      backgroundImage:
                          profileData[userId]!["photo"] != null ? FileImage(profileData[userId]!["photo"]!) : null,
                      child: profileData[userId]!["photo"] == null
                          ? Text(
                                  'sth',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                )
                          : null,
                    ),
            username: profileData[userId]!["username"],
          );
          userActivities.add(activity);
        }
        return userActivities;
      });

      final results = await Future.wait(futures);

      allActivities = results.expand((list) => list).toList();
      allActivities.sort((a, b) => b.time.compareTo(a.time));

      toShare = allActivities;
      state = allActivities;
    } catch (e) {
      print("Error fetching activities: $e");
    }

    isLoading = false;
  }

  Future<void> refresh() async {
    if (_user != null) {
      await getActivities(_user.uid);
    }
  }

  void addActivity(Activity activity) {
    photos = [...activity.images, ...photos];
    state = [activity, ...state];
  }

  void clear() {
    photos = [];
    state = [];
  }
}

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, List<Activity>>((ref) {
  final auth = ref.watch(authStateProvider).value;
  return ActivitiesNotifier(auth);
});


final profilePicturesProvider = Provider((ref) {
  final profileData = ref.watch(activitiesProvider.notifier).profileData;
  return profileData;
});

