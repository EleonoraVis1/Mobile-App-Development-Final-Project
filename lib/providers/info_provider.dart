import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';


final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

class InfoNotifier extends StateNotifier<Map<String, Map<String, dynamic>>> {
  InfoNotifier(this._user) : super({}) {
    _loadInitialInfo();
  }
  
  final User? _user;

  bool isLoading = true;

  Future<void> _loadInitialInfo() async {
    if (_user == null) {
      state = {};
      isLoading = false;   
      return;
    }
    await getInfo(_user.uid);
    isLoading = false;    
  }
  
  Future<void> getInfo(String uid) async {
    isLoading = true;
    state = {};

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
        } catch (_) {
        }

        state[userId] = {
          "username": username,
          "photo": profileFile,
        };
      }

    } catch (e) {
      print("Error fetching activities: $e");
    }

    isLoading = false;
  }

  Future<void> refresh() async {
    if (_user != null) {
      await getInfo(_user.uid);
    }
  }

  void clear() {
    state = {};
  }
}

final infoProvider =
    StateNotifierProvider<InfoNotifier, Map<String, Map<String, dynamic>>>((ref) {
  final auth = ref.watch(authStateProvider).value;
  return InfoNotifier(auth);
});


