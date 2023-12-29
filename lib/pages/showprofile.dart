import 'dart:convert';

import 'dart:io';
import 'dart:async';
import 'package:blurry/blurry.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:servigo/components/pricetagdesign.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/pricetag.dart';
import 'package:servigo/pages/showposts.dart';
import 'package:servigo/pages/showworkstation.dart';
import 'package:servigo/pages/workstation.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<FormFieldState> formkey = new GlobalKey();

class xProfile extends StatefulWidget {
  String i = "0";
  String? userid;
  xProfile({required this.i, required this.userid});

  @override
  State<xProfile> createState() => _ProfileState();
}

class _ProfileState extends State<xProfile> {
  int index = 0;
  File? image;
  String? biovalue;
  var pp;
  bool bio = false;
  String? distance;
  var profileimage = null;
  var rates;
  String? pimage;
  var profile;
  String? userType;
  String? sellerType;
  List? sub = [];
  String? profileid;
  List<Widget> subs = [];
  List<Widget> pricing = [];
  late Future myFuture;

  getWorkstations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    http.Response response = await http.get(
        Uri.parse(getworkstations + '/${profileid}'),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body = jsonDecode(response.body);
    if (body['status'] == 'success') {
      return body['message'];
    }
  }

  getProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    http.Response response = await http.get(
        Uri.parse(getprofileimage + '/${profileid}'),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    setState(() {
      pimage = (jsonDecode(response.body));
    });
  }

  getProfile() async {
    var body;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    print(widget.userid);
    http.Response response = await http.get(
        Uri.parse('${getprofile}' + '/${widget.userid}'),
        headers: {'Authorization': 'Bearer ${token}'});
    body = jsonDecode(response.body);
    if (!mounted) return;
    if (body['status'] == 'success') {
      setState(() {
        profile = body['message'];
        distance = '${profile['profiledata']['distance']} ';
        profileid = '${profile['profiledata']['id']} ';
        userType = '${profile['roleid']}';
        print(userType);
        sub = profile['subcategorydata'];
        biovalue = profile['profiledata']['bio'];
      });
      getProfileImage();
      myFuture = getWorkstations();
      for (int i = 0; i < sub!.length; i++) {
        setState(() {
          subs.add(Text(
            '${sub![i]['name']}',
            style: greyts,
          ));
        });
      }
      getRates();
      if (userType == "1") {
        getPricing();
      }
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

  getRates() async {
    print(profileid);
    print('--------------------');
    var body;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    http.Response response = await http.get(
      Uri.parse(getrates + '/${profileid}'),
      headers: {'Authorization': 'Bearer ${token}'},
    );
    body = (jsonDecode(response.body));
    if (!mounted) return;
    setState(() {
      rates = body;
    });
  }

  getPricing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    http.Response response = await http.get(
      Uri.parse('${getpricing}' + '/' + '${profileid}'),
      headers: {'Authorization': 'Bearer ${token}'},
    );
    var body = jsonDecode(response.body);
    if (!mounted) return;
    if (body['status'] == 'success') {
      setState(() {
        pp = body['message'];
      });
      for (int i = 0; i < body['message'].length; i++) {
        pricing.add(
          pricetagDesign(
            context,
            body['message'][i]['pricingdata']['price'] == null
                ? Text(
                    'SERVIGO default prictag price',
                    style: psmallts,
                  )
                : Text('${body['message'][i]['pricingdata']['price']}',
                    style: psmallts),
            Text(
              '${body['message'][i]['pricingsubcategory']['name']}',
              style: psubts,
            ),
            body['message'][i]['pricingdata']['content'] == null
                ? Text('SERVIGO default prictag content', style: bg)
                : Text('${body['message'][i]['pricingdata']['content']}',
                    style: bg),
          ),
        );
      }
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

  final scaffoldKey = GlobalKey<ScaffoldState>();
  void initState() {
    print('000000000000000000000000000000000000000000000000000000000000000000');
    print(widget.userid);
    getProfile();
    myFuture = getWorkstations();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(top: 50),
          padding: EdgeInsets.all(20),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          width: 100,
                          height: 100,
                          child: pimage == null
                              ? CircleAvatar(
                                  backgroundColor:
                                      Color.fromARGB(93, 83, 81, 81)
                                          .withOpacity(0.4),
                                  backgroundImage:
                                      AssetImage('assets/images/user.png'),
                                )
                              : CircleAvatar(
                                  backgroundColor:
                                      Color.fromARGB(93, 83, 81, 81)
                                          .withOpacity(0.4),
                                  backgroundImage: NetworkImage("$pimage"),
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            profile == null
                                ? CircularProgressIndicator(
                                    color: maincolor,
                                  )
                                : Text(
                                    profile != null ? '${profile['name']}' : '',
                                    style: btitle,
                                  ),
                            if (userType == "1")
                              ...([
                                Text(
                                  profile != null
                                      ? '${profile['profiledata']['teamsize']}'
                                      : '',
                                  style: greyts,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: subs,
                                ),
                              ])
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 30, left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bio',
                        style: bsubts,
                      ),
                      Text(
                        biovalue != null
                            ? '${biovalue}'
                            : 'Tell people about yourself',
                        style: greyts,
                      ),
                    ],
                  ),
                ),

                // userType == "1" && distance != null && sellerType == "hum"
                //     ? Container(
                //         margin: EdgeInsets.only(top: 30, left: 10),
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               'Distance',
                //               style: bsubts,
                //             ),
                //             distance != null
                //                 ? Text(
                //                     '${profile['profiledata']['distance']} km',
                //                     style: greyts,
                //                   )
                //                 : Text(
                //                     '',
                //                     style: greyts,
                //                   ),
                //           ],
                //         ),
                //       )
                //     : Text(''),
                Container(
                  margin: EdgeInsets.only(top: 40),
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (userType == "1")
                            ...([
                              Card(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      widget.i = "0";
                                      index = 0;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3, vertical: 5),
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    height:
                                        MediaQuery.of(context).size.width / 8,
                                    child: Text(
                                      'Workstation',
                                      style: bsmallts,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                  child: InkWell(
                                onTap: () {
                                  setState(() {
                                    widget.i = "1";

                                    index = 1;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 5),
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 8,
                                  child: Text(
                                    'Pricing',
                                    style: bsmallts,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )),
                            ]),
                          Card(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) {
                                      return showPosts(
                                          posts: false, profileid: profileid);
                                    },
                                  ));
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 5),
                                width: MediaQuery.of(context).size.width / 4,
                                height: MediaQuery.of(context).size.width / 8,
                                child: Text(
                                  'Posts',
                                  style: bsmallts,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (userType == "1")
                  ...([
                    widget.i == "0"
                        ? Container(
                            margin: EdgeInsets.only(top: 40, left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'workstation',
                                  style: bsubts,
                                ),
                                Text(
                                  'show people your work',
                                  style: greyts,
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  height:
                                      MediaQuery.of(context).size.height / 6,
                                  child: FutureBuilder(
                                      future: myFuture,
                                      builder:
                                          (context, AsyncSnapshot snapshot) {
                                        if (snapshot.hasData) {
                                          return ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, index) {
                                              return FocusedMenuHolder(
                                                openWithTap: true,
                                                onPressed: () {},
                                                menuItems: <FocusedMenuItem>[
                                                  FocusedMenuItem(
                                                    backgroundColor: maincolor,
                                                    title: Text(
                                                      'show',
                                                      style: wsmallts,
                                                    ),
                                                    trailingIcon: Icon(
                                                      Icons.slideshow_rounded,
                                                      color: Colors.white,
                                                      size: 22,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .push(
                                                              MaterialPageRoute(
                                                        builder: (context) {
                                                          return showWorkstation(
                                                            workstation:
                                                                snapshot.data[
                                                                    index],
                                                          );
                                                        },
                                                      ));
                                                    },
                                                  ),
                                                ],
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            '${serverlink}' +
                                                                '/storage/' +
                                                                '${snapshot.data[index]['image']}'),
                                                        fit: BoxFit.cover),
                                                    color: Color.fromARGB(
                                                            93, 83, 81, 81)
                                                        .withOpacity(0.4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            border_rad_size),
                                                  ),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      6,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                )
                                                //  Container(
                                                //     decoration:
                                                //         BoxDecoration(
                                                //       image: DecorationImage(
                                                //           image: AssetImage("assets/images/google.png"
                                                //               ),
                                                //           fit: BoxFit
                                                //               .cover),
                                                //       color: Color
                                                //               .fromARGB(
                                                //                   93,
                                                //                   83,
                                                //                   81,
                                                //                   81)
                                                //           .withOpacity(
                                                //               0.4),
                                                //       borderRadius:
                                                //           BorderRadius
                                                //               .circular(
                                                //                   border_rad_size),
                                                //     ),
                                                //     width: MediaQuery.of(
                                                //                 context)
                                                //             .size
                                                //             .height /
                                                //         6,
                                                //     margin: EdgeInsets
                                                //         .symmetric(
                                                //             horizontal:
                                                //                 10),
                                                //   )
                                                ,
                                              );
                                            },
                                          );
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child: CircularProgressIndicator(
                                            color: maincolor,
                                          ));
                                        } else {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/images/planet.png',
                                                  height: 100,
                                                  width: 100,
                                                ),
                                                Text(
                                                  'No workstations yet',
                                                  style: psubts,
                                                )
                                              ],
                                            ),
                                          );
                                        }
                                      }),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(top: 40, left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'pricing your service',
                                  style: bsubts,
                                ),
                                Text(
                                  'tell people about your services and their prices',
                                  style: bg,
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child:
                                        Divider(color: Colors.grey, height: 1)),
                                pricing == null
                                    ? CircularProgressIndicator(
                                        color: maincolor,
                                      )
                                    : Container(
                                        margin: EdgeInsets.only(top: 9),
                                        alignment: Alignment.topLeft,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 20,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: sub!.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20),
                                              child: InkWell(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  child: subs[index]),
                                            );
                                          },
                                        ),
                                      ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: sub!.length,
                                    itemBuilder: (context, index) {
                                      return FocusedMenuHolder(
                                        bottomOffsetHeight: 200,
                                        openWithTap: true,
                                        onPressed: () {},
                                        menuItems: <FocusedMenuItem>[
                                          FocusedMenuItem(
                                            backgroundColor: maincolor,
                                            title: Text(
                                              'update',
                                              style: wsmallts,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return priceTag(
                                                      pricingdata: pp[index],
                                                    );
                                                  },
                                                ),
                                              );
                                              ;
                                            },
                                            trailingIcon: Icon(
                                              Icons.update,
                                              size: 22,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                        child: Container(
                                          margin: EdgeInsets.only(top: 20),
                                          alignment: Alignment.topLeft,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.4,
                                          child: pricing[index],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          )
                  ])
                // Container(
                //   margin: EdgeInsets.only(top: 9),
                //   alignment: Alignment.topLeft,
                //   width: MediaQuery.of(context).size.width,
                //   height: MediaQuery.of(context).size.height,
                //   child: ListView.builder(
                //     scrollDirection: Axis.horizontal,
                //     itemCount: sub!.length,
                //     itemBuilder: (context, index) {
                //       return Padding(
                //           padding: const EdgeInsets.only(right: 20),
                //           child: Container(
                //               margin: EdgeInsets.only(top: 20),
                //               width: double.infinity,
                //               child: FocusedMenuHolder(
                //                 child: Text('kkkkkkkkkkkk'),
                // child: Container(
                //   alignment: Alignment.topLeft,
                //   width: MediaQuery.of(context)
                //           .size
                //           .width /
                //       1.4,
                //   child: pricetagDesign(
                //     context,
                //     Text(
                //       'starts at 6700 S.P',
                //       style: greyts,
                //     ),
                //     Text(
                //       'Flutter',
                //       style: bsmallts,
                //     ),
                //     Text(
                //       '''I am a talented developer based in Syria, with a passion for creating innovative solutions using Flutter, PHP, and WordPress. Outside of work, I am an extroverted individual who loves to connect with people and enjoys the simple pleasures of life. I believe that my positive outlook on life and my attention to detail are what make me successful in both my personal and professional endeavors.''',
                //       style: bg,
                //     ),
                //   ),
                // ),
                //                 onPressed: () {},
                //                 menuItems: <FocusedMenuItem>[
                //                   FocusedMenuItem(
                //                     title: Text(
                //                       'create',
                //                       style: bsmallts,
                //                     ),
                //                     onPressed: () {
                //                       Navigator.of(context)
                //                           .push(MaterialPageRoute(
                //                         builder: (context) {
                //                           return priceTag(
                //                               subcategories: sub!);
                //                         },
                //                       ));
                //                     },
                //                     trailingIcon: Icon(
                //                       Icons.create,
                //                       size: 22,
                //                     ),
                //                   ),
                //                   FocusedMenuItem(
                //                     title: Text(
                //                       'update',
                //                       style: bsmallts,
                //                     ),
                //                     onPressed: () {
                //                       Navigator.of(context)
                //                           .pushNamed('priceTag');
                //                     },
                //                     trailingIcon: Icon(
                //                       Icons.update,
                //                       size: 22,
                //                     ),
                //                   ),
                //                   FocusedMenuItem(
                //                     backgroundColor: errorcolor,
                //                     title: Text(
                //                       'delete',
                //                       style: wsmallts,
                //                     ),
                //                     trailingIcon: Icon(
                //                       Icons.delete,
                //                       size: 22,
                //                       color: Colors.white,
                //                     ),
                //                     onPressed: () {},
                //                   )
                //                 ],
                //               )));
                //     },
                //   ),
                // ),
                // ListView.builder(
                //   itemCount: sub!.length,
                //   itemBuilder: (context, index) {
                //     return Container(
                //       margin: EdgeInsets.only(top: 20),
                //       width: double.infinity,
                //       child: FocusedMenuHolder(
                //         onPressed: () {},
                //         menuItems: <FocusedMenuItem>[
                //           FocusedMenuItem(
                //             title: Text(
                //               'create',
                //               style: bsmallts,
                //             ),
                //             onPressed: () {
                //               Navigator.of(context)
                //                   .push(MaterialPageRoute(
                //                 builder: (context) {
                //                   return priceTag(
                //                       subcategories: sub!);
                //                 },
                //               ));
                //             },
                //             trailingIcon: Icon(
                //               Icons.create,
                //               size: 22,
                //             ),
                //           ),
                //           FocusedMenuItem(
                //             title: Text(
                //               'update',
                //               style: bsmallts,
                //             ),
                //             onPressed: () {
                //               Navigator.of(context)
                //                   .pushNamed('priceTag');
                //             },
                //             trailingIcon: Icon(
                //               Icons.update,
                //               size: 22,
                //             ),
                //           ),
                //           FocusedMenuItem(
                //             backgroundColor: errorcolor,
                //             title: Text(
                //               'delete',
                //               style: wsmallts,
                //             ),
                //             trailingIcon: Icon(
                //               Icons.delete,
                //               size: 22,
                //               color: Colors.white,
                //             ),
                //             onPressed: () {},
                //           )
                //         ],
                //         child: Container(
                //           alignment: Alignment.topLeft,
                //           width:
                //               MediaQuery.of(context).size.width / 1.4,
                //           child: pricetagDesign(
                //             context,
                //             Text(
                //               'starts at 6700 S.P',
                //               style: greyts,
                //             ),
                //             Text(
                //               'Flutter',
                //               style: bsmallts,
                //             ),
                //             Text(
                //               '''I am a talented developer based in Syria, with a passion for creating innovative solutions using Flutter, PHP, and WordPress. Outside of work, I am an extroverted individual who loves to connect with people and enjoys the simple pleasures of life. I believe that my positive outlook on life and my attention to detail are what make me successful in both my personal and professional endeavors.''',
                //               style: bg,
                //             ),
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // ),
                // : Container(
                //     margin: EdgeInsets.only(top: 20),
                //     width: double.infinity,
                //     child: FocusedMenuHolder(
                //       onPressed: () {},
                //       menuItems: <FocusedMenuItem>[
                //         FocusedMenuItem(
                //           title: Text(
                //             'create',
                //             style: bsmallts,
                //           ),
                //           onPressed: () {
                //             Navigator.of(context).push(MaterialPageRoute(
                //               builder: (context) {
                //                 return priceTag(subcategories: sub!);
                //               },
                //             ));
                //           },
                //           trailingIcon: Icon(
                //             Icons.create,
                //             size: 22,
                //           ),
                //         ),
                //         FocusedMenuItem(
                //           title: Text(
                //             'upttdate',
                //             style: bsmallts,
                //           ),
                //           onPressed: () {
                //             Navigator.of(context).push(MaterialPageRoute(
                //               builder: (context) {
                //                 return priceTag(
                //                   subcategories: sub!,
                //                   pricingid: 13,
                //                 );
                //               },
                //             ));
                //           },
                //           trailingIcon: Icon(
                //             Icons.update,
                //             size: 22,
                //           ),
                //         ),
                //         FocusedMenuItem(
                //           backgroundColor: errorcolor,
                //           title: Text(
                //             'delete',
                //             style: wsmallts,
                //           ),
                //           trailingIcon: Icon(
                //             Icons.delete,
                //             size: 22,
                //             color: Colors.white,
                //           ),
                //           onPressed: () {},
                //         )
                //       ],
                //       child: Container(
                //         alignment: Alignment.topLeft,
                //         width: MediaQuery.of(context).size.width / 1.4,
                //         child: pricetagDesign(
                //           context,
                //           Text(
                //             'starts at 6700 S.P',
                //             style: greyts,
                //           ),
                //           Text(
                //             'Flutter',
                //             style: bsmallts,
                //           ),
                //           Text(
                //             '''I am a talented developer based in Syria, with a passion for creating innovative solutions using Flutter, PHP, and WordPress. Outside of work, I am an extroverted individual who loves to connect with people and enjoys the simple pleasures of life. I believe that my positive outlook on life and my attention to detail are what make me successful in both my personal and professional endeavors.''',
                //             style: bg,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
                        
                    
                    
              // index == 0
              //     ? Container(
              //         margin: EdgeInsets.only(top: 30, left: 10),
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'My rates',
              //               style: bsubts,
              //             ),
              //             rates != null
              //                 ? StreamBuilder(
              //                     stream: rates.snapshots(),
              //                     builder: (context, AsyncSnapshot snapshot) {
              //                       if (snapshot.connectionState ==
              //                           ConnectionState.waiting) {
              //                         return CircularProgressIndicator(
              //                           color: maincolor,
              //                         );
              //                       } else {
              //                         return Text('');
              //                       }
              //                     },
              //                   )
              //                 : Text('')
              //           ],
              //         ),
              //       )
              //     : Text('')
            // ],
          // ),
        // ),
      

