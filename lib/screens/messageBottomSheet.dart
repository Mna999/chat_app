import 'package:chat_app/models/messages.dart';
import 'package:flutter/material.dart';

class Messagebottomsheet extends StatelessWidget {
  Messagebottomsheet({super.key, required this.message});
  Message message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: const ListTile(
              title: Text(
                'Delete',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.delete, color: Colors.red),
            ),
          ),
          Container(
            child: const ListTile(
              title: Text(
                'Edit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.edit, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
