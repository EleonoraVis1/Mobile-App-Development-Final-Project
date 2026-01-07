import 'package:csc322_starter_app/widgets/general/activity.dart';
import 'package:flutter/material.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key, required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Text(
          'No activities recorded yet',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: activities.length,
      padding: EdgeInsets.all(8),
      itemBuilder: (ctx, index) => activities[index]
    );
  }
}