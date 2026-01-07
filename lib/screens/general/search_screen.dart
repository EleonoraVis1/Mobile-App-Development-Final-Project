// -----------------------------------------------------------------------
// Filename: screen_alternative.dart
// Original Author: Dan Grissom
// Creation Date: 10/31/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the screen for a dummy alternative screen
//               history screen.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter imports

import 'dart:async';
import 'package:csc322_starter_app/providers/photos_provider.dart';
import 'package:csc322_starter_app/providers/provider_activities.dart';
import 'package:csc322_starter_app/providers/provider_profiles.dart';
import 'package:csc322_starter_app/providers/provider_search_result.dart';
import 'package:csc322_starter_app/widgets/general/activity.dart';
import 'package:csc322_starter_app/widgets/general/user_profile_card.dart';
import 'package:csc322_starter_app/widgets/general/widget_search.dart';
import 'package:csc322_starter_app/widgets/navigation/widget_app_drawer.dart';
import 'package:csc322_starter_app/widgets/navigation/widget_primary_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////////////////
// Stateful widget which manages search
//////////////////////////////////////////////////////////////////////////
class ScreenSearch extends ConsumerStatefulWidget {
  static const routeName = '/search';
  const ScreenSearch({super.key});

  @override
  ConsumerState<ScreenSearch> createState() => _ScreenSearchState();
}

//////////////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////////////
class _ScreenSearchState extends ConsumerState<ScreenSearch> {
  bool _isInit = true;
  String username = '';
  bool _isLoading = false;

  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _init();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }
  Future<void> _init() async {
    setState(() => _isLoading = true);

    await ref.read(activitiesProvider);

    setState(() => _isLoading = false);
  }

  ////////////////////////////////////////////////////////////////
  // Initializes state variables and resources
  ////////////////////////////////////////////////////////////////
  

  //////////////////////////////////////////////////////////////////////////
  // Build UI
  //////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final List<Activity> _activityList = ref.watch(activitiesProvider);
    final bool isLoading = ref.watch(activitiesProvider.notifier).isLoading;
    username = ref.watch(searchResultProvider);
    final users = ref.watch(profilesProvider);
    List<Activity> activities = ref.read(activitiesProvider.notifier).toShare;

    if (users.isEmpty) {
      return Scaffold(
        appBar: WidgetPrimaryAppBar(
          title: const Text('Search'),
        ),
        drawer: WidgetAppDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final usernames = users.map((u) => '${u.firstName} ${u.lastName}').toList();

    Widget content = const Center(child: Text('No search items yet'));

    if (username.isNotEmpty) {
      final searchedUser = users.firstWhere(
        (user) => '${user.firstName} ${user.lastName}' == username,
      );
      
      content = UserProfileCard(
        firstName: searchedUser.firstName,
        lastName: searchedUser.lastName,
        uid: searchedUser.uid,
        photo: searchedUser.photo,
        file: searchedUser.file,
        activities: activities,
      );
    }

    return Scaffold(
      appBar: WidgetPrimaryAppBar(
        title: const Text('Search'),
        actionButtons: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final chosenUsername = await showSearch(
                context: context,
                delegate: CustomSearchDelegate(usernames: usernames),
              );

              if (chosenUsername != null) {
                ref.read(searchResultProvider.notifier).addResult(chosenUsername);
                await ref.read(userPhotosProvider.notifier).getPhotosByUID(users.firstWhere(
                  (user) => '${user.firstName} ${user.lastName}' == chosenUsername,
                ).uid);
              }
            },
          ),
        ],
      ),
      drawer: WidgetAppDrawer(),
      body: content,
    );
  }
}
