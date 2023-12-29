import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:servigo/admin/add.dart';
import 'package:servigo/admin/blockuser.dart';
import 'package:servigo/admin/categories.dart';
import 'package:servigo/admin/dash.dart';
import 'package:servigo/admin/subcategories.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/main.dart';
import 'package:servigo/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();

PageController pageController = PageController();
SideMenuController sideMenu = SideMenuController();

class Admin extends StatefulWidget {
 

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    String? userid = prefs.getString('userid');

    String? apptoken = await FirebaseMessaging.instance.getToken();
    http.Response response = await http.post(
      Uri.parse('${deletetoken}'),
      body: {'token': '${apptoken}', 'userid': '${userid}'},
      headers: {'Authorization': 'Bearer ${token}'},
    );
    print(jsonDecode(response.body)['status']);
    if (jsonDecode(response.body)['status'] == 'success') {
    prefs.clear();
    Navigator.of(context).pushNamedAndRemoveUntil('signIn', (route) => false);
    }
  }

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
                onPressed: () {
                  scaffoldKey.currentState!.openDrawer();
                },
                icon: Icon(
                  Icons.abc,
                  color: Colors.white,
                ))),
        key: scaffoldKey,
        drawer: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 30),
            child: Drawer(
              width: 50,
              child: SideMenu(
                alwaysShowFooter: true,
                title: Text('                                '),
                controller: sideMenu,
                style: SideMenuStyle(
                    itemHeight: 70,
                    selectedColor: maincolor1,
                    displayMode: SideMenuDisplayMode.auto,
                    openSideMenuWidth: 50,
                    selectedIconColor: Colors.white),
                items: [
                  SideMenuItem(
                    priority: 0,
                    onTap: (index, _) {
                      sideMenu.changePage(0);
                      pageController.jumpToPage(0);
                    },
                    icon: Icon(Icons.home),
                  ),
                  SideMenuItem(
                    priority: 1,
                    onTap: (index, _) {
                      sideMenu.changePage(1);
                      pageController.jumpToPage(1);
                    },
                    icon: Icon(Icons.create),
                  ),
                  SideMenuItem(
                    priority: 2,
                    onTap: (index, _) {
                      sideMenu.changePage(2);
                      pageController.jumpToPage(2);
                    },
                    icon: Icon(Icons.create_outlined),
                  ),
                  SideMenuItem(
                    priority: 3,
                    onTap: (index, _) {
                      sideMenu.changePage(3);
                      pageController.jumpToPage(3);
                    },
                    icon: Icon(Icons.person_add_alt_1),
                  ),
                  SideMenuItem(
                    priority: 4,
                    onTap: (index, _) {
                      sideMenu.changePage(4);
                      pageController.jumpToPage(4);
                    },
                    icon: Icon(Icons.person_off_rounded),
                  ),
                  // SideMenuItem(
                  //   priority: 5,
                  //   onTap: (index, _) {
                  //     sideMenu.changePage(5);
                  //     pageController.jumpToPage(5);
                  //   },
                  //   icon: Icon(Icons.warning_rounded),
                  // ),
                  SideMenuItem(
                    priority: 5,
                    title: 'Exit',
                    onTap: (index, _) {
                      logOut();
                    },
                    icon: Icon(Icons.exit_to_app),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
              child: PageView(
                // pageSnapping: false,_
                physics: NeverScrollableScrollPhysics(),
                controller: pageController,
                children: [
                  // Admin(title: ';k'),
                  Dash(),
                  Categories(),
                  subcategories(),
                  add(),
                  blockUser(),
                ],
              ),
            )
          ]),
        ));
  }
}
