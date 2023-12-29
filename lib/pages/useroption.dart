import 'dart:convert';

import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_custom_selector/widget/flutter_multi_select.dart';
import 'package:flutter_custom_selector/widget/flutter_single_select.dart';
import 'package:servigo/categories/categories.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/map.dart';
import 'package:servigo/pages/profile.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userOption extends StatefulWidget {
  const userOption({Key? key}) : super(key: key);

  @override
  State<userOption> createState() => _userOptionState();
}

class _userOptionState extends State<userOption> {
  var servicetypes;
  var maincategories;
  var subcategories;
  List<String> stnames = [];
  List<String> mcnames = [];
  List<String> scnames = [];
  var ids = [];
  int mainnum = 0;
  int subnum = 0;
  void initState() {
    super.initState();
    servicetypesnames();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  addProfile() async {
    if (mainnum > 1 || mainnum == 0 || subnum > 2 || subnum == 0) {
      Blurry.error(
          title: 'Opps error',
          description:
              'Please choose one main category and at most two sub categories',
          confirmButtonText: 'Okay',
          titleTextStyle: const TextStyle(fontFamily: 'Zen'),
          buttonTextStyle: const TextStyle(
              decoration: TextDecoration.underline, fontFamily: 'Zen'),
          descriptionTextStyle: const TextStyle(fontFamily: 'Zen'),
          onConfirmButtonPressed: () {
            Navigator.of(context).pop();
          }).show(context);
    } else {
      ids = ids.toSet().toList();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userid = prefs.getString('userid');
      String? token = prefs.getString('usertoken');
      Map data = {'userid': '${userid}', 'roleid': '${1}'};
      http.Response response =
          await http.post(Uri.parse(upgradeuser), body: data);
      var body = jsonDecode(response.body);
      print(body);
      if (body['status'] == 'success') {
        // prefs.setString('profileid', body['profileid']);

        ids.length == 1
            ? data = {
                'teamsize': '${teamsize}',
                'userid': '${userid}',
                'subcategories[0]': '${ids[0]}',
              }
            : data = {
                'teamsize': '${teamsize}',
                'userid': '${userid}',
                'subcategories[0]': '${ids[0]}',
                'subcategories[1]': '${ids[1]}',
              };
        response = await http.post(Uri.parse(addprofile), body: data, headers: {
          'Authorization': 'Bearer $token',
        });
        // print(jsonDecode(response.body));
        body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          prefs.setString('profileid', body['profileid']);
          print(prefs.getString('profileid'));
          prefs.setString('sellerType', techval ? "tech" : "hum");
          print(prefs.getString('sellerType'));

          techval == false
              ? Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                  builder: (context) {
                    return GMap(post: false,);
                  },
                ), (route) => false)
              : Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                  builder: (context) {
                    return Profile(
                      i: "0",
                    );
                  },
                ), (route) => false);
        } else {
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
      } else {
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
  }

  servicetypesnames() async {
    servicetypes = await getServiceTypes();

    if (servicetypes != null) {
      maincategories = await getMainCategories();
      if (maincategories != null) {
        subcategories = await getsubCategories();
      }
      for (int i = 0; i < servicetypes.length; i++) {
        stnames.add(servicetypes[i]['name']);
      }
    }
  }

  maincategoriesname(value) async {
    if (maincategories != null) {
      for (int i = 0; i < maincategories['message'].length; i++) {
        if (maincategories['message'][i]['servicetypedata']['name'] == value) {
          setState(() {
            mcnames
                .add(maincategories['message'][i]['maincategorydata']['name']);
          });
        }
      }
    }
  }

  subcategoriesname(value) async {
    if (subcategories != null && value.length > 0) {
      for (int i = 0; i < subcategories['message'].length; i++) {
        if (subcategories['message'][i]['maincategorydata']['name'] ==
            value[0]) {
          setState(() {
            scnames.add(subcategories['message'][i]['subcategorydata']['name']);
          });
        }
      }
    }
  }

  getsubids(value) {
    if (subcategories != null) {
      for (int i = 0; i < value.length; i++) {
        for (int j = 0; j < subcategories['message'].length; j++) {
          if (value[i] ==
              subcategories['message'][j]['subcategorydata']['name']) {
            setState(() {
              ids.add(subcategories['message'][j]['subcategorydata']['id']);
            });
          }
        }
      }
    }
  }

  String? teamsize;
  bool seller = false;
  bool techval = false;
  bool single = false;
  int sublen = 0;
  int mainlen = 0;
  bool stype = false;

  var selectedString;
  var selectedStringm;
  void _onCountriesSelectionComplete(value) {
    if (value.length > 2) {
      Blurry.error(
          title: 'Opps error',
          description: 'you can\'t choose more than two please choose again',
          confirmButtonText: 'Okay',
          titleTextStyle: const TextStyle(fontFamily: 'Zen'),
          buttonTextStyle: const TextStyle(
              decoration: TextDecoration.underline, fontFamily: 'Zen'),
          descriptionTextStyle: const TextStyle(fontFamily: 'Zen'),
          onConfirmButtonPressed: () {
            Navigator.of(context).pop();
          }).show(context);
    }
    setState(() {
      subnum = value.length;
    });

    getsubids(value);
  }

  void _onCountriesSelectionCompletem(value) {
    if (value.length > 1) {
      Blurry.error(
          title: 'Opps error',
          description: 'You can\'t choose more than one please choose again',
          confirmButtonText: 'Okay',
          titleTextStyle: const TextStyle(fontFamily: 'Zen'),
          buttonTextStyle: const TextStyle(
              decoration: TextDecoration.underline, fontFamily: 'Zen'),
          descriptionTextStyle: const TextStyle(fontFamily: 'Zen'),
          onConfirmButtonPressed: () {
            Navigator.of(context).pop();
          }).show(context);
    }
    setState(() {
      scnames.clear();
      mainnum = value.length;
      subcategoriesname(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(border_rad_size),
            bottomRight: Radius.circular(border_rad_size),
          ),
        ),
        backgroundColor: maincolor,
        toolbarHeight: MediaQuery.of(context).size.height / 4,
        title: Container(
          alignment: Alignment.center,
          width: double.infinity,
          child: Text(
            'Identify yourself',
            style: wmaints,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.topLeft,
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 4,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
            // ignore: sort_child_properties_last
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you a seller?',
                      style: bsubts,
                      textAlign: TextAlign.left,
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 3),
                      child: Text(
                        'Click seller button if you want to sell services',
                        style: greyts,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: maincolor.withOpacity(0.4),
                          ),
                          borderRadius: BorderRadius.circular(border_rad_size),
                          color: seller ? maincolor : Colors.white,
                        ),
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              seller = !seller;
                            });
                          },
                          child: Text(
                            'Seller',
                            style: seller ? wsmallts : psmallts,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        alignment: Alignment.center,
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(border_rad_size),
                            color: maincolor),
                        child: InkWell(
                          child: Text(
                            'Buyer',
                            style: wsmallts,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.transparent.withOpacity(0.4),
              ),
              borderRadius: BorderRadius.circular(border_rad_size),
              color: Colors.white,
            ),
          ),
          seller
              ? Container(
                  alignment: Alignment.topLeft,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 4,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  // ignore: sort_child_properties_last
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Are you a group?',
                            style: bsubts,
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 3),
                            child: Text(
                              'Size of the service depends on size of the group',
                              style: greyts,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 10),
                        child: CustomSingleSelectField<String>(
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: maincolor,
                            ),
                            label: Text(
                              'team size',
                              style: psmallts,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: maincolor),
                              borderRadius:
                                  BorderRadius.circular(border_rad_size),
                            ),
                          ),
                          selectedItemColor: maincolor,
                          items: [
                            'Single seller',
                            'Group Seller',
                          ],
                          title: "Team size",
                          onSelectionDone: (value) {
                            setState(() {
                              teamsize = value;
                            });
                          },
                          itemAsString: (item) => item,
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.transparent.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(border_rad_size),
                    color: Colors.white,
                  ),
                )
              : Container(),
          seller
              ? Container(
                  alignment: Alignment.topLeft,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 4,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.transparent.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(border_rad_size),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What type of services do you sell?',
                        style: bsubts,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 3),
                        child: Text(
                          'Choose type of service',
                          style: greyts,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 10),
                        child: Column(
                          children: [
                            CustomSingleSelectField<String>(
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: maincolor,
                                ),
                                label: Text(
                                  'service type',
                                  style: psmallts,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: maincolor),
                                  borderRadius:
                                      BorderRadius.circular(border_rad_size),
                                ),
                              ),
                              selectedItemColor: maincolor,
                              items: stnames,
                              title: "Type of service",
                              onSelectionDone: (value) {
                                setState(() {
                                  mcnames.clear();
                                  scnames.clear();

                                  stype = true;
                                  if (value == 'Technical services') {
                                    setState(() {
                                      techval = true;
                                    });
                                  } else {
                                    techval = false;
                                  }
                                });
                                maincategoriesname(value);
                              },
                              itemAsString: (item) => item,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
          seller & techval & stype
              ? Container(
                  alignment: Alignment.topLeft,
                  width: double.infinity,
                  // height: MediaQuery.of(context).size.height / 3,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.transparent.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(border_rad_size),
                    color: Colors.white,
                  ),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What type of technical services do you sell?',
                          style: bsubts,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 3, bottom: 10),
                          child: Text(
                            'Choose category',
                            style: greyts,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: CustomMultiSelectField<String>(
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: maincolor,
                              ),
                              label: Text(
                                'main category',
                                style: psmallts,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: maincolor),
                                borderRadius:
                                    BorderRadius.circular(border_rad_size),
                              ),
                            ),
                            selectedItemColor: maincolor,
                            items: mcnames,
                            title: "main category",
                            onSelectionDone: _onCountriesSelectionCompletem,
                            itemAsString: (item) => item.toString(),
                          ),
                        ),
                        (scnames.length != 0)
                            ? Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: CustomMultiSelectField<String>(
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: maincolor,
                                    ),
                                    label: Text(
                                      'sub category',
                                      style: psmallts,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: maincolor),
                                      borderRadius: BorderRadius.circular(
                                          border_rad_size),
                                    ),
                                  ),
                                  selectedItemColor: maincolor,
                                  items: scnames,
                                  title: "sub category",
                                  onSelectionDone:
                                      _onCountriesSelectionComplete,
                                  itemAsString: (item) => item.toString(),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                )
              : Container(),
          seller & !techval & stype
              ? Container(
                  alignment: Alignment.topLeft,
                  width: double.infinity,
                  // height: MediaQuery.of(context).size.height / 3,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.transparent.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(border_rad_size),
                    color: Colors.white,
                  ),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What type of human services do you sell?',
                          style: bsubts,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 3, bottom: 10),
                          child: Text(
                            'Choose category',
                            style: greyts,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: CustomMultiSelectField<String>(
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: maincolor,
                              ),
                              label: Text(
                                'main category',
                                style: psmallts,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: maincolor),
                                borderRadius:
                                    BorderRadius.circular(border_rad_size),
                              ),
                            ),
                            selectedItemColor: maincolor,
                            items: mcnames,
                            title: "main category",
                            onSelectionDone: _onCountriesSelectionCompletem,
                            itemAsString: (item) => item.toString(),
                          ),
                        ),
                        (scnames.length != 0)
                            ? Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: CustomMultiSelectField<String>(
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: maincolor,
                                    ),
                                    label: Text(
                                      'sub category',
                                      style: psmallts,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: maincolor),
                                      borderRadius: BorderRadius.circular(
                                          border_rad_size),
                                    ),
                                  ),
                                  selectedItemColor: maincolor,
                                  items: scnames,
                                  title: "sub category",
                                  onSelectionDone:
                                      _onCountriesSelectionComplete,
                                  itemAsString: (item) => item.toString(),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                )
              : Container(),
          !seller
              ? Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height / 5,
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(border_rad_size),
                    border: Border.all(
                      color: Colors.transparent.withOpacity(0.4),
                    ),
                  ),
                  child: Wrap(
                    children: [
                      Center(
                        child: Text(
                          'Thank you for choosing servigo click next to start buying the best services and communicate with different sellers.',
                          style: bsmallts,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? userid = prefs.getString('userid');
                            String? token = prefs.getString('usertoken');

                            Map data = {
                              'userid': '${userid}',
                            };

                            http.Response response = await http.post(
                                Uri.parse(addprofile),
                                body: data,
                                headers: {
                                  'Authorization': 'Bearer $token',
                                });
                            var body = jsonDecode(response.body);
                            if (body['status'] == 'success') {
                              prefs.setString('profileid', body['profileid']);

                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  'Home', (route) => false);
                            } else {
                              Blurry.error(
                                  title: 'Opps error',
                                  description:
                                      'Something went wrong please try again',
                                  confirmButtonText: 'Okay',
                                  titleTextStyle:
                                      const TextStyle(fontFamily: 'Zen'),
                                  buttonTextStyle: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontFamily: 'Zen'),
                                  descriptionTextStyle:
                                      const TextStyle(fontFamily: 'Zen'),
                                  onConfirmButtonPressed: () {
                                    Navigator.of(context).pop();
                                  }).show(context);
                            }
                          },
                          child: Container(
                            height: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Next',
                                  style: psubts,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: maincolor,
                                  size: 19,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(bottom: 30, right: 30),
                  alignment: Alignment.bottomRight,
                  child: Container(
                    alignment: Alignment.center,
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: maincolor.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(border_rad_size),
                      color: maincolor,
                    ),
                    child: InkWell(
                      onTap: () async {
                        if (teamsize != null && ids.length != 0) {
                          await addProfile();
                        } else {
                          Blurry.error(
                              title: 'Opps error',
                              description: 'Fields are required',
                              confirmButtonText: 'Okay',
                              titleTextStyle:
                                  const TextStyle(fontFamily: 'Zen'),
                              buttonTextStyle: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontFamily: 'Zen'),
                              descriptionTextStyle:
                                  const TextStyle(fontFamily: 'Zen'),
                              onConfirmButtonPressed: () {
                                Navigator.of(context).pop();
                              }).show(context);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: wsmallts,
                            textAlign: TextAlign.center,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
