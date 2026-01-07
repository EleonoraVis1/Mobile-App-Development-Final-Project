// -----------------------------------------------------------------------
// Filename: widget_primary_scaffold.dart
// Original Author: Dan Grissom
// Creation Date: 5/27/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the primary scaffold for the app.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Dart imports

// Flutter external package imports
import 'package:csc322_starter_app/providers/bottom_index.dart';
import 'package:csc322_starter_app/providers/provider_profiles.dart';
import 'package:csc322_starter_app/providers/provider_search_result.dart';
import 'package:csc322_starter_app/providers/provider_user_profile.dart';
import 'package:csc322_starter_app/screens/general/screen_main_page.dart';
import 'package:csc322_starter_app/screens/general/screen_weather.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// App relative file imports
import '../../screens/general/search_screen.dart';
import 'widget_primary_app_bar.dart';
import 'widget_app_drawer.dart';
import '../../main.dart';

//////////////////////////////////////////////////////////////////////////
// Localized provider for the current tab index
//////////////////////////////////////////////////////////////////////////
final providerPrimaryBottomNavTabIndex = StateProvider<int>((ref) => 0);

//////////////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////////////
class WidgetPrimaryScaffold extends ConsumerStatefulWidget {
  static const routeName = "/home";

  const WidgetPrimaryScaffold({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  ConsumerState<WidgetPrimaryScaffold> createState() => _WidgetPrimaryScaffoldState();
}

//////////////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////////////
class _WidgetPrimaryScaffoldState extends ConsumerState<WidgetPrimaryScaffold> {
  // The "instance variables" managed in this state
  var _isInit = true;
  List<String> usernames = [];
  late Image shareImageFocus;
  late Image shareImageLightUnfocused;
  late Image shareImageDarkUnfocused;
  CupertinoTabController controller = CupertinoTabController();
  late String uid;

  @override
  void initState() {
    super.initState();
  }

  ////////////////////////////////////////////////////////////////////////
  // Gets the current state of the providers for consumption on
  // this page
  ////////////////////////////////////////////////////////////////////////
  _init() async {
    // Get providers
  }

  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      _init();
    }

    // Now initialized; run super method
    _isInit = false;
    super.didChangeDependencies();
  }
 
  ////////////////////////////////////////////////////////////////
  // Describes menu options for the chat screen
  ////////////////////////////////////////////////////////////////
  List<PopupMenuEntry<String>> _getMenu() {
    return <PopupMenuEntry<String>>[
      //////////////////////////////////////////////////////////
      // Edit-style options
      //////////////////////////////////////////////////////////
      PopupMenuItem(
        child: Row(children: [Icon(Icons.share, size: 25), SizedBox(width: 10), Text("Share")]),
        value: "Share",
      ),
      PopupMenuItem(
        child: Row(children: [Icon(Icons.edit, size: 25), SizedBox(width: 10), Text("Rename")]),
        value: "Rename",
      ),
      PopupMenuItem(
        child: Row(children: [Icon(Icons.delete, size: 25), SizedBox(width: 10), Text("Delete")]),
        value: "Delete",
      ),
    ];
  }

  ////////////////////////////////////////////////////////////////
  // Takes in the current tab index and returns the appropriate
  // screen to display.
  ////////////////////////////////////////////////////////////////
  Widget _getScreenToDisplay(int currentTabIndex) {
    if (currentTabIndex == BottomNavSelection.MAIN_PAGE_SCREEN.index) {
      return ScreenMainPage();
    }
    else if (currentTabIndex == BottomNavSelection.SEARCH_SCREEN.index) {
      return ScreenSearch();
    }
    else {
      return ScreenWeather();
    }
  }

  ////////////////////////////////////////////////////////////////
  // Takes in the current tab index and returns the appropriate
  // app bar widget to display.
  ////////////////////////////////////////////////////////////////
  Widget _getAppBarTitle(int currentTabIndex) {
    if (currentTabIndex == BottomNavSelection.MAIN_PAGE_SCREEN.index)
      return Text("Main Page");
    else if (currentTabIndex == BottomNavSelection.SEARCH_SCREEN.index)
      return Text("Search");
    else
      return Text("Weather Forecast");
  }

  ////////////////////////////////////////////////////////////////
  // Takes in the current tab index and returns the appropriate
  // actions to display in the app bar (right side).
  ////////////////////////////////////////////////////////////////
  List<Widget>? _getAppBarActions(int currentTabIndex) {
    // Initialize the actions
    List<Widget> actions = [];

    
    // If not chat tab, return null (no actions)
    return actions.isEmpty ? null : actions;
  }

  ////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////


  @override
  Widget build(BuildContext context) {
    final currentTabIndex = ref.watch(
      bottomIndexProvider
    );
    final ProviderUserProfile? _providerUserProfile1 = ref.read(providerUserProfile);

    return Scaffold(
      body: _getScreenToDisplay(currentTabIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        onTap: (index) async {
          ref.read(bottomIndexProvider.notifier).change(index);
          ref.read(searchResultProvider.notifier).clean();
          ref.read(profilesProvider.notifier).clean();
          if (index == 0)
            if (_providerUserProfile1 != null && _providerUserProfile1.uid != null) {
              //await ref.read(activitiesProvider.notifier).getActivities(_providerUserProfile1.uid);
            }
          if (index == 1) {
            if (_providerUserProfile1 != null && _providerUserProfile1.uid != null) {
              await ref.read(profilesProvider.notifier).updateUserData(_providerUserProfile1.uid);
            }
          }  
        },
        items: [
          BottomNavigationBarItem(
            label: "Home",
            activeIcon: Icon(FontAwesomeIcons.house),
            icon: Icon(FontAwesomeIcons.house),
          ),
          BottomNavigationBarItem(
            label: "Search",
            activeIcon: Icon(FontAwesomeIcons.searchengin),
            icon: Icon(FontAwesomeIcons.searchengin),
          ),
          BottomNavigationBarItem(
            label: "Weather Forecast",
            activeIcon: Icon(Icons.sunny_snowing),
            icon: Icon(Icons.sunny_snowing),
          ),
        ],
      ),
    );
  }

}
