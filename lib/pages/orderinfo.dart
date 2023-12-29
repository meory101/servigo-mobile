import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:servigo/db/components.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/dashboard.dart';
import 'package:servigo/pages/document.dart';
import 'package:servigo/pages/map.dart';
import 'package:servigo/pages/test.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class orderInfo extends StatefulWidget {
  String? title;
  String? content;
  String? Worklocation;
  String? time1;
  String? time2;
  String? price;
  String? status;
  String? sellerid;
  String? orderid;
  String? docid;
  String? buyerid;
  var undoc;
  String? untitle;
  String? uncontent;
  String? unWorklocation;
  String? untime1;
  String? untime2;
  String? unprice;
  String? undocid;
  String? id;
  String? url1;
  String? url2;
  orderInfo({
    this.title,
    this.content,
    this.Worklocation,
    this.time1,
    this.time2,
    this.price,
    this.status,
    this.sellerid,
    this.orderid,
    this.buyerid,
    this.docid,
    this.undoc,
    this.untitle,
    this.uncontent,
    this.unWorklocation,
    this.untime1,
    this.untime2,
    this.unprice,
    this.undocid,
    this.id,
    this.url1,
    this.url2,
  });

  @override
  State<orderInfo> createState() => _orderInfoState();
}

bool check = false;
String? path1;
String? path2;
ScrollController scontroller = new ScrollController();

class _orderInfoState extends State<orderInfo> {
  void initState() {
    print('000000000000000000000000000000000000000');
    print(widget.url1); //2
    print(widget.url2); //1
    print(widget.id); //2
    print('000000000000000000000000000000000000000');
    gg();
    getDocs();

    super.initState();
  }

  getDocs() async {
    path1 = null;
    path2 = null;
    print(';;;;;;;;;;;;;;;;;;;;;;;;');
    print(widget.url1);
    print(widget.url2);
    print(';;;;;;;;;;;;;;;;;;;;;;;;');

    String url1 = '${serverlink}' + '/storage/' + '${widget.url1}';
    String url2 = '${serverlink}' + '/storage/' + '${widget.url2}';
    widget.url1 != "null" ? path1 = await loadPDF(url1) : "null";
    widget.url2 != "null" ? path2 = await loadPDF(url2) : "null";
    setState(() {});
    print('000000000000000000000000000000000000000');
    print(path1);
    print(path2);
    print('000000000000000000000000000000000000000');
  }

  deleteOrder() async {
    String? uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userid = await prefs.getString('userid');
    if ('$userid' != '${widget.sellerid}') {
      uid = '${widget.sellerid}';
    } else {
      uid = '${widget.buyerid}';
    }
    String? token = await prefs.getString('usertoken');
    Map data = {
      'orderid': '${widget.orderid}',
      'docid': '${widget.docid}',
      'type': 'reject order',
      'sellerid': '${widget.sellerid}',
      'buyerid': '${widget.buyerid}',
      'userid': '${uid}'
    };
    print(data);
    http.Response response = await http.post(Uri.parse('${deleteorder}'),
        body: data, headers: {'Authorization': 'Bearer ${token}'});
    // if (!mounted) return;
    // var body = jsonDecode(response.body);
    // print(body);
    // if (body['status'] == 'success') {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return dashBoard();
      },
    ));
    // }
  }

  deleteDocument(docid, v) async {
    print(docid);
    String? uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userid = await prefs.getString('userid');
    if ('$userid' != '${widget.sellerid}') {
      uid = '${widget.sellerid}';
    } else {
      uid = '${widget.buyerid}';
    }
    String? token = await prefs.getString('usertoken');
    Map data = {
      'docid': '${docid}',
      'userid': '${uid}',
      'orderid': '${widget.orderid}',
      'sellerid': '${widget.sellerid}',
      'buyerid': '${widget.buyerid}',
      'userid': '${uid}',
    };
    if (v == false) {
      data.addAll({
        'type': 'reject doc',
      });
    }
    http.Response response = await http.post(Uri.parse('${deletedocument}'),
        body: data, headers: {'Authorization': 'Bearer ${token}'});
    print(data);
    // print(jsonDecode(response.body));
    // return;
    if (!mounted) return;
    // var body = jsonDecode(response.body);
    // print(body);
    // if (body['status'] == 'success') {
    setState(() {
      widget.undoc = null;
    });
    // }
  }

  acceptDocument() async {
    String? uid;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    String? userid = await prefs.getString('userid');
    if ('$userid' != '${widget.sellerid}') {
      uid = '${widget.sellerid}';
    } else {
      uid = '${widget.buyerid}';
    }

    await deleteDocument(widget.docid, true);
    http.Response response1 = await http.post(Uri.parse('${updatedoc}'), body: {
      'id': '${widget.undocid}',
      'isapprov': '${1}',
      'orderid': '${widget.orderid}',
      'sellerid': '${widget.sellerid}',
      'buyerid': '${widget.buyerid}',
      'userid': '${uid}',
      'type': 'accept doc'
    }, headers: {
      'Authorization': 'Bearer ${token}'
    });
    if (!mounted) return;
    // var body = jsonDecode(response1.body);
    // if (body['status'] == 'success') {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return dashBoard();
      },
    ));
    // }
  }

  acceptOrder() async {
    String? uid;
    //update order status available;
    //update document isapprov 1;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    String? userid = await prefs.getString('userid');
    if ('$userid' != '${widget.sellerid}') {
      uid = '${widget.sellerid}';
    } else {
      uid = '${widget.buyerid}';
    }
    print('0000000000000000000000000000000000000000000000000///////////////');
    print(uid);

    http.Response response = await http.post(Uri.parse('${updateorder}'),
        body: {'id': '${widget.orderid}', 'status': 'available'},
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body = jsonDecode(response.body);
    print(body);
    if (body['status'] == 'success') {
      http.Response response1 =
          await http.post(Uri.parse('${updatedoc}'), body: {
        'id': '${widget.docid}',
        'isapprov': '${1}',
        'type': 'accept order',
        'sellerid': '${widget.sellerid}',
        'buyerid': '${widget.buyerid}',
        'userid': '${uid}'
      }, headers: {
        'Authorization': 'Bearer ${token}'
      });

      // if (jsonDecode(response1.body)['status'] == 'success') {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) {
          return dashBoard();
        },
      ));
      // }
    }
  }

  String? userid;
  gg() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = await prefs.getString('userid');
    if (!mounted) return;
    setState(() {});
    print(widget.sellerid);
    print(userid);
    print(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scontroller,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              children: [
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(border_rad_size),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    alignment: Alignment.center,
                    child: InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Order Information',
                              style: pmaints,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                widget.Worklocation != 'null/null'
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            top: 20, bottom: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                var latlong = widget
                                                    .Worklocation!
                                                    .split('/');
                                                print(latlong);
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (context) {
                                                    return GMap(
                                                      browse: true,
                                                      lat: double.parse(
                                                          '${latlong[0]}'),
                                                      long: double.parse(
                                                          '${latlong[1]}'),
                                                    );
                                                  },
                                                ));
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'location',
                                                    style: psubts,
                                                  ),
                                                  Icon(
                                                    Icons.location_on,
                                                    color: maincolor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(''),
                                Text(
                                  'Project title : ',
                                  style: bsmallts,
                                ),
                                Text(
                                  '${widget.title}',
                                  style: greyts,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Project content : ',
                                  style: bsmallts,
                                ),
                                Text(
                                  '${widget.content}',
                                  style: greyts,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Startup time : ',
                                  style: bsmallts,
                                ),
                                Text(
                                  '${widget.time1}',
                                  style: greyts,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery time : ',
                                  style: bsmallts,
                                ),
                                Text(
                                  '${widget.time2}',
                                  style: greyts,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price : ',
                                  style: bsmallts,
                                ),
                                Text(
                                  '${widget.price}',
                                  style: greyts,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Attachments : ',
                                  style: bsmallts,
                                ),
                                path1 != null
                                    ? InkWell(
                                        onTap: () async {
                                          await OpenFile.open(path1);
                                        },
                                        child: Text(
                                          '${widget.url1}',
                                          style: greyts,
                                        ),
                                      )
                                    : Text(
                                        'no attachments yet',
                                        style: greyts,
                                      )
                              ],
                            ),
                          ),
                          widget.status == 'available'
                              ? Container(
                                  margin: EdgeInsets.only(top: 30),
                                  alignment: Alignment.topRight,
                                  child: RaisedButton(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            border_rad_size)),
                                    color: maincolor,
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                        builder: (context) {
                                          return Document(
                                            orderid: widget.orderid,
                                            title: widget.title,
                                            content: widget.content,
                                            Worklocation: widget.Worklocation,
                                            price: widget.price,
                                            time1: widget.time1,
                                            time2: widget.time2,
                                            sellerid: widget.sellerid,
                                            buyerid: widget.buyerid,
                                          );
                                        },
                                      ));
                                    },
                                    child: Text(
                                      'Make a change',
                                      style: wsmallts,
                                    ),
                                  ),
                                )
                              : Text(''),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              widget.status == 'waiting' &&
                                      widget.sellerid == userid
                                  ? Container(
                                      margin: EdgeInsets.only(top: 30),
                                      alignment: Alignment.topRight,
                                      child: RaisedButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                border_rad_size)),
                                        color: errorcolor,
                                        onPressed: () {
                                          deleteOrder();
                                        },
                                        child: Text(
                                          'Reject order',
                                          style: wsmallts,
                                        ),
                                      ),
                                    )
                                  : Text(''),
                              widget.status == 'waiting' &&
                                      widget.sellerid == userid
                                  ? Container(
                                      margin: EdgeInsets.only(top: 30),
                                      alignment: Alignment.topRight,
                                      child: RaisedButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                border_rad_size)),
                                        color: maincolor,
                                        onPressed: () {
                                          acceptOrder();
                                        },
                                        child: Text(
                                          'Accept order',
                                          style: wsmallts,
                                        ),
                                      ),
                                    )
                                  : Text(''),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {},
                    ),
                  ),
                ),
                if (widget.undoc != null)
                  ...([
                    InkWell(
                      onTap: () {
                        setState(() {
                          check = !check;
                        });
                      },
                      child: Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'check updates',
                                style: psmallts,
                              ),
                              Icon(
                                check == false
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up,
                                color: maincolor,
                                size: 20,
                              )
                            ],
                          )),
                    )
                  ]),
                if (check == true && widget.undoc != null)
                  ...([
                    Card(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(border_rad_size),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        alignment: Alignment.center,
                        child: InkWell(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Container(
                                //   margin: EdgeInsets.symmetric(vertical: 20),
                                //   child: Text(
                                //     'Order Information',
                                //     style: pmaints,
                                //   ),
                                // ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      widget.unWorklocation != 'null/null'
                                          ? Container(
                                              margin: EdgeInsets.only(
                                                  top: 20, bottom: 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      var latlong = widget
                                                          .Worklocation!
                                                          .split('/');
                                                      print(latlong);
                                                      Navigator.of(context)
                                                          .push(
                                                              MaterialPageRoute(
                                                        builder: (context) {
                                                          return GMap(
                                                            browse: true,
                                                            lat: double.parse(
                                                                '${latlong[0]}'),
                                                            long: double.parse(
                                                                '${latlong[1]}'),
                                                          );
                                                        },
                                                      ));
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'location',
                                                          style: psubts,
                                                        ),
                                                        Icon(
                                                          Icons.location_on,
                                                          color: maincolor,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Text(''),
                                      Text(
                                        'Project title : ',
                                        style: bsmallts,
                                      ),
                                      Text(
                                        '${widget.untitle}',
                                        style: greyts,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Project content : ',
                                        style: bsmallts,
                                      ),
                                      Text(
                                        '${widget.uncontent}',
                                        style: greyts,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Startup time : ',
                                        style: bsmallts,
                                      ),
                                      Text(
                                        '${widget.untime1}',
                                        style: greyts,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Delivery time : ',
                                        style: bsmallts,
                                      ),
                                      Text(
                                        '${widget.untime2}',
                                        style: greyts,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Price : ',
                                        style: bsmallts,
                                      ),
                                      Text(
                                        '${widget.unprice}',
                                        style: greyts,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Attachments : ',
                                        style: bsmallts,
                                      ),
                                      path2 != null
                                          ? InkWell(
                                              onTap: () async {
                                                await OpenFile.open(path2);
                                              },
                                              child: Text(
                                                '${widget.url2}',
                                                style: greyts,
                                              ),
                                            )
                                          : Text(
                                              'no attachments yet',
                                              style: greyts,
                                            )
                                    ],
                                  ),
                                ),
                                '${widget.id}' != '$userid'
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            bottom: 20, top: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(top: 30),
                                              alignment: Alignment.topRight,
                                              child: RaisedButton(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 15),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            border_rad_size)),
                                                color: errorcolor,
                                                onPressed: () {
                                                  deleteDocument(
                                                      widget.undocid, false);
                                                },
                                                child: Text(
                                                  'Reject',
                                                  style: wsmallts,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 30),
                                              alignment: Alignment.topRight,
                                              child: RaisedButton(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 15),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            border_rad_size)),
                                                color: maincolor,
                                                onPressed: () {
                                                  acceptDocument();
                                                },
                                                child: Text(
                                                  'Accept',
                                                  style: wsmallts,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : Text('')
                              ]),
                        ),
                      ),
                    ),
                  ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
