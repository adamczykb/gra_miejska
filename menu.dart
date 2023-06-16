import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connection_db.dart';
import 'main.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:gra_miejska/compas_page.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MainMenu> createState() => _MainMenu();
}

class _MainMenu extends State<MainMenu> {
  final MapController _mapController = MapController();
  final List<LatLng> _latLngList = [
    LatLng(13, 77.5),
    LatLng(13.02, 77.51),
    LatLng(13.05, 77.53),
    LatLng(13.055, 77.54),
    LatLng(13.059, 77.55),
    LatLng(13.07, 77.55),
    LatLng(13.1, 77.5342),
    LatLng(13.12, 77.51),
    LatLng(13.015, 77.53),
    LatLng(13.155, 77.54),
    LatLng(13.159, 77.55),
    LatLng(13.17, 77.55),
  ];
  List<Marker> _markers = [];
  String name = '';
  String game_text = '';
  String user_hash_id = '';
  List<Widget> leaderboard = [];
  // List<Marker> _markersOnTap = [];

  late FollowOnLocationUpdate _followOnLocationUpdate;
  late StreamController<double?> _followCurrentLocationStreamController;
  // Stream<NDEFMessage> stream = NFC.readNDEF();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) => {
          setState(() {
            name = value.getString('name')!;
          }),
          get_story(value.getString('hash_id')!).then((value2) => {
                setState(() {
                  game_text = value2;
                  user_hash_id = value.getString('hash_id')!;
                  getLeaderboard(user_hash_id)
                      .then((value) => {leaderboard = value});
                })
              })
        });

    _followOnLocationUpdate = FollowOnLocationUpdate.always;
    _followCurrentLocationStreamController =
        StreamController<double?>.broadcast();
    _markers = _latLngList
        .map((point) => Marker(
            point: point,
            width: 60,
            height: 60,
            builder: (context) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CompassWidget(
                                destinationLatitude: point.latitude,
                                destinationLongitude: point.longitude)));
                  },
                  child: const Icon(
                    Icons.location_on,
                    size: 60,
                    color: Colors.blueAccent,
                  ),
                )))
        .toList();
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        NfcA? ndef = NfcA.from(tag);
        if (ndef == null) {
          print('Tag is not compatible with NfcA');
          return;
        } else {
          print(ndef.identifier);
          String identifier = "";
          for (int val in ndef.identifier) {
            identifier += val.toString();
          }
          print(int.parse(identifier));
        }
      },
    );
    super.initState();
  }

  int currentPageIndex = 0;
  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF1690ac),
            leading: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => {
                      SharedPreferences.getInstance().then((value) => {
                            value.clear().then((value) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyHomePage()),
                                ))
                          })
                    }),
            title: Text(name),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 25),
          ),
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            destinations: const <Widget>[
              NavigationDestination(
                icon: ImageIcon(AssetImage('assets/log_1ldpi.png')),
                label: 'Historia',
              ),
              NavigationDestination(
                icon: ImageIcon(AssetImage('assets/map_1ldpi.png')),
                label: 'Mapa',
              ),
              NavigationDestination(
                icon: ImageIcon(AssetImage('assets/ranking_1ldpi.png')),
                label: 'Ranking',
              ),
            ],
          ),
          body: <Widget>[
            SingleChildScrollView(
                child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Text(game_text)),
            )),
            Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _latLngList[0],
                  interactiveFlags: InteractiveFlag.all &
                      ~InteractiveFlag.rotate &
                      ~InteractiveFlag.doubleTapZoom,
                  bounds: LatLngBounds.fromPoints(_latLngList),
                  onPositionChanged: (MapPosition position, bool hasGesture) {
                    if (hasGesture &&
                        _followOnLocationUpdate !=
                            FollowOnLocationUpdate.never) {
                      setState(
                        () => _followOnLocationUpdate =
                            FollowOnLocationUpdate.never,
                      );
                    }
                  },
                  //   plugins: [
                  //     MarkerClusterPlugin(),          ],
                  //   onTap: (_) => _popupController
                  //       .hidePopup(),
                  //
                ),
                // ignore: sort_child_properties_last
                children: [
                  TileLayer(
                    minZoom: 1,
                    maxZoom: 18,
                    backgroundColor: Colors.white,
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  CurrentLocationLayer(
                    followCurrentLocationStream:
                        _followCurrentLocationStreamController.stream,
                    followOnLocationUpdate: _followOnLocationUpdate,
                  ),
                  MarkerLayer(markers: _markers),
                ],
                nonRotatedChildren: [
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: FloatingActionButton(
                      onPressed: () {
                        // Follow the location marker on the map when location updated until user interact with the map.
                        setState(
                          () => _followOnLocationUpdate =
                              FollowOnLocationUpdate.always,
                        );
                        // Follow the location marker on the map and zoom the map to level 18.
                        _followCurrentLocationStreamController.add(18);
                      },
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: ListView(
                  padding: const EdgeInsets.all(8), children: leaderboard),
            ),
          ][currentPageIndex],
        ),
        onWillPop: () async {
          return false;
        });
  }
}
