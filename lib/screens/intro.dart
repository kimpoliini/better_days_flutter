import 'dart:developer';

import 'package:better_days_flutter/main.dart';
import 'package:better_days_flutter/states/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

ButtonStyle disabled = ButtonStyle(
    elevation: WidgetStateProperty.all(0),
    backgroundColor: WidgetStateProperty.all(Colors.grey.shade400));

ButtonStyle enabled =
    ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.white));

TextStyle white = const TextStyle(color: Colors.white);
List<TextEditingController> controllers = <TextEditingController>[];
String firstName = "";
String lastName = "";

class Intro extends StatelessWidget {
  const Intro({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();

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
              flex: 1,
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
                      child: Column(
                        children: [
                          TextField(
                            autofillHints: const [AutofillHints.namePrefix],
                            onChanged: (value) => firstName = value,
                            decoration: const InputDecoration.collapsed(
                                hintText: 'First name'),
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20.0),
                          TextField(
                            autofillHints: const [AutofillHints.nameSuffix],
                            onChanged: (value) => lastName = value,
                            decoration: const InputDecoration.collapsed(
                                hintText: 'Last name (optional)'),
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                      style: enabled,
                      onPressed: () async {
                        bool validName = checkName();

                        if (validName) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString("firstName", firstName);
                          await prefs.setString("lastName", lastName);
                          await prefs.setBool("hasSeenIntro", true);

                          state.updateUser();

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const MainPage()));
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("First name required"),
                            duration: Duration(seconds: 2),
                          ));
                        }
                      },
                      child: const Text("done"))
                ],
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  bool checkName() => firstName.isNotEmpty;
}
