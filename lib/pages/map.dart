import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/db/components.dart';
import 'package:servigo/pages/post.dart';
import 'package:servigo/pages/profile.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<FormFieldState> formkey = new GlobalKey();

class GMap extends StatefulWidget {
  bool? post;
  double? lat;
  double? long;
  String? distance;
  bool ?browse ;
  GMap({this.lat, this.long, this.distance, this.post,  this.browse});
  @override
  State<GMap> createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  String? distance;
  void initState() {
    super.initState();
    getper();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  GoogleMapController? gmc;
  Position? cl;
  var lat;
  var long;
  late Set<Marker> mymarker;
  CameraPosition? _kGooglePlex;

  getper() async {
    LocationPermission per;
    per = await Geolocator.checkPermission();
    if (per == LocationPermission.denied) {
      per = await Geolocator.requestPermission();
    }

    if (per == LocationPermission.always ||
        per == LocationPermission.whileInUse) {
      getLatAndLong();
    }
  }

  Future<void> getLatAndLong() async {
    print(widget.lat);

    if (widget.lat != null && widget.long != null) {
      lat = widget.lat;
      long = widget.long;
      print(widget.lat);
    } else {
      cl = await Geolocator.getCurrentPosition().then((value) => (value));
      lat = cl?.latitude;
      long = cl?.longitude;
    }

    _kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 10.4746,
    );
    if (!mounted) return;
    setState(() {
      mymarker = {
        Marker(markerId: MarkerId("1"), position: LatLng(lat, long)),
        Marker(
            onDragEnd: ((LatLng) => {print(LatLng)}),
            markerId: MarkerId("1"),
            position: LatLng(lat, long))
      };
    });
  }

  updatprofile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (formkey.currentState!.validate()) {
      var body = await updateProfile({
        'profileid': '${prefs.getString('profileid')}',
        'distance': '${distance}',
        'lat': '${lat}',
        'long': '${long}'
      });

      if (body['status'] == 'success') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              return Profile(
                i: "0",
              );
            },
          ),
          (route) => false,
        );
      } else {
        Blurry.error(
            title: 'Opps error',
            description: 'Something went wrong please try again',
            confirmButtonText: 'Okay',
            titleTextStyle: const TextStyle(fontFamily: 'Zen'),
            buttonTextStyle: const TextStyle(
                decoration: TextDecoration.underline, fontFamily: 'Zen'),
            descriptionTextStyle: const TextStyle(fontFamily: 'Zen'),
            onConfirmButtonPressed: () {
              Navigator.of(context).pop();
            }).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
            child: Stack(children: [
          Container(
            child: _kGooglePlex == null
                ? Center(
                    child: CircularProgressIndicator(
                    color: maincolor,
                  ))
                : Container(
                    margin: EdgeInsets.only(
                        top: widget.post == false
                            ? MediaQuery.of(context).size.height / 9
                            : 0),
                    child: GoogleMap(
                      onTap: (LatLng) {
                     widget.browse==null?   setState(() {
                          mymarker.add(Marker(
                              markerId: MarkerId("1"), position: LatLng));
                          lat = LatLng.latitude;
                          long = LatLng.longitude;
                        })
                        
                        :print('dddddddddddddd');
                      },
                      markers: mymarker,
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex!,
                      onMapCreated: (GoogleMapController controller) {
                        gmc = controller;
                      },
                    ),
                  ),
          ),
          if (widget.post == false)
            ...([
              Container(
                height: MediaQuery.of(context).size.height / 8,
                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                child: customField(
                    validator: (p0) {
                      if (p0!.length == 0) {
                        return 'Can\'t be empty';
                      }
                      print(int.parse(p0));
                      if (int.parse(p0) > 50) {
                        return 'You can\'t work in this distance range';
                      }
                      setState(() {
                        distance = p0;
                      });
                      return null;
                    },
                    fromkey: formkey,
                    ketype: TextInputType.number,
                    hint: 'distanse to work in',
                    val: widget.distance == null ? null : widget.distance,
                    suffix: Text(
                      'km',
                      style: psmallts,
                    )),
              ),
            ]),
          Container(
            margin: EdgeInsets.only(top: 30, bottom: 30, right: 30),
            alignment: Alignment.bottomRight,
            child: Container(
              alignment: Alignment.center,
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: maincolor.withOpacity(0.4),
                ),
                borderRadius: BorderRadius.circular(border_rad_size),
                color: maincolor,
              ),
              child: InkWell(
                onTap: () {
                  if (widget.post == false) {
                    formkey.currentState!.validate();
                    updatprofile();
                  } else {
                    Navigator.of(context).pop('$lat/$long');
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: wsmallts,
                      textAlign: TextAlign.center,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        ])),
      ),
    );
  }
}
