import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/user.dart';
import 'package:flutter/material.dart';

class Editbottomsheet extends StatefulWidget {
  Editbottomsheet({super.key, required this.user, required this.state});
  User user;
  VoidCallback state;
  @override
  State<Editbottomsheet> createState() => _EditbottomsheetState();
}

class _EditbottomsheetState extends State<Editbottomsheet> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController username = TextEditingController();
  TextEditingController bio = TextEditingController();
  UserController userController = UserController();
  @override
  void initState() {
    super.initState();
    username.text = widget.user.username;
    bio.text = widget.user.bio ?? "...";
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
        child: Column(
          children: [
            const Text(
              "Edit Details",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            TextFormField(
              decoration: const InputDecoration(labelText: "Username"),
              controller: username,
              validator: (val) {
                if (val != null) {
                  if (val.trim().isEmpty) {
                    return "Please fill the field";
                  }
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 50),
            TextFormField(
              decoration: const InputDecoration(labelText: "Bio"),
              controller: bio,
            ),
            const Spacer(),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    var bioComp = widget.user.bio ?? "...";
                    if (widget.user.username.trim() != username.text.trim() ||
                        bioComp.trim() != bio.text.trim()) {
                      widget.user.username = username.text.trim();
                      widget.user.bio = bio.text.trim();
                      userController.updateUserForFriends(widget.user);
                      widget.state();
                    }
                  }
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
