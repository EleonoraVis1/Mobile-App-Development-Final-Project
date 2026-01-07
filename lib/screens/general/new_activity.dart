import 'dart:io';
import 'package:csc322_starter_app/data/categories.dart';
import 'package:csc322_starter_app/db_helpers/public_user_service.dart';
import 'package:csc322_starter_app/main.dart';
import 'package:csc322_starter_app/providers/provider_user_profile.dart';
import 'package:csc322_starter_app/widgets/general/activity.dart';
import 'package:csc322_starter_app/models/category.dart';
import 'package:csc322_starter_app/providers/provider_activities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class NewActivity extends ConsumerStatefulWidget {
  const NewActivity({super.key});

  @override
  ConsumerState<NewActivity> createState() => _NewActivityState();
}

class _NewActivityState extends ConsumerState<NewActivity> {
  final _formKey = GlobalKey<FormState>();
  var _enteredTitle = '';
  var _enteredDescription = '';
  var _selectedCategory = categories[Categories.run];
  var _enteredTime = 1;
  var _enteredMileage = 1.0;
  final List<File> _images = [];
  final _publicUserService = PublicUserService();

  Future<void> _addPhoto() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedImage == null) return;

    setState(() {
      _images.add(File(pickedImage.path));
    });
  }

  void _saveItem() {
    String initials = '';
    final now = DateTime.now();
    final formatted = DateFormat('dd MMM yyyy, HH:mm').format(now);
    final ProviderUserProfile provider = ref.read(providerUserProfile);
    ImageProvider? image1 = provider.userImage;
    try {
      if (provider.firstName != null && provider.lastName != null){
        String fn = provider.firstName[0];
        String ln = provider.lastName[0];

        String i1 = fn.isEmpty ? "" : fn.substring(0, 1);
        String i2 = ln.isEmpty ? "" : ln.substring(0, 1);

        initials = (i1 + i2).trim();
        initials = initials.isEmpty ? "ME" : initials;
      }
     } catch(e) {}
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      final activity = Activity(
        uid: uid,
        title: _enteredTitle,
        description: _enteredDescription,
        mileage: _enteredMileage,
        time: _enteredTime,
        category: _selectedCategory!,
        images: _images,
        username: "${provider.firstName} ${provider.lastName}",
        createdAt: formatted,
        image: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        image1 != null ? image1 : null,
                    child: image1 == null
                        ? Text(initials)
                        : null,
                  )
      );
  
      _publicUserService.writeAnActivity(id: activity.id, title: _enteredTitle, description: _enteredDescription, mileage: _enteredMileage, time: _enteredTime, category: _selectedCategory!.title);
      _publicUserService.writeActivityPhotos(id: activity.id, images: _images);
      ref.read(activitiesProvider.notifier).addActivity(activity);
      Navigator.of(context).pop();
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _images.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new activity'),
        actions: [
          IconButton(
            onPressed: _addPhoto,
            icon: const Icon(Icons.image),
            tooltip: 'Add image',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 2 ||
                          value.trim().length > 50) {
                        return 'Must be between 2 and 50 characters';
                      }
                      return null;
                    },
                    onSaved: (value) => _enteredTitle = value!,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    maxLength: 300,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 2 ||
                          value.trim().length > 300) {
                        return 'Must be between 2 and 300 characters';
                      }
                      return null;
                    },
                    onSaved: (value) => _enteredDescription = value!,
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    items: [
                      for (final category in categories.entries)
                        DropdownMenuItem(
                          value: category.value,
                          child: Text(category.value.title),
                        )
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 14),

                  _images.isEmpty
                      ? const Text('No images added yet.')
                      : SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _images[index],
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 14),

                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Mileage'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    initialValue: _enteredMileage.toString(),
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Must be a valid, positive number';
                      }
                      return null;
                    },
                    onSaved: (value) =>
                        _enteredMileage = double.parse(value ?? '0'),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Time (minutes)'),
                    keyboardType: TextInputType.number,
                    initialValue: _enteredTime.toString(),
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Must be a valid, positive number';
                      }
                      return null;
                    },
                    onSaved: (value) =>
                        _enteredTime = int.parse(value ?? '0'),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _resetForm,
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _saveItem,
                        child: const Text('Add Item'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
