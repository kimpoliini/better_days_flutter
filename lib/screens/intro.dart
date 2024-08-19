import 'dart:developer';

import 'package:better_days_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ButtonStyle disabled = ButtonStyle(
    elevation: WidgetStateProperty.all(0),
    backgroundColor: WidgetStateProperty.all(Colors.grey.shade400));

ButtonStyle enabled =
    ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.white));

TextStyle white = const TextStyle(color: Colors.white);
String name = "";

class Intro extends StatelessWidget {
  const Intro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.green.shade200,
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "helo",
                    style: const TextStyle(fontSize: 48.0).merge(white),
                  ),
                  Text(
                    "wat name",
                    style: white,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value) => name = value,
                        decoration:
                            const InputDecoration.collapsed(hintText: 'Name'),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ),
                  ElevatedButton(
                      style: enabled,
                      onPressed: () async {
                        bool validName = checkName();
                        log("name is ${name.isNotEmpty ? name : "empy"}");

                        if (validName) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString("firstName", name);
                          await prefs.setBool("hasSeenIntro", true);

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const MainPage()));
                        }
                      },
                      child: const Text("done"))
                ],
              ),
            ),
            const Spacer(flex: 5),
          ],
        ),
      ),
    );
  }

  bool checkName() => name.isNotEmpty;
}
