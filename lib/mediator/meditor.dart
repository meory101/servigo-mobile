import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:servigo/db/links.dart';
import 'package:servigo/mediator/blockuser.dart';
import 'package:servigo/mediator/dash.dart';
import 'package:servigo/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();

PageController pageController = PageController();
SideMenuController sideMenu = SideMenuController();

class Mediator extends StatefulWidget {
  const Mediator({Key? key}) : super(key: key);

  @override
  State<Mediator> createState() => _MediatorState();
}

class _MediatorState extends State<Mediator> {
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
                    icon: Icon(Icons.person_off_rounded),
                  ),
                 
                  SideMenuItem(
                    priority: 2,
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
                Mdash(),                  
                  MblockUser(),
                ],
              ),
            )
          ]),
        ));
  }
}
