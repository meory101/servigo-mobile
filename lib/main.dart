import 'dart:convert';

import 'package:blurry/blurry.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:servigo/admin/Admin.dart';
import 'package:servigo/admin/add.dart';
import 'package:servigo/admin/dash.dart';
import 'package:servigo/auth/signin.dart';
import 'package:servigo/auth/signup.dart';
import 'package:servigo/chat_pages/chat_home.dart';
import 'package:servigo/chat_pages/room.dart';
import 'package:servigo/mediator/dash.dart';
import 'package:servigo/mediator/meditor.dart';
import 'package:servigo/pages/dashboard.dart';
import 'package:servigo/pages/document.dart';
import 'package:servigo/pages/documentform.dart';
import 'package:servigo/pages/home.dart';
import 'package:servigo/pages/info.dart';
import 'package:servigo/pages/map.dart';
import 'package:servigo/pages/orderinfo.dart';
import 'package:servigo/pages/post.dart';
import 'package:servigo/pages/pricetag.dart';
import 'package:servigo/pages/profile.dart';
import 'package:servigo/pages/search.dart';
import 'package:servigo/pages/showworkstation.dart';
import 'package:servigo/pages/test.dart';
import 'package:servigo/pages/test1.dart';
import 'package:servigo/pages/useroption.dart';
import 'package:servigo/pages/workstation.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");

// var notification;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(serviGo());
}

class serviGo extends StatefulWidget {
  const serviGo({Key? key}) : super(key: key);

  @override
  State<serviGo> createState() => _serviGoState();
}

class _serviGoState extends State<serviGo> {
  @override
  void initState() {
    inappNotification();
    checklogin();
    gg();
  }

  void sendNotification({String? title, String? body, event}) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    ////Set the settings for various platform
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // const IOSInitializationSettings initializationSettingsIOS =
    //     IOSInitializationSettings(
    //   requestAlertPermission: true,
    //   requestBadgePermission: true,
    //   requestSoundPermission: true,
    // );
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'hello',
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,

            // iOS: initializationSettingsIOS,
            linux: initializationSettingsLinux);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? roleid = await prefs.getString('userType');
      print(roleid);

      if (event.data.entries.isEmpty) {
        navigatorKey
          ..currentState?.push(MaterialPageRoute(
            builder: (context) {
              return dashBoard();
            },
          ));
      } else if (event.data.entries.elementAt(0).key == 'profile') {
        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) {
            return Room(
              userprofile:
                  jsonDecode('${event.data.entries.elementAt(0).value}'),
              roomid: '${event.data.entries.elementAt(1).value}',
            );
          },
        ));
      } else if (event.data.entries.elementAt(0).key == 'key') {
        //  try{
        //    navigatorKey.currentState?.push(MaterialPageRoute(
        //     builder: (context) {
        //       return roleid == "4" ? Admin() : Mediator();
        //     },
        //   ));
        //  }
        //  catch(e){

        //  }
      } else {
        print('laaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
        print(event.data.entries);

        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) {
            return orderInfo(
              undoc: jsonDecode(
                  event.data.entries.elementAt(2).value)['undocument'],
              title: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['title'],
              content: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['content'],
              Worklocation: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['worklocation'],
              time1: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['startuptime'],
              time2: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['deliverytime'],
              price:
                  '${jsonDecode(event.data.entries.elementAt(2).value)['documentdata']['price']}',
              status: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['status'],
              untitle: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      null
                  ? null
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'undocument']['title'],
              uncontent: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      null
                  ? null
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'undocument']['content'],
              unWorklocation: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      null
                  ? null
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'undocument']['worklocation'],
              untime1: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      null
                  ? null
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'undocument']['startuptime'],
              untime2: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      null
                  ? null
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'undocument']['deliverytime'],
              unprice: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      null
                  ? null
                  : '${jsonDecode(event.data.entries.elementAt(2).value)['undocument']['price']}',
              undocid: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      null
                  ? null
                  : '${jsonDecode(event.data.entries.elementAt(2).value)['undocument']['id']}',
              id: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      null
                  ? null
                  : '${jsonDecode(event.data.entries.elementAt(2).value)['undocument']['createrid']}',
              url1: jsonDecode(event.data.entries.elementAt(2).value)[
                          'attachment'] ==
                      null
                  ? 'null'
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'attachment']['attachmenturl'],
              url2: jsonDecode(event.data.entries.elementAt(2).value)[
                          'unattachemnt'] ==
                      null
                  ? 'null'
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'unattachemnt']['attachmenturl'],
              sellerid: '${jsonDecode(event.data.entries.elementAt(0).value)}',
              buyerid: '${jsonDecode(event.data.entries.elementAt(3).value)}',
              orderid: '${jsonDecode(event.data.entries.elementAt(1).value)}',
              docid:
                  '${jsonDecode(event.data.entries.elementAt(2).value)['documentdata']['id']}',
            );
          },
        ));
      }
    });

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_channel', 'High Importance Notification',
        description: "This channel is for important notification",
        importance: Importance.max);

    flutterLocalNotificationsPlugin.show(
      2,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description),
      ),
    );
  }

  inappNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? roleid = await prefs.getString('userType');
    print(roleid);
    final _firebaseMessaging = FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
      print(event.data.entries.elementAt(2).value);
      print('opened');
      if (event.data.entries.isEmpty) {
        navigatorKey
          ..currentState?.push(MaterialPageRoute(
            builder: (context) {
              return dashBoard();
            },
          ));
      } else if (event.data.entries.elementAt(0).key == 'profile') {
        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) {
            return Room(
              userprofile:
                  jsonDecode('${event.data.entries.elementAt(0).value}'),
              roomid: '${event.data.entries.elementAt(1).value}',
            );
          },
        ));
      } else if (event.data.entries.elementAt(0).key == 'key') {
        // try {
        //   navigatorKey.currentState?.push(MaterialPageRoute(
        //     builder: (context) {
        //       return roleid == "4"
        //           ? Admin(
        //             )
        //           : Mediator();
        //     },
        //   ));
        // } catch (e) {}
      } else {
        print('laaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
        print(event.data.entries.elementAt(2));

        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) {
            return orderInfo(
              undoc: jsonDecode(
                  event.data.entries.elementAt(2).value)['undocument'],
              title: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['title'],
              content: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['content'],
              Worklocation: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['worklocation'],
              time1: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['startuptime'],
              time2: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['deliverytime'],
              price:
                  '${jsonDecode(event.data.entries.elementAt(2).value)['documentdata']['price']}',
              status: jsonDecode(event.data.entries.elementAt(2).value)[
                  'documentdata']['status'],
              untitle: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      'null'
                  ? null
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'undocument']['title'],
              uncontent: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      'null'
                  ? null
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'undocument']['content'],
              unWorklocation: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      'null'
                  ? null
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'undocument']['worklocation'],
              untime1: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      'null'
                  ? null
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'undocument']['startuptime'],
              untime2: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      'null'
                  ? null
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'undocument']['deliverytime'],
              unprice: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      'null'
                  ? null
                  : '${jsonDecode(event.data.entries.elementAt(2).value)['undocument']['price']}',
              undocid: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      'null'
                  ? null
                  : '${jsonDecode(event.data.entries.elementAt(2).value)['undocument']['id']}',
              id: jsonDecode(event.data.entries.elementAt(2).value)[
                          'undocument'] ==
                      'null'
                  ? null
                  : '${jsonDecode(event.data.entries.elementAt(2).value)['undocument']['createrid']}',
              url1: jsonDecode(event.data.entries.elementAt(2).value)[
                          'attachment'] ==
                      null
                  ? 'null'
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'attachment']['attachmenturl'],
              url2: jsonDecode(event.data.entries.elementAt(2).value)[
                          'unattachemnt'] ==
                      null
                  ? 'null'
                  : jsonDecode(event.data.entries.elementAt(2).value)[
                      'unattachemnt']['attachmenturl'],
              sellerid: '${jsonDecode(event.data.entries.elementAt(0).value)}',
              buyerid: '${jsonDecode(event.data.entries.elementAt(3).value)}',
              orderid: '${jsonDecode(event.data.entries.elementAt(1).value)}',
              docid:
                  '${jsonDecode(event.data.entries.elementAt(2).value)['documentdata']['id']}',
            );
          },
        ));
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      RemoteNotification notification = event.notification!;
      AndroidNotification androidNotification = event.notification!.android!;
      if (notification != null && androidNotification != null) {
        sendNotification(
            title: notification.title!, body: notification.body!, event: event);
      }
    });
  }

  bool mediator = false;
  bool admin = false;
  bool login = false;
  checklogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? roleid = await prefs.getString('userType');
    print(roleid);
    print('00000000000000000000000000000000000000');
    if (prefs.getString('profileid') != null) {
      print('tyes');
      setState(() {
        login = true;
      });
    } else if (roleid == "4") {
      print('ffffffff');
      setState(() {
        admin = true;
      });
    } else if (roleid == "3") {
      setState(() {
        mediator = true;
      });
    }
  }
  gg()async{
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: login
          ? Home()
          : admin
              ? Admin()
              : mediator
                  ? add()
                  : signIn(),
      routes: {
        'signUp': (context) => signUp(),
        'signIn': (context) => signIn(),
        'userOption': (context) => userOption(),
        'GMap': (context) => GMap(),
        'Profile': (context) => Profile(
              i: "2",
            ),
        'Search': (context) => Search(searchstring: ''),
        'Workstation': (context) => Workstation(
              subcategories: [],
            ),
        'priceTag': (context) => priceTag(),
        'Post': (context) => Post(),
        'Home': (context) => Home(),
        'Info': (context) => Info(
              maincategory: [],
            ),
        'chatHome': (context) => chatHome(),
        'Room': (context) => Room(),
        'showWorkstation': (context) => showWorkstation(),
        'dashBoard': (context) => dashBoard(),
        // 'orderInfo': (context) => orderInfo(),
        // 'Document': (context) => Document(),
        'dashBoard': (context) => dashBoard()
      },
    );
  }
}
