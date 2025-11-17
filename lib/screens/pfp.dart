import 'package:chat_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class Pfp extends StatefulWidget {
  Pfp({super.key, required this.user});
  User user;

  @override
  State<Pfp> createState() => _PfpState();
}

class _PfpState extends State<Pfp> {
  double scale = 0.5;
  bool isZoomed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.username)),
      body: Center(
        child: Hero(
          tag: 'pfp',
          child:
              widget.user.profilePictureUrl == '' ||
                  widget.user.profilePictureUrl == null
              ? Image.asset(
                  'assets/images/chatApp ui ux/icons8-user-50.png',
                  width: double.infinity,
                  fit: BoxFit.fill,
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height * scale,
                  width: double.infinity,
                  child: ClipRRect(
                    child: PhotoView(
                      initialScale: PhotoViewComputedScale.covered,
                      maxScale: PhotoViewComputedScale.covered * 4,
                      minScale: PhotoViewComputedScale.covered * 1,
                      tightMode: false,
                      onTapUp: (context, details, controllerValue) {
                        if (isZoomed) {
                          scale = 0.5;
                          isZoomed = false;
                        } else {
                          scale = 1;
                          isZoomed = true;
                        }

                        setState(() {});
                      },
                      imageProvider: NetworkImage(
                        widget.user.profilePictureUrl ?? '',
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
