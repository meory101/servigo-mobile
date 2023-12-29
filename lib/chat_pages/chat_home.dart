import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servigo/chat_pages/room.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class chatHome extends StatefulWidget {
  const chatHome({Key? key}) : super(key: key);

  @override
  State<chatHome> createState() => _chatHomeState();
}

class _chatHomeState extends State<chatHome> {
  late Future rooms;
  String? userid;
  void initState() {
    super.initState();
    rooms = getRooms();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  getRooms() async {
    print('aaaaaaaaaaaaaaaaa');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('usertoken');
    userid = await prefs.getString('userid');
    http.Response response = await http.get(Uri.parse(getrooms + '/${userid}'),
        headers: {'Authorization': 'Bearer ${token}'});

    var body = jsonDecode(response.body);
    print(body);
    if (body['status'] == 'success') {
      body = body['message'];
      // print(body[5]['lastmessage']);
      return body;
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.center,
            width: double.infinity,
            color: maincolor,
            height: MediaQuery.of(context).size.height / 5,
            child: Row(
              children: [
                Text(
                  'SERVIGO CHAT',
                  style: wsubts,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 5 - 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(border_rad_size),
                topRight: Radius.circular(border_rad_size),
              ),
            ),
            child: FutureBuilder(
              future: rooms,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    reverse: false,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          var data = await Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (context) {
                              return Room(
                                  order:
                                      '${snapshot.data[index]['userroom']['userid1']}' ==
                                              userid
                                          ? true
                                          : false,
                                  userprofile: snapshot.data[index]
                                      ['userprofile'],
                                  roomid:
                                      '${snapshot.data[index]['roomdata']['id']}');
                            },
                          ));
                          if (data == true || data == null) {
                            rooms = getRooms();
                          }
                          setState(() {});
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 14),
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Color.fromARGB(255, 234, 233, 233)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  child:
                                      '${snapshot.data[index]['userprofile']['message']['profiledata']['imageurl']}' ==
                                              'null'
                                          ? CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  'assets/images/user.png'))
                                          : CircleAvatar(
                                              backgroundColor:
                                                  Color.fromARGB(93, 83, 81, 81)
                                                      .withOpacity(0.4),
                                              backgroundImage: NetworkImage(
                                                  '${serverlink}' +
                                                      '/storage/' +
                                                      '${snapshot.data[index]['userprofile']['message']['profiledata']['imageurl']}'),
                                            ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${snapshot.data[index]['userprofile']['message']['name']}',
                                            style: bsmallts,
                                          ),
                                          '${snapshot.data[index]['lastmessage']}' ==
                                                  "null"
                                              ? Text(
                                                  '',
                                                  style: smallgreyts,
                                                )
                                              : Text(
                                                  '${snapshot.data[index]['lastmessage']['date']}',
                                                  style: smallgreyts,
                                                )
                                        ],
                                      ),
                                      '${snapshot.data[index]['lastmessage']}' ==
                                              "null"
                                          ? Text(
                                              '',
                                              style: smallgreyts,
                                            )
                                          : Text(
                                              '${snapshot.data[index]['lastmessage']['content']}',
                                              style: smallgreyts,
                                            )
                                    ],
                                  ),
                                ),
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.only(right: 8),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.end,
                              //     children: [
                              //       if (index == 3 || index == 7)
                              //         Container(
                              //           margin: EdgeInsets.only(bottom: 6),
                              //           width: 20,
                              //           height: 20,
                              //           child: CircleAvatar(
                              //             child: Text(
                              //               '${index - 2}',
                              //               style: wsmallts,
                              //             ),
                              //             backgroundColor: maincolor,
                              //           ),
                              //         ),
                              //       // Text(
                              //       //   '11:12 AM',
                              //       //   style: smallgreyts,
                              //       // )
                              //     ],
                              //   ),
                              // ),
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
                          'No chats yet',
                          style: psubts,
                        )
                      ],
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
