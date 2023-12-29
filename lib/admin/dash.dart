import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/main.dart';
import 'package:servigo/pages/download.dart';
import 'package:servigo/pages/orderinfo.dart';
import 'package:servigo/pages/showprofile.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Dash extends StatefulWidget {
  const Dash({Key? key}) : super(key: key);

  @override
  State<Dash> createState() => _DashState();
}

class _DashState extends State<Dash> {
  late Future orders;

  getOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    String? userid = await prefs.getString('userid');
    http.Response response = await http.get(Uri.parse('${getorders}' + '/${0}'),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body = jsonDecode(response.body);

    print(body);
    return body['orderdata'];
  }

  @override
  void initState() {
    orders = getOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
        body: SafeArea(
      child: Container(
        child: FutureBuilder(
          future: orders,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data.length > 0) {
              return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Card(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(border_rad_size),
                              ),
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              // padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),

                              alignment: Alignment.center,
                              child: InkWell(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {},
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Column(
                                          children: [
                                            Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 20),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) {
                                                      return xProfile(
                                                          i: "0",
                                                          userid:
                                                              '${snapshot.data[index]['sellerprofile']['message']['profiledata']['userid']}');
                                                    },
                                                  ));
                                                },
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Container(
                                                            width: 70,
                                                            height: 70,
                                                            child: '${snapshot.data[index]['sellerprofile']['message']['profiledata']['imageurl']}' !=
                                                                    "null"
                                                                ? CircleAvatar(
                                                                    backgroundColor: Color.fromARGB(
                                                                            93,
                                                                            83,
                                                                            81,
                                                                            81)
                                                                        .withOpacity(
                                                                            0.4),
                                                                    backgroundImage:
                                                                        NetworkImage('${serverlink}' +
                                                                            '/storage/' +
                                                                            '${snapshot.data[index]['sellerprofile']['message']['profiledata']['imageurl']}'),
                                                                  )
                                                                : CircleAvatar(
                                                                    backgroundColor: Color.fromARGB(
                                                                            93,
                                                                            83,
                                                                            81,
                                                                            81)
                                                                        .withOpacity(
                                                                            0.4),
                                                                    backgroundImage:
                                                                        AssetImage(
                                                                            "assets/images/user.png"),
                                                                  ),
                                                          ),
                                                        )),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${snapshot.data[index]['sellerprofile']['message']['name']}',
                                                              style: bsubts,
                                                            ),
                                                            Text(
                                                              'order seller',
                                                              style: greyts,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (context) {
                                                    return xProfile(
                                                        i: "0",
                                                        userid:
                                                            '${snapshot.data[index]['buyerprofile']['message']['profiledata']['userid']}');
                                                  },
                                                ));
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10),
                                                        child: Container(
                                                          width: 70,
                                                          height: 70,
                                                          child:
                                                              '${snapshot.data[index]['buyerprofile']['message']['profiledata']['imageurl']}' !=
                                                                      "null"
                                                                  ? CircleAvatar(
                                                                      backgroundColor: Color.fromARGB(
                                                                              93,
                                                                              83,
                                                                              81,
                                                                              81)
                                                                          .withOpacity(
                                                                              0.4),
                                                                      backgroundImage: NetworkImage('${serverlink}' +
                                                                          '/storage/' +
                                                                          '${snapshot.data[index]['buyerprofile']['message']['profiledata']['imageurl']}'),
                                                                    )
                                                                  : CircleAvatar(
                                                                      backgroundColor: Color.fromARGB(
                                                                              93,
                                                                              83,
                                                                              81,
                                                                              81)
                                                                          .withOpacity(
                                                                              0.4),
                                                                      backgroundImage:
                                                                          AssetImage(
                                                                              "assets/images/user.png"),
                                                                    ),
                                                        ),
                                                      )),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${snapshot.data[index]['buyerprofile']['message']['name']}',
                                                            style: bsubts,
                                                          ),
                                                          Text(
                                                            'order buyer',
                                                            style: greyts,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Title',
                                            style: psmallts,
                                          ),
                                          Text(
                                            '${snapshot.data[index]['documentdata']['documentdata']['title']}',
                                            style: greyts,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Delivery time',
                                            style: psmallts,
                                          ),
                                          Text(
                                            '${snapshot.data[index]['documentdata']['documentdata']['deliverytime']}',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 40, right: 30),
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
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) {
                                                return orderInfo(
                                                  title:
                                                      '${snapshot.data[index]['documentdata']['documentdata']['title']}',
                                                  content:
                                                      '${snapshot.data[index]['documentdata']['documentdata']['content']}',
                                                  Worklocation:
                                                      '${snapshot.data[index]['documentdata']['documentdata']['worklocation']}',
                                                  time1:
                                                      '${snapshot.data[index]['documentdata']['documentdata']['startuptime']}',
                                                  time2:
                                                      '${snapshot.data[index]['documentdata']['documentdata']['deliverytime']}',
                                                  price:
                                                      '${snapshot.data[index]['documentdata']['documentdata']['price']}',
                                                  status:
                                                      '${snapshot.data[index]['orderdata']['status']}',
                                                  sellerid:
                                                      '${snapshot.data[index]['orderdata']['sellerid']}',
                                                  buyerid:
                                                      '${snapshot.data[index]['orderdata']['buyerid']}',
                                                  orderid:
                                                      '${snapshot.data[index]['orderdata']['id']}',
                                                  docid:
                                                      '${snapshot.data[index]['documentdata']['documentdata']['id']}',
                                                  url1: '${snapshot.data[index]['documentdata']['attachment']}' ==
                                                          'null'
                                                      ? 'null'
                                                      : '${snapshot.data[index]['documentdata']['attachment']['attachmenturl']}',
                                                  url2: '${snapshot.data[index]['documentdata']['unattachemnt']}' ==
                                                          'null'
                                                      ? 'null'
                                                      : '${snapshot.data[index]['documentdata']['unattachemnt']['attachmenturl']}',
                                                  undoc: '${snapshot.data[index]['documentdata']['undocument']}' ==
                                                          'null'
                                                      ? null
                                                      : '${snapshot.data[index]['documentdata']['undocument']}',
                                                  untitle:
                                                      '${snapshot.data[index]['documentdata']['undocument']}' ==
                                                              'null'
                                                          ? null
                                                          : '${snapshot.data[index]['documentdata']['undocument']['title']}',
                                                  uncontent:
                                                      '${snapshot.data[index]['documentdata']['undocument']}' ==
                                                              'null'
                                                          ? null
                                                          : '${snapshot.data[index]['documentdata']['undocument']['content']}',
                                                  unWorklocation:
                                                      '${snapshot.data[index]['documentdata']['undocument']}' ==
                                                              'null'
                                                          ? null
                                                          : '${snapshot.data[index]['documentdata']['undocument']['worklocation']}',
                                                  untime1:
                                                      '${snapshot.data[index]['documentdata']['undocument']}' ==
                                                              'null'
                                                          ? null
                                                          : '${snapshot.data[index]['documentdata']['undocument']['startuptime']}',
                                                  untime2:
                                                      '${snapshot.data[index]['documentdata']['undocument']}' ==
                                                              'null'
                                                          ? null
                                                          : '${snapshot.data[index]['documentdata']['undocument']['deliverytime']}',
                                                  unprice:
                                                      '${snapshot.data[index]['documentdata']['undocument']}' ==
                                                              'null'
                                                          ? null
                                                          : '${snapshot.data[index]['documentdata']['undocument']['price']}',
                                                  undocid:
                                                      '${snapshot.data[index]['documentdata']['undocument']}' ==
                                                              'null'
                                                          ? null
                                                          : '${snapshot.data[index]['documentdata']['undocument']['id']}',
                                                  id: '${snapshot.data[index]['documentdata']['undocument']}' ==
                                                          'null'
                                                      ? null
                                                      : '${snapshot.data[index]['documentdata']['undocument']['createrid']}',
                                                );
                                              },
                                            ));
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'More',
                                                style: wsmallts,
                                                textAlign: TextAlign.center,
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white,
                                                size: 20,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        '${snapshot.data[index]['project']}' != "null" &&
                                '${snapshot.data[index]['project']['isapprov']}' ==
                                    "${0}"
                            ? Positioned(
                                top: 20,
                                right: 20,
                                child: IconButton(
                                    onPressed: ()async {
                                      var approv =await Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) {
                                          return Download(
                                            url1:
                                                '${snapshot.data[index]['project']['fileurl']}',
                                            id: '${snapshot.data[index]['project']['id']}',
                                            buyerid:
                                                '${snapshot.data[index]['orderdata']['buyerid']}',
                                          );
                                        },
                                      ));
                                      print(approv);
                                      setState(() {});
                                      if (approv == true) {
                                        setState(() {
                                          orders = getOrders();
                                        });
                                      }
                                      setState(() {});
                                    },
                                    icon: Icon(
                                      Icons.file_download_outlined,
                                      color: maincolor,
                                    )),
                              )
                            : Text(''),
                        Positioned(
                            bottom: 30,
                            left: 40,
                            child: Row(
                              children: [
                                Text(
                                  '${snapshot.data[index]['orderdata']['status']}',
                                  style: errorts,
                                ),
                              ],
                            )),
                      ],
                    );
                  });
            } else if (snapshot.connectionState == ConnectionState.waiting) {
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
                      'No orders yet',
                      style: psubts,
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    ));
  }
}
