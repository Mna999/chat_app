import 'package:chat_app/controllers/imageController.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/providers/loadingProviderAuth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class Pickimage extends ConsumerStatefulWidget {
  Pickimage({super.key, required this.user});
  User user;

  @override
  ConsumerState<Pickimage> createState() => _PickimageState();
}

class _PickimageState extends ConsumerState<Pickimage> {
  Imagecontroller imagecontroller = Imagecontroller();
  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(loadingAuthProvider);
    return PopScope(
      canPop: !isLoading,

      child: GestureDetector(
        onVerticalDragUpdate: !isLoading ? (details) {} : null,
        behavior: isLoading
            ? HitTestBehavior.opaque
            : HitTestBehavior.deferToChild,
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Please dont close this window until upload is complete',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 12),
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth / 3,
                          child: InkWell(
                            onTap: () async {
                              ref.read(loadingAuthProvider.notifier).set();

                              String? url = await imagecontroller.pickImage(
                                ImageSource.camera,
                                widget.user,
                              );
                              ref.read(loadingAuthProvider.notifier).reset();

                              if (mounted) {
                                Navigator.pop(context, url);
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
                          width: constraints.maxWidth / 3,
                          child: InkWell(
                            onTap: () async {
                              ref.read(loadingAuthProvider.notifier).set();
                              setState(() {});
                              String? url = await imagecontroller.pickImage(
                                ImageSource.gallery,
                                widget.user,
                              );
                              ref.read(loadingAuthProvider.notifier).reset();

                              if (mounted) {
                                Navigator.pop(context, url);
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
                        SizedBox(
                          width: constraints.maxWidth / 3,
                          child: InkWell(
                            onTap: () async {
                              if (mounted) {
                                Navigator.pop(context, '');
                              }
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete, size: 50, color: Colors.red),
                                SizedBox(height: 12),
                                Text(
                                  "Remove",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
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
        ),
      ),
    );
  }
}
