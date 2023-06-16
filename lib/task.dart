import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connection_db.dart';
import 'menu.dart';

List<Color> get getColorsList => [
      const Color(0xFF05aea4),
      const Color(0xFF1690ac),
    ]..shuffle();

/// Generate list of alignment which will be used to
/// set gradient start and end for random color animation.
List<Alignment> get getAlignments => [
      Alignment.topLeft,
      Alignment.bottomRight,
    ];

var counter = 0;
var closed = true;
final _formKey = GlobalKey<FormState>();

TextEditingController answerController = TextEditingController();

class TaskGame extends StatefulWidget {
  final String task_id;
  String user_hash_id = '';
  String task_text = '';
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  TaskGame({required this.task_id});

  @override
  State<TaskGame> createState() => _TaskGame();
}

class _TaskGame extends State<TaskGame> {
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  void checkingAndSentAnswer(context) {
    if (_formKey.currentState!.validate()) {
      set_answer(
              widget.user_hash_id, widget.task_id, answerController.value.text)
          .then((value) => {
                if (value)
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MainMenu()),
                    )
                  }
                else
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Zła odpowiedz')),
                    )
                  }
              });
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => {
          setState(() {
            widget.user_hash_id = value.getString('hash_id')!;
          }),
          get_task_text(value.getString('hash_id')!, widget.task_id)
              .then((value2) => {
                    setState(() {
                      widget.task_text = value2;
                    })
                  })
        });
    if (!mounted) {
      _startBgColorAnimationTimer();
    }
  }

  /// We will animate the gradient every 5 seconds
  _startBgColorAnimationTimer() {
    ///Animating for the first time.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      counter++;
      if (!mounted) {
        setState(() {});
      }
    });

    const interval = Duration(seconds: 1);
    Timer.periodic(
      interval,
      (Timer timer) {
        counter++;
        if (!mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
    );
    return Scaffold(
      body: Stack(children: [
        AnimatedContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: getAlignments[counter % getAlignments.length],
              end: getAlignments[(counter) % getAlignments.length],
              colors: getColorsList,
              tileMode: TileMode.clamp,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
        SingleChildScrollView(
            child: Form(
                key: _formKey,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  const SizedBox(height: 64),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Text(widget.task_text,
                          style: TextStyle(
                              fontFamily: 'Geologica', color: Colors.white))),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pole nie może być puste';
                        }
                        return null;
                      },
                      controller: answerController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                          focusColor: Colors.white,
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: "Odpowiedź"),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    style: style,
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.

                      checkingAndSentAnswer(context);
                    },
                    child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Wyślij!',
                          style: TextStyle(fontFamily: 'Geologica'),
                        )),
                  ),
                  const SizedBox(height: 64),
                ]))),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Bartosz Adamczyk, Filip Sudziński",
                style: TextStyle(fontFamily: 'Geologica', color: Colors.white),
              )),
        ),
      ]),
    );
  }
}
