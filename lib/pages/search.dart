import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:servigo/admin/Admin.dart';
import 'package:servigo/chat_pages/room.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/main.dart';
import 'package:servigo/pages/showprofile.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_size.dart';
import '../theme/colors.dart';

class Search extends StatefulWidget {
  String searchstring;
  bool? admin;
  Search({required this.searchstring, this.admin});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late Future users;
  var pimage;
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

  blockUser(index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    http.Response response = await http.post(Uri.parse(blockuser),
        body: {'id': '${index}'},
        headers: {'Authorization': 'Bearer ${token}'});
    var body = jsonDecode(response.body);
    if (body['status'] == 'success') {
      // users = getUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User has been successfully blocked.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop('1');

   
    }
  }

  getUsers() async {
    var gg;
    print(widget.searchstring);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    String? userid = await prefs.getString('userid');

    http.Response response = await http.get(
        Uri.parse(usersearch + '/${widget.searchstring}'),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body = jsonDecode(response.body);
    // print(body);
    if (body['status'] == 'success') {
      gg = [];
      for (int i = 0; i < body['message'].length; i++) {
        if ('${body['message'][i]['userdata']['id']}' != '$userid') {
          gg.add(body['message'][i]);
        }
      }

      print('000000000000000000000000000000000000000000000000000');
      return gg;
    }
  }

  getProfileImage(profileid) async {
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

  @override
  void initState() {
    users = getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: users,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data.length > 0) {
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return xProfile(
                              i: "0",
                              userid:
                                  "${snapshot.data[index]['userdata']['id']}",
                            );
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
                                          '${snapshot.data[index]['profiledata']['message']['profiledata']['imageurl']}' ==
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
                                                          '${snapshot.data[index]['profiledata']['message']['profiledata']['imageurl']}'),
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
                                            '${snapshot.data[index]['userdata']['name']}',
                                            style: btitle,
                                          ),
                                          '${snapshot.data[index]['profiledata']['message']['profiledata']['teamsize']}' !=
                                                  'null'
                                              ? Text(
                                                  '${snapshot.data[index]['profiledata']['message']['profiledata']['teamsize']}',
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
                                                          ['profiledata']
                                                          ['message']
                                                          ['subcategorydata']
                                                      .length ==
                                                  1
                                              ? Text(
                                                  '${snapshot.data[index]['profiledata']['message']['subcategorydata'][0]['name']}',
                                                  style: greyts,
                                                )
                                              : snapshot
                                                          .data[index]
                                                              ['profiledata']
                                                              ['message'][
                                                              'subcategorydata']
                                                          .length ==
                                                      2
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                          Text(
                                                            '${snapshot.data[index]['profiledata']['message']['subcategorydata'][0]['name']}',
                                                            style: greyts,
                                                          ),
                                                          Text(
                                                            ' ${snapshot.data[index]['profiledata']['message']['subcategorydata'][1]['name']}',
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
                            '${snapshot.data[index]['userdata']['roleid']}' ==
                                        "1" &&
                                    widget.admin == null
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
                                                            ['profiledata']
                                                            ['message']
                                                            ['subcategorydata']
                                                        .length ==
                                                    2
                                                ? uu = [
                                                    '${snapshot.data[index]['profiledata']['message']['subcategorydata'][0]['id']}',
                                                    '${snapshot.data[index]['profiledata']['message']['subcategorydata'][1]['id']}'
                                                  ]
                                                : uu = [
                                                    '${snapshot.data[index]['profiledata']['message']['subcategorydata'][0]['id']}'
                                                  ];

                                            createRoom(
                                                snapshot.data[index]['userdata']
                                                    ['id'],
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
                            if (widget.admin == true)
                              ...([
                                Container(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 20, right: 20),
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
                                        color: errorcolor,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          blockUser(snapshot.data[index]
                                              ['userdata']['id']);
                                        },
                                        child: Text(
                                          'Block',
                                          style: wsmallts,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ])
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: maincolor),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/search.png',
                    height: 100,
                    width: 100,
                  ),
                  Text(
                    'No resaults',
                    style: psubts,
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
