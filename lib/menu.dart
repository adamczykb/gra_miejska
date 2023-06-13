import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

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

MapController mapController = MapController(
  // initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
  initMapWithUserPosition: const UserTrackingOption(enableTracking: true),
  areaLimit: BoundingBox(
    east: 10.4922941,
    north: 47.8084648,
    south: 45.817995,
    west: 5.9559113,
  ),
);

class _MainMenu extends State<MainMenu> {
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
          child: OSMFlutter(
            controller: mapController,
            initZoom: 21,
            markerOption: MarkerOption(
              defaultMarker: MarkerIcon(
                icon: Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 56,
                ),
              ),
            ),
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
