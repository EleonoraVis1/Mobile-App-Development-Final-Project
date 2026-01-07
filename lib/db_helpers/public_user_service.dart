import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc322_starter_app/util/logging/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class PublicUserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPublicUserProfile({
    required String firstName,
    required String lastName,
    
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be signed in before creating a profile.');
    }

    final uid = user.uid;

    final publicData = {
      'firstName': firstName,
      'lastName': lastName
    };

    await _firestore.collection('userDirectory').doc(uid).set(publicData);
  }

  Future<void> writeAnActivity({
    required String id,
    required String title,
    required String description,
    required double mileage,
    required int time,
    required String category
    
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be signed in before creating an activity.');
    }
    final now = DateTime.now();
    final formatted = DateFormat('dd MMM yyyy, HH:mm').format(now);

    final uid = user.uid;

    final activityData = {
      'title': title,
      'description': description,
      'mileage': mileage,
      'time': time,
      'category': category,
      'createdAt': formatted
    };
    DocumentReference userDocRef = _firestore.collection('userDirectory').doc(uid);
    await userDocRef.collection('posts').doc(id).set(activityData);
  }

  Future<void> writeActivityPhotos({
    required String id,
    required List<File> images
    
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be signed in before creating an activity.');
    }

    final uid = user.uid;
    try {
      for (int i = 0; i < images.length; i++){
        try {
          final gcsPath = 'users/${uid}/posts/${id}/photo$i.jpg';
          final ref = FirebaseStorage.instance.ref().child(gcsPath);
          try {
            final existingMetadata = await ref.getMetadata();
            await ref.putFile(
                images[i], SettableMetadata(customMetadata: existingMetadata.customMetadata ?? <String, String>{}));
          } catch (e) {
            Map<String, String> customMetadata = {};
            ref.putFile(images[i], SettableMetadata(customMetadata: customMetadata));
          }
        } catch (e) {
          AppLogger.error("Failed To Upload: $e");
        }
      }
    } catch (e) {}
  }
}
