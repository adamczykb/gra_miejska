import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

double getOffsetFromNorth(double currentLatitude, double currentLongitude,
    double targetLatitude, double targetLongitude) {
  var la_rad = radians(currentLatitude);
  var lo_rad = radians(currentLongitude);

  var de_la = radians(targetLatitude);
  var de_lo = radians(targetLongitude);

  var toDegrees = degrees(math.atan(math.sin(de_lo - lo_rad) /
      ((math.cos(la_rad) * math.tan(de_la)) -
          (math.sin(la_rad) * math.cos(de_lo - lo_rad)))));
  if (la_rad > de_la) {
    if ((lo_rad > de_lo || lo_rad < radians(-180.0) + de_lo) &&
        toDegrees > 0.0 &&
        toDegrees <= 90.0) {
      toDegrees += 180.0;
    } else if (lo_rad <= de_lo &&
        lo_rad >= radians(-180.0) + de_lo &&
        toDegrees > -90.0 &&
        toDegrees < 0.0) {
      toDegrees += 180.0;
    }
  }
  if (la_rad < de_la) {
    if ((lo_rad > de_lo || lo_rad < radians(-180.0) + de_lo) &&
        toDegrees > 0.0 &&
        toDegrees < 90.0) {
      toDegrees += 180.0;
    }
    if (lo_rad <= de_lo &&
        lo_rad >= radians(-180.0) + de_lo &&
        toDegrees > -90.0 &&
        toDegrees <= 0.0) {
      toDegrees += 180.0;
    }
  }
  return toDegrees;
}

class CompassWidget extends StatefulWidget {
  final double destinationLatitude;
  final double destinationLongitude;

  CompassWidget(
      {required this.destinationLatitude, required this.destinationLongitude});

  @override
  _CompassWidgetState createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  double azimuth = 0.0; // Kąt odchylenia od kierunku do punktu docelowego
  CompassEvent? _lastRead;
  DateTime? _lastReadAt;
  bool _hasPermissions = false;
  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
    _getAzimuth(); // Pobierz kąt odchylenia przy inicjalizacji
  }

  // Pobierz kąt odchylenia od aktualnej lokalizacji do punktu docelowego
  void _getAzimuth() async {
    Position position = await Geolocator.getCurrentPosition();
    double currentLatitude = position.latitude;
    double currentLongitude = position.longitude;

    // Oblicz kąt odchylenia od aktualnej lokalizacji do punktu docelowego
    double bearing = getOffsetFromNorth(position.latitude, position.longitude,
        widget.destinationLatitude, widget.destinationLongitude);

    setState(() {
      azimuth = bearing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        return Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.center,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1690ac)),
            child: Transform.rotate(
              angle: (direction * (math.pi / 180) * -1 + azimuth + 180 * -1),
              child: Icon(
                Icons.arrow_upward,
                size: 150,
              ),
            ),
          ),
        );
      },
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}
