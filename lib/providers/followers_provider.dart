import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class FollowersNotifier extends StateNotifier<List<int>?> {
  FollowersNotifier() : super(null);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> follow(String thisName, String otheruid, String fullName) async {
    final _user = FirebaseAuth.instance.currentUser;

    if (_user == null) {
      throw Exception('User must be signed in before following.');
    }

    final currentUid = _user.uid;

    final followersRef = _firestore
        .collection('userDirectory')
        .doc(otheruid)
        .collection('followers')
        .doc(currentUid);

    final followingRef = _firestore
        .collection('userDirectory')
        .doc(currentUid)
        .collection('following')
        .doc(otheruid);

    final batch = _firestore.batch();

    batch.set(followersRef, {
      'uid': currentUid,
      'fullname': thisName,
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.set(followingRef, {
      'uid': otheruid,
      'fullName': fullName,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> unfollow(String otherUid) async {
    final _user = FirebaseAuth.instance.currentUser;

    if (_user == null) {
      throw Exception('User must be signed in before unfollowing.');
    }

    final currentUid = _user.uid;

    final followersRef = _firestore
        .collection('userDirectory')
        .doc(otherUid)
        .collection('followers')
        .doc(currentUid);

    final followingRef = _firestore
        .collection('userDirectory')
        .doc(currentUid)
        .collection('following')
        .doc(otherUid);

    final batch = _firestore.batch();

    batch.delete(followersRef);
    batch.delete(followingRef);

    await batch.commit();
  }


  Future<void> loadCounts(String profileUid) async {
    state = null;
    final _user = FirebaseAuth.instance.currentUser;
    if (_user == null) return;

    final followersSnap = await _firestore
        .collection('userDirectory')
        .doc(profileUid)
        .collection('followers')
        .get();

    final followingSnap = await _firestore
        .collection('userDirectory')
        .doc(profileUid)
        .collection('following')
        .get();

    state = [
      followingSnap.size,
      followersSnap.size,
    ];
  }
}

final followersProvider =
    StateNotifierProvider<FollowersNotifier, List<int>?>((ref) {
  return FollowersNotifier();
});
