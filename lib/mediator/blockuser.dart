import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/search.dart';
import 'package:servigo/pages/showprofile.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MblockUser extends StatefulWidget {
  const MblockUser({Key? key}) : super(key: key);

  @override
  State<MblockUser> createState() => _MblockUserState();
}

class _MblockUserState extends State<MblockUser> {
  TextEditingController con = new TextEditingController();
  late Future users;
  @override
  void initState() {
    users = getUsers();
    super.initState();
  }

  MblockUser(index) async {
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
      users = getUsers();
      setState(() {
        
      });
    }
  }

  bool admin = true;
  getUsers() async {
    var gg;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');

    http.Response response = await http.get(Uri.parse(getusers),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body = jsonDecode(response.body);
    // print(body);
    if (body['status'] == 'success') {
      gg = [];
      for (int i = 0; i < body['message'].length; i++) {
        gg.add(body['message'][i]);
      }
      print('000000000000000000000000000000000000000000000000000');
      return gg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: 100,
          title: Container(
            padding: EdgeInsets.only(left: 10, top: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: maincolor1.withOpacity(0.2),
              ),
              child: SearchBarAnimation(
                onEditingComplete: () async {
                  var res = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return Search(
                        searchstring: con.text,
                        admin: true,
                      );
                    },
                  ));
                  print(res);
                  if (res == '1') {
                    users = getUsers();
                    setState(() {});
                  }
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
          )),
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
                                    admin == null
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
                                          onTap: () {},
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
                            if (admin == true)
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
                                          MblockUser(snapshot.data[index]
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
