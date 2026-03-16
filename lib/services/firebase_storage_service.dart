import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Upload screenshot for a screen
  Future<String> uploadScreenshot(String screenId, File file) async {
    try {
      final ref = _storage.ref().child('screenshots/$screenId.png');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading screenshot: $e');
      rethrow;
    }
  }

  // Upload screenshot from image picker
  Future<String> uploadScreenshotFromPicker(String screenId) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) throw Exception('No image selected');
      
      final file = File(image.path);
      return await uploadScreenshot(screenId, file);
    } catch (e) {
      print('Error uploading screenshot from picker: $e');
      rethrow;
    }
  }

  // Get screenshot URL for a screen
  Future<String?> getScreenshotUrl(String screenId) async {
    try {
      final ref = _storage.ref().child('screenshots/$screenId.png');
      return await ref.getDownloadURL();
    } catch (e) {
      // Screenshot doesn't exist
      return null;
    }
  }

  // Delete screenshot
  Future<void> deleteScreenshot(String screenId) async {
    try {
      final ref = _storage.ref().child('screenshots/$screenId.png');
      await ref.delete();
    } catch (e) {
      print('Error deleting screenshot: $e');
      // Ignore if file doesn't exist
    }
  }
}

