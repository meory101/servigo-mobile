import 'dart:async';
import 'dart:convert';

import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:jiffy/jiffy.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/documentform.dart';
import 'package:servigo/pages/pricetag.dart';
import 'package:servigo/pages/showprofile.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Room extends StatefulWidget {
  bool? order;
  String? roomid;
  String? postid;
  var userprofile;

  List<String>? subcategoryid;
  Room({
    this.roomid,
    this.userprofile,
    this.postid,
    this.subcategoryid,
    this.order,
  });
  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  bool update = false;
  String? date;
  late Stream messages;
  TextEditingController messagecontroller = new TextEditingController();
  ScrollController controller = new ScrollController();
  String? messageid;
  String? userid;
  Timer? timer;

  void initState() {
    print('555555555555555555555555555555555555555555555555555555555');
    widget.userprofile['message']['profiledata']['teamsize'];
    print('555555555555555555555555555555555555555555555555555555555');

    gg();
    print(widget.subcategoryid);
    super.initState();
    print(widget.userprofile);
    messages = getMessages();

    timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
      setState(() {
        setState(() {
          messages = getMessages();
        });
      });
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  gg() async {
    print(widget.subcategoryid);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (widget.subcategoryid != null) {
      print('------------------------------------------------');
      print(widget.subcategoryid);
      print('--------------------------------------------------------------');
      // return;
      prefs.setStringList('orderids', widget.subcategoryid!);
      print(prefs.getStringList('orderids'));
    } else {
      print('**************************************************************');
      List<String> pricing = [];
      print('${widget.userprofile['message']['profiledata']['id']}');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('usertoken');

      http.Response response = await http.get(
        Uri.parse('${getpricing}' +
            '/' +
            '${widget.userprofile['message']['profiledata']['id']}'),
        headers: {'Authorization': 'Bearer ${token}'},
      );
      if (!mounted) return;
      print('llllllllllllllllll');
      var body = jsonDecode(response.body);
      print(body);
      if (body['status'] == 'success') {
        print('ffjjfjfjfjf');
        for (int i = 0; i < body['message'].length; i++) {
          pricing.add('${body['message'][i]['pricingdata']['subcategoryid']}');
          print('fkfk');
        }
        print(pricing);
        prefs.setStringList('orderids', pricing);
        print('0000000000000000000000000000000000000000000000');
        print('------------------------------------------------');
        print(prefs.getStringList('orderids'));
        print('--------------------------------------------------------------');
        return;
      }
    }
  }

  String? buyerid;
  String? sellerid;
  var userroom;
  checkOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    buyerid = await prefs.getString('userid');
    sellerid = '${widget.userprofile['message']['profiledata']['userid']}';

    http.Response response = await http.post(
        body: {'buyerid': '${buyerid}', 'sellerid': '${sellerid}'},
        Uri.parse(checkorder),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body = jsonDecode(response.body);
    print(
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
    print(body);
    if (body['message'] == 'order') {
      Blurry.error(
          title: 'Opps error',
          description: 'You have active order request with this seller',
          confirmButtonText: 'Okay',
          titleTextStyle: const TextStyle(fontFamily: 'Zen'),
          buttonTextStyle: const TextStyle(
              decoration: TextDecoration.underline, fontFamily: 'Zen'),
          descriptionTextStyle: const TextStyle(fontFamily: 'Zen'),
          onConfirmButtonPressed: () {
            Navigator.of(context).pop();
          }).show(context);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return documentForm(
            sellerid: sellerid,
            buyerid: buyerid,
            lat: userroom != null ? userroom['lat'] : null,
            long: userroom != null ? userroom['long'] : null,
          );
        },
      ));
    }
  }

  getMessages() async* {
    // print(messages);
    // print('dkdkdkd');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    userid = await prefs.getString('userid');
    var body;
    try {
      http.Response response = await http.get(
          Uri.parse('${getmessages}/${widget.roomid}'),
          headers: {'Authorization': 'Bearer ${token}'});
      if (!mounted) return;
      if (response.body.isNotEmpty) {
        body = jsonDecode(response.body);
      }
      userroom = body['userroom'];
      // print(body);

      body = body['message'];

      yield body;
    } catch (e) {
      // print(e);
    }
  }

  sendMessage() async {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
            backgroundColor: Colors.transparent.withOpacity(0.4),
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 100),
              // width: 10,
              // height: 10,
              child: CircularProgressIndicator(
                color: maincolor,
              ),
            ),
          ),
        );
      },
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    String? userid = await prefs.getString('userid');

    http.Response response = await http.post(
        body: {
          'content': '${messagecontroller.text}',
          'date': '${Jiffy().Hm}',
          'senderid': '$userid',
          'recieverid':
              '${widget.userprofile['message']['profiledata']['userid']}',
          'roomid': '${widget.roomid}',
        },
        Uri.parse(addmessage),
        headers: {'Authorization': 'Bearer ${token}'});

    // if (jsonDecode(response.body)['status'] == 'success') {
    messagecontroller.clear();
    setState(() {
      messages = getMessages();
    });
    Navigator.of(context).pop();
    print(controller);
    // if (controller.hasClients) {
    // controller.jumpTo(controller.position.extentAfter);
    // }
  }

  updateMessage() async {
    var lk = date!.split(' ').reversed.toList();
    print(lk);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    String? userid = await prefs.getString('userid');

    http.Response response = await http.post(
        body: {
          'content': '${messagecontroller.text}',
          'date': 'edited ${lk[0]}',
          'senderid': '$userid',
          'recieverid':
              '${widget.userprofile['message']['profiledata']['userid']}',
          'roomid': '${widget.roomid}',
          'id': '$messageid'
        },
        Uri.parse(updatemessage),
        headers: {'Authorization': 'Bearer ${token}'});

    if (jsonDecode(response.body)['status'] == 'success') {
      messagecontroller.clear();
      if (!mounted) return;
      setState(() {
        messages = getMessages();
        update = false;
      });
      // if (controller.hasClients) {
      //   controller.animateTo(
      //     controller.position.maxScrollExtent,
      //     curve: Curves.easeOut,
      //     duration: const Duration(milliseconds: 300),
      //   );
      // }
    }
  }

  deleteMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');

    http.Response response = await http.post(
        body: {'id': '$messageid'},
        Uri.parse(deletemessage),
        headers: {'Authorization': 'Bearer ${token}'});
    print(jsonDecode(response.body));
    if (jsonDecode(response.body)['status'] == 'success') {
      messagecontroller.clear();
      setState(() {
        messages = getMessages();
        update = false;
      });
      // if (controller.hasClients) {
      //   controller.animateTo(
      //     controller.position.maxScrollExtent +
      //         MediaQuery.of(context).size.height / 2,
      //     curve: Curves.easeOut,
      //     duration: const Duration(milliseconds: 300),
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 25),
            alignment: Alignment.center,
            width: double.infinity,
            color: maincolor,
            height: MediaQuery.of(context).size.height / 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return xProfile(
                                i: "0",
                                userid:
                                    '${widget.userprofile['message']['profiledata']['userid']}');
                          },
                        ));
                      },
                      child: Row(
                        children: [
                          Container(
                              width: 40,
                              height: 40,
                              child:
                                  '${widget.userprofile['message']['profiledata']['imageurl']}' ==
                                          "null"
                                      ? CircleAvatar(
                                          backgroundImage: AssetImage(
                                            'assets/images/user.png',
                                          ),
                                        )
                                      : CircleAvatar(
                                          backgroundColor:
                                              Color.fromARGB(93, 83, 81, 81)
                                                  .withOpacity(0.4),
                                          backgroundImage: NetworkImage(
                                            '${serverlink}' +
                                                '/storage/' +
                                                '${widget.userprofile['message']['profiledata']['imageurl']}',
                                          ),
                                        )),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.userprofile['message']['name']}',
                                  style: wsmallts,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                InkWell(
                    onTap: () {},
                    child: FocusedMenuHolder(
                        menuWidth: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.more_vert_outlined,
                            color: Colors.white,
                          ),
                        ),
                        openWithTap: true,
                        onPressed: () {},
                        menuItems: <FocusedMenuItem>[
                          if (widget.userprofile['message']['profiledata']
                                  ['teamsize'] !=
                              null)
                            ...([
                              FocusedMenuItem(
                                title: Text(
                                  'Order',
                                  style: psmallts,
                                ),
                                onPressed: () {
                                  checkOrder();
                                },
                                trailingIcon: Icon(
                                  Icons.task_alt_outlined,
                                  color: maincolor,
                                  size: 22,
                                ),
                              )
                            ])
                        ]))
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(border_rad_size),
                    topRight: Radius.circular(border_rad_size),
                  ),
                  image: DecorationImage(
                      image: AssetImage('assets/images/bac.jpg'),
                      fit: BoxFit.cover),
                ),
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 5 - 40),
                child: Container(
                  margin: EdgeInsets.only(bottom: 55),
                  child: StreamBuilder(
                    stream: messages,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            reverse: false,
                            controller: controller,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  '${snapshot.data[index]['senderid']}' ==
                                          '$userid'
                                      ? FocusedMenuHolder(
                                          menuWidth: 100,
                                          openWithTap: true,
                                          onPressed: () {},
                                          menuItems: <FocusedMenuItem>[
                                            FocusedMenuItem(
                                              title: Text(
                                                'edit',
                                                style: bsmallts,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  messageid =
                                                      '${snapshot.data[index]['id']}';
                                                  date =
                                                      '${snapshot.data[index]['date']}';
                                                  update = true;
                                                  messagecontroller.text =
                                                      '${snapshot.data[index]['content']}';
                                                });
                                              },
                                              trailingIcon: Icon(
                                                Icons.update,
                                                size: 22,
                                              ),
                                            ),
                                            FocusedMenuItem(
                                              backgroundColor: errorcolor,
                                              title: Text(
                                                'delete',
                                                style: wsmallts,
                                              ),
                                              trailingIcon: Icon(
                                                Icons.delete,
                                                size: 22,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  messageid =
                                                      '${snapshot.data[index]['id']}';
                                                });
                                                deleteMessage();
                                              },
                                            )
                                          ],
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                bottom: 10, right: 10),
                                            child: ChatBubble(
                                              clipper: ChatBubbleClipper5(
                                                  type: BubbleType.sendBubble),
                                              alignment: Alignment.topRight,
                                              margin: EdgeInsets.only(top: 20),
                                              backGroundColor: maincolor1,
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.7,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${snapshot.data[index]['content']}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  'font',
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 10,
                                                                    top: 8),
                                                            child: Text(
                                                              '${snapshot.data[index]['date']}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ))
                                      : Container(
                                          padding: EdgeInsets.only(
                                              bottom: 10, left: 10),
                                          child: ChatBubble(
                                            clipper: ChatBubbleClipper5(
                                                type:
                                                    BubbleType.receiverBubble),
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(top: 20),
                                            backGroundColor: Color(0xffE7E7ED),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.7,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${snapshot.data[index]['content']}',
                                                          style: bg,
                                                        ),
                                                        Container(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 10,
                                                                  top: 8),
                                                          child: Text(
                                                            '${snapshot.data[index]['date']}',
                                                            style: TextStyle(
                                                                color:
                                                                    maincolor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                ],
                              );
                            });
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: maincolor,
                          ),
                        );
                      } else {
                        return Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: Text(''));
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(color: Color(0xffE7E7ED)),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: TextFormField(
                    keyboardAppearance: Brightness.dark,
                    // autofocus: true,
                    controller: messagecontroller,
                    cursorColor: maincolor,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          update == false ? sendMessage() : updateMessage();
                        },
                        color: maincolor1,
                      ),
                      hintText: 'Message',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: maincolor.withOpacity(0.4),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: maincolor.withOpacity(0.4),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: errorcolor),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                // left: 0,
                left: 10,
                child: Container(
                  width: 30,
                  height: 30,
                  child: FloatingActionButton(
                      backgroundColor: maincolor,
                      child: new Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        if (controller.hasClients) {
                          controller.animateTo(
                            controller.position.maxScrollExtent,
                            curve: Curves.easeOut,
                            duration: const Duration(milliseconds: 300),
                          );
                        }
                      }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
