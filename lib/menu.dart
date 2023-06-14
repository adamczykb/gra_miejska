import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
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
  List<GeoPoint> points = [];
  // [
  //   GeoPoint(latitude: 47.4333594, longitude: 8.4680184),
  //   GeoPoint(latitude: 47.4317782, longitude: 8.4716146),
  // ],

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
          child: CompassWidget(
            destinationLatitude:
                52.4034, // Przykładowe współrzędne punktu docelowego
            destinationLongitude: 16.9150,
          ),
        ),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: OSMFlutter(
            controller: mapController,
            // userTrackingOption: const UserTrackingOption(
            //   enableTracking: true,
            //   unFollowUser: false,
            // ),
            mapIsLoading: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("Map is Loading...")
                ],
              ),
            ),
            initZoom: 19,
            // userLocationMarker: UserLocationMaker(
            //   personMarker: const MarkerIcon(
            //     icon: Icon(
            //       Icons.location_history_rounded,
            //       color: Colors.red,
            //       size: 48,
            //     ),
            //   ),
            //   directionArrowMarker: const MarkerIcon(
            //     icon: Icon(
            //       Icons.double_arrow,
            //       size: 48,
            //     ),
            //   ),
            // ),
            markerOption: MarkerOption(
              defaultMarker: const MarkerIcon(
                icon: Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 56,
                ),
              ),
            ),
            staticPoints: [
              StaticPositionGeoPoint(
                "locations",
                const MarkerIcon(
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
                // points
                [
                  GeoPoint(latitude: 47.4333594, longitude: 8.4680184),
                  GeoPoint(latitude: 47.4317782, longitude: 8.4716146),
                ],
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
