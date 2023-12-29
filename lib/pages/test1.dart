import 'dart:convert';
import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:servigo/chat_pages/room.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/main.dart';
import 'package:servigo/pages/showprofile.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWidget extends StatefulWidget {
  String? postid;
  MyWidget({this.postid});
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

late Future future;

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    future = getrec();
  }

  createRoom(userid2, subs) async {
    print(subs);
    print(userid2);
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
              subcategoryid: subs,
            );
          },
        ));
      }
    }
  }

  List users = [];
  getrec() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    print(widget.postid);
    String url =
        'https://hadi12345.pythonanywhere.com/predict/${widget.postid}';
    try {
      http.Response res = await http.get(Uri.parse(url));
      var body = jsonDecode(res.body);
      print(body);
      body = (body['user_prediction']);
      for (int i = 0; i < body.length; i++) {
        String? userid = body[i];
        http.Response response = await http.get(
            Uri.parse('${getprofile}' + '/${userid}'),
            headers: {'Authorization': 'Bearer ${token}'});
        var body1 = jsonDecode(response.body);
        if (!mounted) return;
        if (body1['status'] == 'success') {
          users.add(body1['message']);
        }
      }
      print(users.length);
      print(users);

      return users;
    } catch (e) {
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

  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: future,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && users.length > 0) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return '${snapshot.data[index]['roleid']}' == '${1}'
                  ? InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return xProfile(
                                i: "0",
                                userid:
                                    "${snapshot.data[index]['profiledata']['userid']}");
                          },
                        ));
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(border_rad_size),
                          color: Colors.transparent,
                        ),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      child:
                                          '${snapshot.data[index]['profiledata']['imageurl']}' ==
                                                  'null'
                                              ? CircleAvatar(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                              93, 83, 81, 81)
                                                          .withOpacity(0.4),
                                                  backgroundImage: AssetImage(
                                                      'assets/images/user.png'),
                                                )
                                              : CircleAvatar(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                              93, 83, 81, 81)
                                                          .withOpacity(0.4),
                                                  backgroundImage: NetworkImage(
                                                      '$serverlink' +
                                                          '/storage/' +
                                                          '${snapshot.data[index]['profiledata']['imageurl']}'),
                                                ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${snapshot.data[index]['name']}',
                                            style: btitle,
                                          ),
                                          '${snapshot.data[index]['profiledata']['teamsize']}' !=
                                                  'null'
                                              ? Text(
                                                  '${snapshot.data[index]['profiledata']['teamsize']}',
                                                  style: greyts,
                                                )
                                              : Container(
                                                  padding:
                                                      EdgeInsets.only(top: 10),
                                                  child: Text(
                                                    'Byer account',
                                                    style: psmallts,
                                                  )),
                                          snapshot
                                                      .data[index]
                                                          ['subcategorydata']
                                                      .length ==
                                                  1
                                              ? Text(
                                                  '${snapshot.data[index]['subcategorydata'][0]['name']}',
                                                  style: greyts,
                                                )
                                              : snapshot
                                                          .data[index][
                                                              'subcategorydata']
                                                          .length ==
                                                      2
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                          Text(
                                                            '${snapshot.data[index]['subcategorydata'][0]['name']}',
                                                            style: greyts,
                                                          ),
                                                          Text(
                                                            ' ${snapshot.data[index]['subcategorydata'][1]['name']}',
                                                            style: greyts,
                                                          )
                                                        ])
                                                  : Text(''),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            '${snapshot.data[index]['roleid']}' == "1"
                                ? Container(
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(top: 20, right: 20),
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 100,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: maincolor.withOpacity(0.4),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              border_rad_size),
                                          color: maincolor,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            var uu;
                                            snapshot
                                                        .data[index]
                                                            ['subcategorydata']
                                                        .length ==
                                                    2
                                                ? uu = [
                                                    '${snapshot.data[index]['subcategorydata'][0]['id']}',
                                                    '${snapshot.data[index]['subcategorydata'][1]['id']}'
                                                  ]
                                                : uu = [
                                                    '${snapshot.data[index]['subcategorydata'][0]['id']}'
                                                  ];

                                            createRoom(
                                                snapshot.data[index]
                                                    ['profiledata']['userid'],
                                                uu);
                                          },
                                          child: Text(
                                            'Contact',
                                            style: wsmallts,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(''),
                          ],
                        ),
                      ),
                    )
                  : Text('');
            },
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: maincolor,
            ),
          );
        } else {
          return Text('');
        }
      },
    ));
  }
}
