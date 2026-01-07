import 'dart:io';

import 'package:csc322_starter_app/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Activity extends ConsumerStatefulWidget{
  Activity({
    required this.uid,
    required this.title,
    required this.description,
    required this.mileage,
    required this.time,
    required this.category,
    required this.images,
    required this.image,
    required this.username,
    required this.createdAt,
    String? id,
  }) : id = id ?? uuid.v4();

  final String id;
  final String uid;
  final String title;
  final String description;
  final double mileage;
  final int time;
  final Category category;
  final List<File> images;
  final Widget image;
  final String username;
  final String createdAt;
  
  @override
  ConsumerState<Activity> createState() {
    return _ActivityState();
  }
}

class _ActivityState extends ConsumerState<Activity> {  

  @override
  Widget build(BuildContext context) {
    Icon? icon;

  switch (widget.category.title) {
    case 'Run':
      icon = const Icon(Icons.directions_run, size: 16);
      break;

    case 'Walk':
      icon = const Icon(FontAwesomeIcons.shoePrints, size: 16);
      break;

    case 'Ride':
      icon = const Icon(Icons.pedal_bike, size: 16);
      break;

    case 'Swim':
      icon = const Icon(Icons.pool, size: 16);
      break;

    case 'Elliptical':
      icon = const Icon(Icons.fitness_center, size: 16);
      break;

    default:
      icon = const Icon(Icons.help_outline, size: 16);
  }

    double pace = widget.time / widget.mileage; 
    int paceMinutes = pace.floor();
    int paceSeconds = ((pace - paceMinutes) * 60).round();

    if (paceSeconds == 60) {
      paceMinutes += 1;
      paceSeconds = 0;
    }

    String paceFormatted = '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')} /mi';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: const Color.fromARGB(255, 198, 198, 198),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.image,
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      Text(
                        widget.username,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          icon,
                          const SizedBox(width: 6),
                          Text(
                            widget.createdAt,           
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  Text('Distance: ${widget.mileage} mi'),
                  Text('Time: ${widget.time} m'),
                  Text('Pace: $paceFormatted'),
                ],
              ),

              const SizedBox(height: 10),

              widget.images.isEmpty
                ? const Text('No images added. (Lame)')
                : SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.images.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            widget.images[index],
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

}