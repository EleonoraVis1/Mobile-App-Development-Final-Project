// -----------------------------------------------------------------------
// Filename: screen_settings.dart
// Original Author: Wyatt Bodle
// Creation Date: 6/06/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the screen for optional settings.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:csc322_starter_app/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:csc322_starter_app/widgets/navigation/widget_primary_app_bar.dart';

// App relative file imports
import '../../providers/provider_user_profile.dart';
import '../../util/message_display/popup_dialogue.dart';
import '../../util/message_display/snackbar.dart';
import '../../util/logging/app_logger.dart';
import '../../main.dart';

//////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////
class ScreenSettings extends ConsumerStatefulWidget {
  const ScreenSettings({super.key});

  static const routeName = '/settings';

  @override
  ConsumerState<ScreenSettings> createState() => _ScreenSettingsState();
}

//////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _ScreenSettingsState extends ConsumerState<ScreenSettings> {
  // The "instance variables" managed in this state
  var _isInit = true;
  late ProviderUserProfile _providerUserProfile;
  String selectedHour = '12';
  String selectedMinute = '0';
  String actualH = '';
  String selectedAmPm = 'AM';

  List<String> hours = List.generate(12, (index) => (index + 1).toString());
  List<String> minutes = List.generate(60, (index) => index.toString());
  List<String> amPm = ['AM', 'PM'];


  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      _init();

      // Now initialized; run super method
      _isInit = false;
      super.didChangeDependencies();
    }
  }
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  /// Helper Methods (for state object)
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////
  // Gets the current state of the providers for consumption on
  // this page
  ////////////////////////////////////////////////////////////////
  Future<void> _init() async {
    // Get providers
    _providerUserProfile = ref.watch(providerUserProfile);

    //Get and set the saved pitch and speed
    getCurrentData();
  }

  ////////////////////////////////////////////////////////////////
  // Gets the current data for consumption on
  // this page
  ////////////////////////////////////////////////////////////////
  void getCurrentData() async {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  ////////////////////////////////////////////////////////////////
  // Submits the current data to the _providerprofile
  ////////////////////////////////////////////////////////////////
  void _trySubmit() async {
    // Unfocus from any controls that may have focus to disengage the keyboard
    FocusScope.of(context).unfocus();

    
    //Save the data to the provider
    _providerUserProfile.writeUserProfileToDb();
    if (selectedAmPm == 'AM') {
      if (selectedHour == '12')
        actualH = '0';
      else
        actualH = selectedHour;
    } else {
      if (selectedHour == '12') {
        actualH = '12';
      } else {
        int hour = int.parse(selectedHour) + 12;
        actualH = hour.toString();
      }

    }

    await NotificationService.scheduleDailyNotification(
      hour: int.parse(actualH),
      minute: int.parse(selectedMinute),
    );  


    Snackbar.show(SnackbarDisplayType.SB_SUCCESS, 'A daily notification was set up successfully', context);
    context.pop();
  }

  //////////////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  //////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetPrimaryAppBar(
        title: const Text('A daily notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedHour,
                  items: hours
                      .map((hour) => DropdownMenuItem(
                            value: hour,
                            child: Text(hour),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedHour = value!),
                ),
                const Text(': '),
                DropdownButton<String>(
                  value: selectedMinute,
                  items: minutes
                      .map((minute) => DropdownMenuItem(
                            value: minute,
                            child: Text(minute),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedMinute = value!),
                ),
                DropdownButton<String>(
                  value: selectedAmPm,
                  items: amPm
                      .map((ap) => DropdownMenuItem(
                            value: ap,
                            child: Text(ap),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedAmPm = value!),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _trySubmit, 
                child: const Text('Save')
              ),
            ),
          ],
        ),
      ),
    );
  }
}
