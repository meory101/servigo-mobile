import 'dart:convert';
// import 'dart:math';

// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:expandable_menu/expandable_menu.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_custom_selector/flutter_custom_selector.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:servigo/categories/categories.dart';
import 'package:servigo/db/links.dart';
// import 'package:servigo/main.dart';
import 'package:http/http.dart' as http;
import 'package:servigo/main.dart';
import 'package:servigo/pages/info.dart';
import 'package:servigo/pages/profile.dart';
import 'package:servigo/pages/search.dart';
import 'package:servigo/pages/showposts.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController con = new TextEditingController();
  String? pimage;
  bool servicetype = true;
  var servicetypes;
  List<String> stnames = [];
  getProfileImage() async {
    // fAFmO3cMRSmdJgsgAeueYz:APA91bHotpvGffmlsaNOs6v6c75wDAgIjv8k-oWkTY7zXsw4zysE4SYm79M14hRU9dgOPqDma0N6CgEHAgTZ-ltg6hFfChb7u0gi-9svRALsCwm8w3F0TADwThRIPTydgj9KmfZit0eN
    print('${await FirebaseMessaging.instance.getToken()}');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    String? profileid = await prefs.getString('profileid');
    http.Response response = await http.get(
        Uri.parse(getprofileimage + '/${profileid}'),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    setState(() {
      pimage = (jsonDecode(response.body));
    });
  }

  servicetypesnames() async {
    servicetypes = await getServiceTypes();
    for (int i = 0; i < servicetypes.length; i++) {
      stnames.add(servicetypes[i]['name']);
      print(stnames);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getProfileImage();
    servicetypesnames();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  int selected = 4;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: selected,
        showElevation: true,
        onItemSelected: (index) => setState(() {
          // selected = index;
        }),
        items: [
          FlashyTabBarItem(
            icon: IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return Profile(
                      i: "0",
                    );
                  },
                ));
              },
              icon: Icon(
                Icons.person,
                color: maincolor1,
                size: 25,
              ),
            ),
            title: Text(
              'Profile',
              style: psmallts,
            ),
          ),
          FlashyTabBarItem(
            icon: Image.asset(
              "assets/images/home.png",
              width: 20,
              height: 30,
            ),
            title: Text(
              'Home',
              style: psmallts,
            ),
          ),
          FlashyTabBarItem(
            icon: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('dashBoard');
              },
              icon: Icon(
                Icons.local_fire_department_sharp,
                size: 25,
                color: maincolor1,
              ),
            ),
            title: Text(
              'Board',
              style: psmallts,
            ),
          ),
        ],
      ),
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 4.5,
        elevation: 0,
        backgroundColor: maincolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(border_rad_size),
            bottomLeft: Radius.circular(border_rad_size),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return Profile(i: "0");
                              },
                            ));
                          },
                          child: Container(
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
                        InkWell(
                          onTap: () {
                            // Navigator.of(context).pushNamed('dashBoard');
                          },
                          child: Text(
                            '  SERVIGO',
                            style: wsubts,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return showPosts(posts: true);
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Latest',
                              style: wsmallts,
                            ),
                            Text(
                              'posts',
                              style: wsmallts,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.transparent.withOpacity(0.2),
                    ),
                    child: SearchBarAnimation(
                      onEditingComplete: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return Search(
                              searchstring: con.text,
                            );
                          },
                        ));
                      },
                      cursorColour: maincolor,
                      hintTextColour: maincolor,
                      hintText: 'search users',
                      enteredTextStyle: psmallts,
                      buttonWidget: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 20,
                      ),
                      textEditingController: con,
                      buttonColour: maincolor,
                      isOriginalAnimation: true,
                      enableKeyboardFocus: true,
                      trailingWidget: const Icon(
                        Icons.search,
                        size: 20,
                        color: Color.fromARGB(255, 85, 30, 152),
                      ),
                      secondaryButtonWidget: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('chatHome');
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      child: Image.asset(
                        'assets/images/message.png',
                        width: 20,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10),
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  alignment: Alignment.topLeft,
                  child: Text(
                    stnames.length > 0
                        ? servicetype
                            ? "${stnames[0]}"
                            : "${stnames[1]}"
                        : 'Waiting',
                    style: psubts,
                    textAlign: TextAlign.left,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      servicetype = !servicetype;
                    });
                  },
                  icon: Icon(
                    Icons.swap_horiz,
                    color: maincolor,
                  ),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder(
                future: servicetype == true ? getTechnicals() : getHumans(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return GridView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.8),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return Info(
                                  maincategory: snapshot.data[index]
                                      ['maincategorydata'],
                                );
                              },
                            ));
                          },
                          child: Card(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(border_rad_size),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        image: DecorationImage(
                                            image: NetworkImage('$serverlink' +
                                                '/storage/' +
                                                '${snapshot.data[index]['maincategorydata']['imageurl']}'),
                                            fit: BoxFit.cover),
                                        color: Colors.transparent,
                                      ),
                                      margin: EdgeInsets.all(10),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        '${snapshot.data[index]['maincategorydata']['name']}',
                                        style: psubts,
                                        textAlign: TextAlign.center,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height / 2),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: maincolor,
                        ),
                      ),
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
                              'No main categories yet',
                              style: psubts,
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
