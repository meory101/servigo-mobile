import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class test extends StatefulWidget {
  const test({Key? key}) : super(key: key);

  @override
  State<test> createState() => _testState();
}

var lat, long;
gg() async {
  var cl = await Geolocator.getCurrentPosition().then((value) => (value));
  lat = cl.latitude;
  long = cl.longitude;
}

class _testState extends State<test> {
  @override
  void initState() {
    gg();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          // width: 200,
          // height: 200,
          child: GoogleMap(
            mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                  target: LatLng(-5.468364, -53.231320), zoom: 10.4746)),
        ));
  }
}
