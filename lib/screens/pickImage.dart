import 'package:chat_app/controllers/imageController.dart';
import 'package:chat_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Pickimage extends StatefulWidget {
  Pickimage({super.key, required this.user, required this.state});
  User user;
  VoidCallback state;

  @override
  State<Pickimage> createState() => _PickimageState();
}

class _PickimageState extends State<Pickimage> {
  Imagecontroller imagecontroller = Imagecontroller();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.25,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth * 0.5,
                      child: InkWell(
                        onTap: () async {
                          isLoading = true;
                          setState(() {});
                          await imagecontroller.pickImage(
                            ImageSource.camera,
                            widget.user,
                          );
                          isLoading = false;

                          widget.state();
                          if (mounted) {
                            setState(() {});
                            Navigator.pop(context);
                          }
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Camera",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth * 0.5,
                      child: InkWell(
                        onTap: () async {
                          isLoading = true;
                          setState(() {});
                          await imagecontroller.pickImage(
                            ImageSource.gallery,
                            widget.user,
                          );
                          isLoading = false;
                          widget.state();
                          if (mounted) {
                            setState(() {});
                            Navigator.pop(context);
                          }
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 50, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              "Gallery",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
