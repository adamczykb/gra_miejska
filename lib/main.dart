import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gra_miejska/connect_to_game.dart';
import 'package:gra_miejska/menu.dart';

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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gra miejska',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1690ac)),
        useMaterial3: true,
      ),
      home: const MainMenu(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ///Start animation.
  @override
  void initState() {
    super.initState();
    _startBgColorAnimationTimer();
  }

  /// We will animate the gradient every 5 seconds
  _startBgColorAnimationTimer() {
    ///Animating for the first time.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      counter++;
      setState(() {});
    });

    const interval = Duration(seconds: 5);
    Timer.periodic(
      interval,
      (Timer timer) {
        counter++;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
    );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // appBar: AppBar(
      //   // TRY THIS: Try changing the color here to a specific color (to
      //   // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
      //   // change color while the other colors stay the same.
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: Stack(
        children: [
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
            duration: const Duration(seconds: 1),
          ),
          Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Image(
                image: NetworkImage(
                    'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                height: 200),
            const SizedBox(height: 50),
            ElevatedButton(
              style: style,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ConnectToGame()),
                );
              },
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Zacznij przygodę',
                    style: TextStyle(fontFamily: 'Geologica'),
                  )),
            ),
          ])),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Bartosz Adamczyk, Filip Sudziński",
                  style:
                      TextStyle(fontFamily: 'Geologica', color: Colors.white),
                )),
          ),
        ],
      ),
    );
  }
}
