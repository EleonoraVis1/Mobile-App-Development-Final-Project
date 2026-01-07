// -----------------------------------------------------------------------
// Filename: screen_home.dart
// Original Author: Dan Grissom
// Creation Date: 10/31/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the screen for a dummy home screen
//               history screen.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////

// Flutter imports
import 'dart:async';
import 'dart:io';

// Flutter external package imports
import 'package:csc322_starter_app/main.dart';
import 'package:csc322_starter_app/providers/provider_activities.dart';
import 'package:csc322_starter_app/providers/provider_user_profile.dart';
import 'package:csc322_starter_app/screens/general/profile_info.dart';
import 'package:csc322_starter_app/widgets/general/activity.dart';
import 'package:csc322_starter_app/widgets/general/activity_list.dart';
import 'package:csc322_starter_app/screens/general/new_activity.dart';
import 'package:csc322_starter_app/widgets/navigation/widget_app_drawer.dart';
import 'package:csc322_starter_app/widgets/navigation/widget_primary_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// App relative file imports

//////////////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the state object.
//////////////////////////////////////////////////////////////////////////
class ScreenMainPage extends ConsumerStatefulWidget {
  static const routeName = '/main_page';

  @override
  ConsumerState<ScreenMainPage> createState() => _ScreenMainPageState();
}

//////////////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////////////
class _ScreenMainPageState extends ConsumerState<ScreenMainPage> {
  // The "instance variables" managed in this state
  bool _isInit = true;
  bool _isLoading = false;
  List<File> _photosList = [];
  late String uid;
  late String name;
  late String last;

  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    //if (_isInit) {
    
     // _init();
     // _isInit = false;
      super.didChangeDependencies();
    //}
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);

    await ref.read(activitiesProvider);

    setState(() => _isLoading = false);
  }


  @override
  void initState() {
    super.initState();
    _init();
  }

  void _addItem() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewActivity(),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////
  // Initializes state variables and resources
  ////////////////////////////////////////////////////////////////
  

  //////////////////////////////////////////////////////////////////////////
  // Primary Flutter method overridden which describes the layout and bindings for this widget.
  //////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final List<Activity> _activityList = ref.watch(activitiesProvider);
    final bool isLoading = ref.watch(activitiesProvider.notifier).isLoading;
    
    
    _photosList = ref.read(activitiesProvider.notifier).getPhotos();
    String initials = '';
    final ProviderUserProfile provider = ref.read(providerUserProfile);
    ImageProvider? image = provider.userImage;
    try {
      if (provider.firstName != null && provider.lastName != null){
        String fn = provider.firstName[0];
        String ln = provider.lastName[0];

        String i1 = fn.isEmpty ? "" : fn.substring(0, 1);
        String i2 = ln.isEmpty ? "" : ln.substring(0, 1);

        initials = (i1 + i2).trim();
        initials = initials.isEmpty ? "ME" : initials;
      }
      
    } catch (e) {
      initials = "ME";
    }

    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  
    return Scaffold(
      appBar: WidgetPrimaryAppBar(
        title: Text('Main Page'),
        
        actionButtons: [
          Padding(
          padding: EdgeInsets.only(right: 5),
          child: image == null 
          ? CircleAvatar(
            radius: 18,
            backgroundColor: Color.fromARGB(255, 137, 137, 137),
            child: InkWell(
              onTap: () async {
                File? file;
                try {
                  final ref = FirebaseStorage.instance
                      .ref('users/${provider.uid}/profile_picture/userProfilePicture.jpg');

                  final dir = await getTemporaryDirectory();
                  final tryFile = File('${dir.path}/${provider.uid}-profile.jpg');

                  await ref.writeToFile(tryFile);
                  file = tryFile;
                } catch (_) {
                  
                }
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => ProfileInfo(uid: provider.uid, firstName: provider.firstName, lastName: provider.lastName, file: file, photos: _photosList, activities: _activityList,))
                );
              },
              child: Text(
                initials,
                style: TextStyle(fontSize: 12),
              )
            ),
          )  
          : CircleAvatar(
            radius: 18,
            backgroundImage: image,
            child: InkWell(
              onTap: () async {
                File? file;
                try {
                  final ref = FirebaseStorage.instance
                      .ref('users/${provider.uid}/profile_picture/userProfilePicture.jpg');

                  final dir = await getTemporaryDirectory();
                  final tryFile = File('${dir.path}/${provider.uid}-profile.jpg');

                  await ref.writeToFile(tryFile);
                  file = tryFile;
                } catch (_) {
                  
                }
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => ProfileInfo(uid: provider.uid, firstName: provider.firstName, lastName: provider.lastName, file: file, photos: _photosList, activities: _activityList,))
                );
              },
            ),
          ),
        )
        ],
      ),
      drawer: WidgetAppDrawer(),
      
      floatingActionButton: FloatingActionButton(
        shape: ShapeBorder.lerp(CircleBorder(), StadiumBorder(), 0.5),
        onPressed: _addItem,            
        splashColor: Theme.of(context).primaryColor,
        child: Icon(FontAwesomeIcons.plus),
      ),
      body: isLoading
        ? Center(child: CircularProgressIndicator())
        : ActivityList(activities: _activityList),

    );
  }
}