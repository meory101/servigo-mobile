import 'dart:convert';
import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:geolocator/geolocator.dart';
import 'package:servigo/categories/categories.dart';
import 'package:servigo/chat_pages/chat_home.dart';
import 'package:servigo/chat_pages/room.dart';
import 'package:servigo/components/pricetagdesign.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/main.dart';
import 'package:servigo/pages/map.dart';
import 'package:servigo/pages/pricetag.dart';
import 'package:servigo/pages/showprofile.dart';
import 'package:servigo/pages/test.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Info extends StatefulWidget {
  var maincategory;
  Info({required this.maincategory});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var subcategories;
  var latlong;
  List items = [];
  List cards = [];
  String? selecteditem;
  String? selecteditemid;
  late Future futureitems;
  late Future futurecards;
  String? profileid;
  void initState() {
    super.initState();
    futureitems = getsideItems();
    futurecards = getAllPricings(null);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  createRoom(userid2) async {
    print(userid2);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    String? userid1 = prefs.getString('userid');
    print(userid1);
    http.Response response = await http.post(Uri.parse(createroom), headers: {
      'Authorization': 'Bearer ${token}'
    }, body: {
      'title': 'room',
      'userid1': '$userid1',
      'userid2': '$userid2',
      'lat': latlong == null ? 'null' : '${latlong[0]}',
      'long': latlong == null ? 'null' : '${latlong[1]}'
    });
    if (!mounted) return;
    print(response.body);
    var body = jsonDecode(response.body);
    print(body);
    if (body['status'] == 'success') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return Room(
              roomid: '${body['roomid']}',
              userprofile: body['userprofile'],
              subcategoryid: ['${selecteditemid}']);
        },
      ));
    }
  }

  getsideItems() async {
    print(widget.maincategory);
    subcategories = await getsubCategories();
    if (subcategories['status'] == 'success') {
      subcategories = subcategories['message'];
      for (int i = 0; i < subcategories.length; i++) {
        if (subcategories[i]['maincategorydata']['name'] ==
            '${widget.maincategory['name']}') {
          items.add(subcategories[i]);
        }
      }
            if (!mounted) return;

      setState(() {
        selecteditem = items[0]['subcategorydata']['name'];
        selecteditemid = '${items[0]['subcategorydata']['id']}';
      });
      return (items);
    }
  }

  getAllPricings(List? latlong) async {
    cards.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    profileid = await prefs.getString('profileid');
    setState(() {});
    http.Response response = await http.get(Uri.parse(getallpricing),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body = jsonDecode(response.body);
    if (body['status'] == 'success') {
      body = body['message'];
      if (latlong != null) {
        for (int i = 0; i < body.length; i++) {
          if (body[i]['pricingsubcategory']['name'] == selecteditem) {
            print(Geolocator.distanceBetween(
                    double.parse(latlong[0]),
                    double.parse(latlong[1]),
                    double.parse(body[i]['profiledata']['lat']),
                    double.parse(body[i]['profiledata']['long'])) /
                1000);
            if (Geolocator.distanceBetween(
                        double.parse(latlong[0]),
                        double.parse(latlong[1]),
                        double.parse(body[i]['profiledata']['lat']),
                        double.parse(body[i]['profiledata']['long'])) /
                    1000.0 <=
                body[i]['profiledata']['distance']) {
              cards.add(body[i]);
            }
          }
        }
      } else {
        for (int i = 0; i < body.length; i++) {
          if (body[i]['pricingsubcategory']['name'] == selecteditem) {
            cards.add(body[i]);
          }
        }
      }
      setState(() {});
      return cards;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        endDrawer: SafeArea(
          child: SingleChildScrollView(
            child: SideMenu(
              hasResizer: false,
              minWidth: MediaQuery.of(context).size.width - 190,
              maxWidth: MediaQuery.of(context).size.width - 190,
              builder: (data) => SideMenuData(
                  header: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    height: MediaQuery.of(context).size.height,
                    child: FutureBuilder(
                        future: futureitems,
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: maincolor,
                                      borderRadius: BorderRadius.circular(
                                          border_rad_size),
                                      border: Border.all(color: maincolor)),
                                  margin: EdgeInsets.only(top: 20),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 7),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selecteditem =
                                            '${snapshot.data[index]['subcategorydata']['name']}';
                                        selecteditemid =
                                            '${snapshot.data[index]['subcategorydata']['id']}';
                                      });
                                      print(
                                          '99999999999999999999999999999999999');
                                      print(selecteditemid);
                                      futurecards = getAllPricings(latlong);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      '${snapshot.data[index]['subcategorydata']['name']}',
                                      style: wsubts,
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: maincolor,
                              ),
                            );
                          } else {
                            return Container(
                              margin: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).size.height / 2),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/planet.png',
                                      height: 100,
                                      width: 100,
                                    ),
                                    Text(
                                      'Nothing is found!',
                                      style: psubts,
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                        }),
                  ),
                  items: []),
            ),
          ),
        ),
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                child: Image.asset(
                  'assets/images/list.png',
                  width: 20,
                ),
                onTap: () {
                  scaffoldKey.currentState!.openEndDrawer();
                },
              ),
            ),
          ],
          toolbarHeight: MediaQuery.of(context).size.height / 7,
          elevation: 0,
          backgroundColor: maincolor,
          title: Text(
            "${widget.maincategory['name']}",
            style: wsubts,
          ),
        ),
        body: Stack(children: [
          FutureBuilder(
            future: futurecards,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return '${snapshot.data[index]['pricingdata']['profileid']}' ==
                              '$profileid'
                          ? Text('')
                          : InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                    return xProfile(
                                        i: "0",
                                        userid:
                                            '${snapshot.data[index]['pricingdata']['profile']['userid']}');
                                  },
                                ));
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(border_rad_size),
                                  color: Colors.transparent,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Container(
                                                width: 80,
                                                height: 80,
                                                child:
                                                    '${snapshot.data[index]['profiledata']['imageurl']}' ==
                                                            "null"
                                                        ? CircleAvatar(
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                        93,
                                                                        83,
                                                                        81,
                                                                        81)
                                                                    .withOpacity(
                                                                        0.4),
                                                            backgroundImage:
                                                                AssetImage(
                                                                    'assets/images/user.png'),
                                                          )
                                                        : CircleAvatar(
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                        93,
                                                                        83,
                                                                        81,
                                                                        81)
                                                                    .withOpacity(
                                                                        0.4),
                                                            backgroundImage: NetworkImage(
                                                                '$serverlink' +
                                                                    '/storage/' +
                                                                    '${snapshot.data[index]['profiledata']['imageurl']}'),
                                                          ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 17),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${snapshot.data[index]['name']}',
                                                    style: btitle,
                                                  ),
                                                  Text(
                                                    '${snapshot.data[index]['profiledata']['teamsize']}',
                                                    style: greyts,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    pricetagDesign(
                                      context,
                                      '${snapshot.data[index]['pricingdata']['price']}' ==
                                              null
                                          ? Text(
                                              '${snapshot.data[index]['pricingdata']['price']}',
                                              style: greyts,
                                            )
                                          : Text(''),
                                      Text(
                                        '${snapshot.data[index]['pricingsubcategory']['name']}',
                                        style: bsmallts,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '${snapshot.data[index]['pricingdata']['content']}',
                                            style: bg,
                                          ),
                                          latlong == null &&
                                                  '${widget.maincategory['servicetype']['name']}' ==
                                                      'Human services'
                                              ? Text('')
                                              : Container(
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 20, right: 20),
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 100,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: maincolor
                                                              .withOpacity(0.4),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                border_rad_size),
                                                        color: maincolor,
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          createRoom(
                                                              '${snapshot.data[index]['pricingdata']['profile']['userid']}');
                                                        },
                                                        child: Text(
                                                          'Contact',
                                                          style: wsmallts,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                    });
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: maincolor),
                );
              } else {
                return Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height / 2),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/planet.png',
                          height: 100,
                          width: 100,
                        ),
                        Text(
                          'Nothing is found!',
                          style: psubts,
                        )
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          '${widget.maincategory['servicetype']['name']}' == 'Human services'
              ? Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    backgroundColor: maincolor,
                    onPressed: () async {
                   
                      latlong =
                          await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return GMap(
                            post: true,
                            lat: latlong != null
                                ? double.parse(latlong[0])
                                : null,
                            long: latlong != null
                                ? double.parse(latlong[1])
                                : null,
                          );
                        },
                      ));
                      if (latlong != null) {
                        latlong = latlong.split('/');
                        setState(() {
                          futurecards = getAllPricings(latlong);
                        });
                      }
                    },
                    child: Icon(Icons.location_on),
                  ),
                )
              : Text('')
        ]));
  }
}
