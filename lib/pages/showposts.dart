import 'dart:convert';
import 'package:blurry/blurry.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable_menu/expandable_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:servigo/chat_pages/room.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/showprofile.dart';
import 'package:servigo/pages/test1.dart';
import 'package:servigo/pages/updatepost.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class showPosts extends StatefulWidget {
  bool posts;
  String? profileid;
  showPosts({required this.posts, this.profileid});
  @override
  State<showPosts> createState() => _showPostsState();
}

class _showPostsState extends State<showPosts> {
  var body;
  var usersubcategories = [];
  late Future myfuture;
  late Future allposts;
  late Future specialposts;
  bool myservice = false;
  String? userType;
  var limitposts = [];
  void initState() {
    super.initState();
    allposts = getallPosts();
    specialposts = getspecialPosts();
    myfuture = getPosts();

    print('0000000000000000000000000000000');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  createRoom(userid2, postid, lat, long) async {
    print(userid2);
    print(lat);
    print(long);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    String? userid1 = await prefs.getString('userid');
    print(userid1);
    if (userid2 != null) {
      http.Response response = await http.post(Uri.parse(createroom), headers: {
        'Authorization': 'Bearer ${token}'
      }, body: {
        'title': 'room',
        'userid1': '$userid1',
        'userid2': '$userid2',
        'lat': '$lat',
        'long': '$long',
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
              postid: "$postid",
            );
          },
        ));
      }
    }
  }

  int? servicetype;
  getallPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    userType = await prefs.getString('userType');
    print(userType);
    setState(() {});
    String? profileid = await prefs.getString('profileid');
    String? userid = await prefs.getString('userid');

    http.Response response = await http.get(
        Uri.parse('${getprofile}' + '/${userid}'),
        headers: {'Authorization': 'Bearer ${token}'});
    body = jsonDecode(response.body);

    if (!mounted) return;
    if (body['status'] == 'success') {
      body = body['message'];
      for (int i = 0; i < body['subcategorydata'].length; i++) {
        if (usersubcategories.contains(body['subcategorydata'][i]['name']) ==
            false) {
          usersubcategories.add(body['subcategorydata'][i]['name']);
          servicetype = body['main']['servicetypeid'];
        }
      }
      if (usersubcategories.length == 1) {
        usersubcategories.add('l');
      }
      print(usersubcategories);
      http.Response response = await http.get(
          Uri.parse(getallposts + '/$profileid'),
          headers: {'Authorization': 'Bearer ${token}'});
      var body1 = jsonDecode(response.body);

      if (body1['status'] == 'success') {
        return body1['message'];
      }
    }
  }

  getspecialPosts() async {
    limitposts.clear();
    var cards = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    String? profileid = await prefs.getString('profileid');
    String? userid = await prefs.getString('userid');
    http.Response response = await http.get(
        Uri.parse(getallposts + '/$profileid'),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body1 = jsonDecode(response.body);
    if (body1['status'] == 'success') {
      if (myservice == true) {
        print(body1['message']);
        print(usersubcategories.length);
        for (int i = 0; i < body1['message'].length; i++) {
          for (int j = 0; j < usersubcategories.length; j++) {
            if (body1['message'][i]['subcategorydata']['name'] ==
                usersubcategories[j]) {
              limitposts.add(body1['message'][i]);
              print(limitposts);
            }
          }
        }
      }
      if (servicetype == 2) {
        http.Response response2 = await http.get(
            Uri.parse(getprofile + '/$userid'),
            headers: {'Authorization': 'Bearer ${token}'});
        var body2 = jsonDecode(response2.body);
        body2 = body2['message'];
        for (int i = 0; i < limitposts.length; i++) {
          if (Geolocator.distanceBetween(
                      double.parse(body2['profiledata']['lat']),
                      double.parse(body2['profiledata']['long']),
                      double.parse('${limitposts[i]['postdata']['lat']}'),
                      double.parse('${limitposts[i]['postdata']['long']}')) /
                  1000.0 <=
              body2['profiledata']['distance']) {
            cards.add(limitposts[i]);
          }
        }
        return cards;
      }

      return limitposts;
      // return limitposts;
    }
  }

  deletePost(index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    http.Response response = await http.post(
        body: {'id': '${index}'},
        Uri.parse(deletepost),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body = jsonDecode(response.body);
    if (body['status'] == 'failed') {
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
    } else {
      setState(() {
        myfuture = getPosts();
      });
    }
  }

  getPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    String? profileid = widget.profileid != null
        ? widget.profileid
        : await prefs.getString('profileid');
    http.Response response = await http.get(Uri.parse(getposts + '/$profileid'),
        headers: {'Authorization': 'Bearer ${token}'});
    var body = jsonDecode(response.body);
    if (body['status'] == 'success') {
      return body['message'];
    }
  }

  bool arrow = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.posts == true && userType == "${1}"
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Icon(
                Icons.local_fire_department_sharp,
                color: maincolor,
              ),
              title: InkWell(
                  onTap: () {
                    setState(() {
                      myservice = !myservice;
                    });
                    specialposts = getspecialPosts();
                    allposts = getallPosts();
                  },
                  child: myservice == true
                      ? Text(
                          'Show all posts',
                          style: psubts,
                        )
                      : Text(
                          'Show posts for my service',
                          style: psubts,
                          textAlign: TextAlign.right,
                        )),
            )
          : AppBar(
              elevation: 0, backgroundColor: Colors.transparent, leading: null),
      body: SafeArea(
        child: Container(
          child: StatefulBuilder(builder: (context, setState) {
            return widget.posts == false
                ? FutureBuilder(
                    future: myfuture,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Column(
                                children: [
                                  Card(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            border_rad_size),
                                      ),
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      alignment: Alignment.center,
                                      child: InkWell(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CarouselSlider(
                                              options: CarouselOptions(
                                                aspectRatio: 1.0,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    3,
                                                animateToClosest: true,
                                                viewportFraction: 1.0,
                                                enlargeCenterPage: false,
                                                autoPlay: true,
                                              ),
                                              items: List.generate(
                                                  snapshot
                                                      .data[index]
                                                          ['postimagedata']
                                                      .length,
                                                  (j) => Container(
                                                        width: double.infinity,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 2),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        border_rad_size),
                                                            image:
                                                                DecorationImage(
                                                              image: NetworkImage(
                                                                  '$serverlink' +
                                                                      '/storage/' +
                                                                      '${snapshot.data[index]['postimagedata'][j]['imageurl']}'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      )).map((i) {
                                                return Builder(
                                                  builder:
                                                      (BuildContext context) {
                                                    return i;
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                            Container(
                                              alignment: Alignment.topLeft,
                                              padding: EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 2),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${snapshot.data[index]['postdata']['title']}',
                                                                style: psubts,
                                                              ),
                                                              Text(
                                                                '${snapshot.data[index]['postdata']['status']}',
                                                                style: greyts,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      if (widget.posts ==
                                                              false &&
                                                          widget.profileid ==
                                                              null)
                                                        ...([
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                vertical: 20,
                                                              ),
                                                              child:
                                                                  ExpandableMenu(
                                                                backgroundColor:
                                                                    maincolor1,
                                                                itemContainerColor:
                                                                    Colors
                                                                        .white,
                                                                iconColor:
                                                                    Colors
                                                                        .white,
                                                                width: 46.0,
                                                                height: 46.0,
                                                                items: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      deletePost(snapshot.data[index]
                                                                              [
                                                                              'postdata']
                                                                          [
                                                                          'id']);
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color:
                                                                          maincolor,
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pushReplacement(
                                                                              MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                          return updatePost(
                                                                            subcategorydata:
                                                                                snapshot.data[index]['subcategorydata'],
                                                                            post:
                                                                                snapshot.data[index]['postdata'],
                                                                            images:
                                                                                snapshot.data[index]['postimagedata'],
                                                                          );
                                                                        },
                                                                      ));
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .edit,
                                                                      color:
                                                                          maincolor,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ])
                                                    ],
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            '${snapshot.data[index]['postdata']['content']}',
                                                            style: bg,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${snapshot.data[index]['postdata']['price']}' !=
                                                                      "null"
                                                                  ? '${snapshot.data[index]['postdata']['price']}'
                                                                  : '',
                                                              style: greyts,
                                                            ),
                                                            Text(
                                                              '${snapshot.data[index]['subcategorydata']['name']}',
                                                              style: greyts,
                                                            ),
                                                            Text(
                                                              '${snapshot.data[index]['postdata']['date']}',
                                                              style: greyts,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        onTap: () {},
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    padding: EdgeInsets.only(top: 10, left: 10),
                                    child: InkWell(
                                      child: Row(
                                        children: [
                                          Text(
                                            'Recommended for you   ',
                                            style: psubts,
                                            textAlign: TextAlign.center,
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: maincolor,
                                          )
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) {
                                            return MyWidget(postid:  '${snapshot.data[index]['postdata']['id']}',);
                                          },
                                        ));
                                      },
                                    ),
                                  )
                                ],
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
                        return Center(
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
                                'No posts yet',
                                style: psubts,
                              )
                            ],
                          ),
                        );
                      }
                    },
                  )
                : myservice == false
                    ? FutureBuilder(
                        future: allposts,
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Card(
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) {
                                                return xProfile(
                                                    i: "0",
                                                    userid:
                                                        "${snapshot.data[index]['profiledata']['user']['id']}");
                                              },
                                            ));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10,
                                                        right: 10,
                                                        left: 10),
                                                    child: Container(
                                                      width: 70,
                                                      height: 70,
                                                      child:
                                                          '${snapshot.data[index]['profiledata']['imageurl']}' ==
                                                                  "null"
                                                              ? CircleAvatar(
                                                                  backgroundColor: Color
                                                                          .fromARGB(
                                                                              93,
                                                                              83,
                                                                              81,
                                                                              81)
                                                                      .withOpacity(
                                                                          0.4),
                                                                  backgroundImage:
                                                                      AssetImage(
                                                                    'assets/images/user.png',
                                                                  ),
                                                                )
                                                              : CircleAvatar(
                                                                  backgroundColor: Color
                                                                          .fromARGB(
                                                                              93,
                                                                              83,
                                                                              81,
                                                                              81)
                                                                      .withOpacity(
                                                                          0.4),
                                                                  backgroundImage:
                                                                      NetworkImage('$serverlink' +
                                                                          '/storage/' +
                                                                          '${snapshot.data[index]['profiledata']['imageurl']}'),
                                                                ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 20),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${snapshot.data[index]['userdata']['name']}',
                                                          style: bsmallts,
                                                        ),
                                                        '${snapshot.data[index]['profiledata']['teamsize']}' ==
                                                                "null"
                                                            ? Text(
                                                                'Buyer account',
                                                                style: greyts,
                                                              )
                                                            : Text(
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
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                border_rad_size),
                                          ),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          alignment: Alignment.center,
                                          child: InkWell(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CarouselSlider(
                                                  options: CarouselOptions(
                                                    aspectRatio: 1.0,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            3,
                                                    animateToClosest: true,
                                                    viewportFraction: 1.0,
                                                    enlargeCenterPage: false,
                                                    autoPlay: true,
                                                  ),
                                                  items: List.generate(
                                                      snapshot
                                                          .data[index]
                                                              ['postimagedata']
                                                          .length,
                                                      (j) => Container(
                                                            width:
                                                                double.infinity,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            border_rad_size),
                                                                image:
                                                                    DecorationImage(
                                                                  image: NetworkImage(
                                                                      '$serverlink' +
                                                                          '/storage/' +
                                                                          '${snapshot.data[index]['postimagedata'][j]['imageurl']}'),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          )).map((i) {
                                                    return Builder(
                                                      builder: (BuildContext
                                                          context) {
                                                        return i;
                                                      },
                                                    );
                                                  }).toList(),
                                                ),
                                                Container(
                                                  alignment: Alignment.topLeft,
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          2),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    '${snapshot.data[index]['postdata']['title']}',
                                                                    style:
                                                                        psubts,
                                                                  ),
                                                                  Text(
                                                                    '${snapshot.data[index]['postdata']['status']}',
                                                                    style:
                                                                        greyts,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          if (widget.posts ==
                                                              false)
                                                            ...([
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                    vertical:
                                                                        20,
                                                                  ),
                                                                  child:
                                                                      ExpandableMenu(
                                                                    backgroundColor:
                                                                        maincolor1,
                                                                    itemContainerColor:
                                                                        Colors
                                                                            .white,
                                                                    iconColor:
                                                                        Colors
                                                                            .white,
                                                                    width: 46.0,
                                                                    height:
                                                                        46.0,
                                                                    items: [
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          deletePost(snapshot.data[index]['postdata']
                                                                              [
                                                                              'id']);
                                                                        },
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              maincolor,
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .push(MaterialPageRoute(
                                                                            builder:
                                                                                (context) {
                                                                              return updatePost(
                                                                                post: snapshot.data[index]['postdata'],
                                                                                images: snapshot.data[index]['postimagedata'],
                                                                              );
                                                                            },
                                                                          ));
                                                                        },
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .edit,
                                                                          color:
                                                                              maincolor,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ])
                                                        ],
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                '${snapshot.data[index]['postdata']['content']}',
                                                                style: bg,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        margin: EdgeInsets.only(
                                                            left: 0, top: 8),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${snapshot.data[index]['postdata']['price']}' !=
                                                                      "null"
                                                                  ? '${snapshot.data[index]['postdata']['price']}'
                                                                  : '',
                                                              style: greyts,
                                                            ),
                                                            Text(
                                                              '${snapshot.data[index]['subcategorydata']['name']}',
                                                              style: greyts,
                                                            ),
                                                            Text(
                                                              '${snapshot.data[index]['postdata']['date']}',
                                                              style: greyts,
                                                            ),
                                                            /* if ((widget
                                                                    .posts) &&
                                                                (snapshot.data[index]
                                                                            [
                                                                            'postdata']
                                                                        [
                                                                        'status'] ==
                                                                    "available") &&
                                                                (snapshot.data[index]['subcategorydata']
                                                                            [
                                                                            'name'] ==
                                                                        '${usersubcategories[0]}' ||
                                                                    snapshot.data[index]['subcategorydata']
                                                                            [
                                                                            'name'] ==
                                                                        '${usersubcategories[1]}'))
                                                              ...([
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                  alignment:
                                                                      Alignment
                                                                          .bottomRight,
                                                                  child:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    width: 100,
                                                                    height: 40,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: maincolor
                                                                            .withOpacity(0.4),
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              border_rad_size),
                                                                      color:
                                                                          maincolor,
                                                                    ),
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        createRoom(
                                                                            snapshot.data[index]['userdata']['id'],
                                                                            snapshot.data[index]['postdata']['id'],
                                                                            snapshot.data[index]['postdata']['lat'],
                                                                            snapshot.data[index]['postdata']['long']
                                                                            /* snapshot.data[index]['subcategorydata']['id']*/
                                                                            );
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        'Offer',
                                                                        style:
                                                                            wsmallts,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ])*/
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            onTap: () {},
                                          ),
                                        ),
                                      ],
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
                            return Center(
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
                                    'No posts yet',
                                    style: psubts,
                                  )
                                ],
                              ),
                            );
                          }
                        },
                      )
                    : FutureBuilder(
                        future: specialposts,
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData && snapshot.data.length > 0) {
                            return ListView.builder(
                              reverse: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Card(
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) {
                                                return xProfile(
                                                    i: "0",
                                                    userid:
                                                        "${snapshot.data[index]['profiledata']['user']['id']}");
                                              },
                                            ));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10,
                                                        right: 10,
                                                        left: 10),
                                                    child: Container(
                                                      width: 70,
                                                      height: 70,
                                                      child:
                                                          '${snapshot.data[index]['profiledata']['imageurl']}' ==
                                                                  "null"
                                                              ? CircleAvatar(
                                                                  backgroundColor: Color
                                                                          .fromARGB(
                                                                              93,
                                                                              83,
                                                                              81,
                                                                              81)
                                                                      .withOpacity(
                                                                          0.4),
                                                                  backgroundImage:
                                                                      AssetImage(
                                                                    'assets/images/user.png',
                                                                  ),
                                                                )
                                                              : CircleAvatar(
                                                                  backgroundColor: Color
                                                                          .fromARGB(
                                                                              93,
                                                                              83,
                                                                              81,
                                                                              81)
                                                                      .withOpacity(
                                                                          0.4),
                                                                  backgroundImage:
                                                                      NetworkImage('$serverlink' +
                                                                          '/storage/' +
                                                                          '${snapshot.data[index]['profiledata']['imageurl']}'),
                                                                ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 20),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${snapshot.data[index]['userdata']['name']}',
                                                          style: bsmallts,
                                                        ),
                                                        '${snapshot.data[index]['profiledata']['teamsize']}' ==
                                                                "null"
                                                            ? Text(
                                                                'Buyer account',
                                                                style: greyts,
                                                              )
                                                            : Text(
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
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                border_rad_size),
                                          ),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          alignment: Alignment.center,
                                          child: InkWell(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CarouselSlider(
                                                  options: CarouselOptions(
                                                    aspectRatio: 1.0,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            3,
                                                    animateToClosest: true,
                                                    viewportFraction: 1.0,
                                                    enlargeCenterPage: false,
                                                    autoPlay: true,
                                                  ),
                                                  items: List.generate(
                                                      snapshot
                                                          .data[index]
                                                              ['postimagedata']
                                                          .length,
                                                      (j) => Container(
                                                            width:
                                                                double.infinity,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            border_rad_size),
                                                                image:
                                                                    DecorationImage(
                                                                  image: NetworkImage(
                                                                      '$serverlink' +
                                                                          '/storage/' +
                                                                          '${snapshot.data[index]['postimagedata'][j]['imageurl']}'),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          )).map((i) {
                                                    return Builder(
                                                      builder: (BuildContext
                                                          context) {
                                                        return i;
                                                      },
                                                    );
                                                  }).toList(),
                                                ),
                                                Container(
                                                  alignment: Alignment.topLeft,
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          2),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    '${snapshot.data[index]['postdata']['title']}',
                                                                    style:
                                                                        psubts,
                                                                  ),
                                                                  Text(
                                                                    '${snapshot.data[index]['postdata']['status']}',
                                                                    style:
                                                                        greyts,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          if (widget.posts ==
                                                              false)
                                                            ...([
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                    vertical:
                                                                        20,
                                                                  ),
                                                                  child:
                                                                      ExpandableMenu(
                                                                    backgroundColor:
                                                                        maincolor1,
                                                                    itemContainerColor:
                                                                        Colors
                                                                            .white,
                                                                    iconColor:
                                                                        Colors
                                                                            .white,
                                                                    width: 46.0,
                                                                    height:
                                                                        46.0,
                                                                    items: [
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          deletePost(snapshot.data[index]['postdata']
                                                                              [
                                                                              'id']);
                                                                        },
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              maincolor,
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .push(MaterialPageRoute(
                                                                            builder:
                                                                                (context) {
                                                                              return updatePost(
                                                                                post: snapshot.data[index]['postdata'],
                                                                                images: snapshot.data[index]['postimagedata'],
                                                                              );
                                                                            },
                                                                          ));
                                                                        },
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .edit,
                                                                          color:
                                                                              maincolor,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ])
                                                        ],
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                '${snapshot.data[index]['postdata']['content']}',
                                                                style: bg,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        margin: EdgeInsets.only(
                                                            left: 0, top: 8),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${snapshot.data[index]['postdata']['price']}' !=
                                                                      "null"
                                                                  ? '${snapshot.data[index]['postdata']['price']}'
                                                                  : '',
                                                              style: greyts,
                                                            ),
                                                            Text(
                                                              '${snapshot.data[index]['subcategorydata']['name']}',
                                                              style: greyts,
                                                            ),
                                                            Text(
                                                              '${snapshot.data[index]['postdata']['date']}',
                                                              style: greyts,
                                                            ),
                                                            if ((widget
                                                                    .posts) &&
                                                                (snapshot.data[index]
                                                                            [
                                                                            'postdata']
                                                                        [
                                                                        'status'] ==
                                                                    "available") &&
                                                                (snapshot.data[index]['subcategorydata']
                                                                            [
                                                                            'name'] ==
                                                                        '${usersubcategories[0]}' ||
                                                                    snapshot.data[index]['subcategorydata']
                                                                            [
                                                                            'name'] ==
                                                                        '${usersubcategories[1]}'))
                                                              ...([
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                  alignment:
                                                                      Alignment
                                                                          .bottomRight,
                                                                  child:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    width: 100,
                                                                    height: 40,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: maincolor
                                                                            .withOpacity(0.4),
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              border_rad_size),
                                                                      color:
                                                                          maincolor,
                                                                    ),
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        createRoom(
                                                                          snapshot.data[index]['userdata']
                                                                              [
                                                                              'id'],
                                                                          snapshot.data[index]['postdata']
                                                                              [
                                                                              'id'],
                                                                          snapshot.data[index]['postdata']
                                                                              [
                                                                              'lat'],
                                                                          snapshot.data[index]['postdata']
                                                                              [
                                                                              'long'], /*  snapshot.data[index]['subcategorydata']['id']*/
                                                                        );
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        'Offer',
                                                                        style:
                                                                            wsmallts,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ])
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            onTap: () {},
                                          ),
                                        ),
                                      ],
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
                            return Center(
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
                                    'No posts yet',
                                    style: psubts,
                                  )
                                ],
                              ),
                            );
                          }
                        },
                      );
          }),
        ),
      ),
    );
  }
}
