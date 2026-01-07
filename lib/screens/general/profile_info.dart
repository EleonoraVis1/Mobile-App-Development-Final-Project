import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc322_starter_app/main.dart';
import 'package:csc322_starter_app/models/activities_chart.dart';
import 'package:csc322_starter_app/providers/followers_provider.dart';
import 'package:csc322_starter_app/providers/info_provider.dart';
import 'package:csc322_starter_app/providers/photos_provider.dart';
import 'package:csc322_starter_app/providers/provider_activities.dart';
import 'package:csc322_starter_app/widgets/general/activity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileInfo extends ConsumerStatefulWidget {
  const ProfileInfo({
    super.key,
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.file,
    this.photos,
    required this.activities,
  }) : fullName = firstName + ' ' + lastName;

  final String uid;
  final String firstName;
  final String lastName;
  final String fullName;
  final File? file;
  final List<File>? photos;
  final List<Activity> activities;

  @override
  ConsumerState<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends ConsumerState<ProfileInfo> {
  final double topPhotoHeight = 200.0;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  List<File> topPhotos = [];
  List<File> usedPhotos = [];
  String UID = '';
  bool _isLoading = false;
  bool _isFollowing = false;
  bool _followLoaded = false;

  User? user = FirebaseAuth.instance.currentUser;
  List<int> followInfo = [0, 0];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);

    await ref.read(userPhotosProvider);

    setState(() => _isLoading = false);
  }

  Future<void> _checkIfFollowing() async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("userDirectory")
        .doc(currentUid)
        .collection("following")
        .doc(widget.uid)
        .get();

    setState(() {
      _isFollowing = doc.exists;
      _followLoaded = true; 
    });
  }

  void _toggleFollow() async {
    final profile = ref.read(providerUserProfile);

    if (_isFollowing) {
      await ref.read(followersProvider.notifier).unfollow(widget.uid);
    } else {
      await ref.read(followersProvider.notifier).follow(
        '${profile.firstName} ${profile.lastName}',
        widget.uid,
        widget.fullName,
      );
    }
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    setState(() {
      _isFollowing = !_isFollowing;
    });
    
    await ref.read(followersProvider.notifier).loadCounts(widget.uid);
    await ref.read(activitiesProvider.notifier).refresh();
    await ref.read(infoProvider.notifier).getInfo(currentUid);
  }
  
  bool _activitiesLoading = true;
  List<Map<String, dynamic>> _activitiesData = [];

  @override
  void initState() {
    super.initState();
    _init();
    Future.microtask(() async {
      await ref.read(followersProvider.notifier).loadCounts(widget.uid);
      await _checkIfFollowing();    
      await _loadActivitiesData(); 
    });
  }

  Future<void> _loadActivitiesData() async {
    setState(() => _activitiesLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('userDirectory')
          .doc(widget.uid)
          .collection('posts')
          .get();

      final List<Map<String, dynamic>> activitiesData = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'category': data['category'],
          'mileage': data['mileage'],
        };
      }).toList();

      setState(() {
        _activitiesData = activitiesData;
        _activitiesLoading = false;
      });
    } catch (e) {
      print("Error loading activities data: $e");
      setState(() => _activitiesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    topPhotos = ref.watch(userPhotosProvider);
    final bool isLoading = ref.watch(userPhotosProvider.notifier).isLoading;
    List<int>? followInfo = ref.watch(followersProvider);

    if (widget.photos == null) 
      usedPhotos = topPhotos;
    else
      usedPhotos = widget.photos!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: topPhotoHeight,
              child: isLoading && widget.photos == null
                  ? Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : usedPhotos.isEmpty
                      ? Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text(
                              'No photos added',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: usedPhotos.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  width: double.infinity,
                                  height: topPhotoHeight,
                                  color: Colors.black, 
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    child: Image.file(usedPhotos[index]),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(usedPhotos.length, (index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    width: _currentPage == index ? 10 : 6,
                                    height: _currentPage == index ? 10 : 6,
                                    decoration: BoxDecoration(
                                      color: _currentPage == index
                                          ? Colors.white
                                          : Colors.white54,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        widget.file != null ? FileImage(widget.file!) : null,
                    child: widget.file == null
                        ? (widget.firstName.isEmpty || widget.lastName.isEmpty)
                            ? const Text('')
                            : Text(
                                '${widget.firstName.substring(0, 1)}${widget.lastName.substring(0, 1)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Text(
                      widget.fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  Text(
                    "Following: ${followInfo?.first ?? '-'}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Followers: ${followInfo?.last ?? '-'}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  if (widget.photos == null)
                    _followLoaded
                        ? ElevatedButton(
                            onPressed: _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFollowing
                                  ? Colors.white
                                  : const Color(0xFFFC4C02),
                              foregroundColor: _isFollowing
                                  ? Colors.grey[800]
                                  : Colors.white,
                              side: _isFollowing
                                  ? BorderSide(color: Colors.grey[600]!, width: 1.2)
                                  : BorderSide.none,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            ),
                            child: Text(
                              _isFollowing ? "Following" : "Follow",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 30,
                            width: 90,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                ],
              )
            ),

            const SizedBox(height: 50),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _activitiesLoading
                ? const Center(child: CircularProgressIndicator())
                : AllActivitiesChart(
                    activities: _activitiesData, 
                  ),            
            ),
          ],
        ),
      ),
    );
  }
}
