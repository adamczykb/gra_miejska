import 'dart:async';
import 'dart:io';
import 'package:gra_miejska/menu.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:flutter/material.dart';

import 'connection_db.dart';

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

TextEditingController teamController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController nameController = TextEditingController();
void checkingAndConnectToGame(context) {
  if (_formKey.currentState!.validate()) {
    join(teamController.value.text, passwordController.value.text,
            nameController.value.text)
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
                    const SnackBar(content: Text('Złe dane dołączeniowe')),
                  )
                }
            });
  }
}

class ConnectToGame extends StatefulWidget {
  const ConnectToGame({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<ConnectToGame> createState() => _ConnectToGame();
}

class _ConnectToGame extends State<ConnectToGame> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
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
                  const Text(
                    "Dopisz się!",
                    style: TextStyle(
                        fontFamily: 'Geologica',
                        color: Colors.white,
                        fontSize: 50),
                  ),
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
                      controller: teamController,
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
                          labelText: "Nazwa drużyny"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pole nie może być puste';
                        }
                        return null;
                      },
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
                          labelText: "Hasło drużyny"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: style,
                    onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _buildQrView(context),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Zeskanuj kod',
                          style: TextStyle(fontSize: 16),
                        )),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Divider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 2) {
                          return 'Imię musi być dłuższe niż 2 znaki';
                        }
                        return null;
                      },
                      controller: nameController,
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
                          labelText: "Twoje Imię"),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    style: style,
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.

                      checkingAndConnectToGame(context);
                    },
                    child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Zaczynamy!',
                          style: TextStyle(fontFamily: 'Geologica'),
                        )),
                  ),
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

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return SizedBox(
        width: 300.0,
        height: 300.0,
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: scanArea),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ));
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      closed = false;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if (scanData.format != BarcodeFormat.unknown && scanData.code != null) {
          var text = scanData.code!.split(',');
          if (!closed &&
              text.length == 2 &&
              text[0].startsWith('nazwa:') &&
              text[1].startsWith('haslo:')) {
            teamController.text = text[0].split('nazwa:')[1];
            passwordController.text = text[1].split('haslo:')[1];
            closed = true;
            Navigator.pop(context);
          }
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
