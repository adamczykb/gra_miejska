import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
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
  // List<Marker> _markersOnTap = [];

  late FollowOnLocationUpdate _followOnLocationUpdate;
  late StreamController<double?> _followCurrentLocationStreamController;
  // Stream<NDEFMessage> stream = NFC.readNDEF();

  @override
  void initState() {
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
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            label: 'Informacje',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Mapa',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bookmark),
            icon: Icon(Icons.bookmark_border),
            label: 'Zadania',
          ),
        ],
      ),
      body: <Widget>[
        Container(
          color: Colors.red,
          alignment: Alignment.center,
          child: const Text('Page 1'),
        ),
        Container(
          color: Colors.green,
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
                    _followOnLocationUpdate != FollowOnLocationUpdate.never) {
                  setState(
                    () =>
                        _followOnLocationUpdate = FollowOnLocationUpdate.never,
                  );
                }
              },
            ),
            // ignore: sort_child_properties_last
            children: [
              TileLayer(
                minZoom: 1,
                maxZoom: 18,
                backgroundColor: Colors.green,
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              // MarkerLayer(markers: _markersOnTap),
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
          color: Colors.blue,
          alignment: Alignment.center,
          child: const Text('Page 3'),
        ),
      ][currentPageIndex],
    );
  }
}
