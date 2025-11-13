import 'dart:developer';
import 'dart:io';

import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/user.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class Imagecontroller {
  final ImagePicker picker = ImagePicker();
  final UserController userController = UserController();
  final cloudinary = CloudinaryPublic('dcga1llsc', 'dsdsds');
  File? pickedImage;

  Future<void> pickImage(ImageSource source, User user) async {
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;
    pickedImage = File(image.path);
    String? url = await _uploadPfp(user.id);

    if (url == null) return;
    log(url);
    user.profilePictureUrl = url;
    userController.updateUserForFriends(user);
  }

  Future<String?> _uploadPfp(String id) async {
    if (pickedImage == null) return null;

    final res = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        pickedImage!.path,
        resourceType: CloudinaryResourceType.Image,
        folder: 'pfp/$id',
      ),
    );
    return res.secureUrl;
  }
}
