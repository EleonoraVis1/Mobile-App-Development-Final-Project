import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class PhotosNotifier extends StateNotifier<List<File>> {
  PhotosNotifier() : super([]);

  List<File> allPhotos = [];
  bool isLoading = true;

  Future<void> getPhotosByUID(String uid) async {
    state = [];
    allPhotos = [];
    isLoading = true;
    try {
      final storage = FirebaseStorage.instance;
      final postsRoot = storage.ref().child('users/$uid/posts');

      final tempDir = await getTemporaryDirectory();

      ListResult folderList;
      try {
        folderList = await postsRoot.listAll();
      } catch (_) {
        state = [];
        isLoading = false;
        return;
      }

      for (var folderRef in folderList.prefixes) {
        ListResult fileList;

        try {
          fileList = await folderRef.listAll();
        } catch (_) {
          continue; 
        }

        for (var fileRef in fileList.items) {
          try {
            final bytes = await fileRef.getData();

            if (bytes == null) continue;

            final file = File('${tempDir.path}/${folderRef.name}_${fileRef.name}');
            await file.writeAsBytes(bytes);

            allPhotos.add(file);
          } catch (_) {}
        }
      }
    } catch (_) {}

    state = allPhotos;
    isLoading = false;
  }

  void clear() {
    allPhotos = [];
    state = [];
  }
}

final userPhotosProvider =
    StateNotifierProvider<PhotosNotifier, List<File>>((ref) {
  return PhotosNotifier();
});
