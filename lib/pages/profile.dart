import 'dart:convert';

import 'dart:io';
import 'dart:async';
import 'package:blurry/blurry.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/components/pricetagdesign.dart';
import 'package:servigo/db/components.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/map.dart';
import 'package:servigo/pages/post.dart';
import 'package:servigo/pages/pricetag.dart';
import 'package:servigo/pages/showposts.dart';
import 'package:servigo/pages/showworkstation.dart';
import 'package:servigo/pages/workstation.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<FormFieldState> formkey = new GlobalKey();

class Profile extends StatefulWidget {
  String i = "0";
  Profile({required this.i});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int index = 0;
  File? image;
  String? biovalue;
  var pp;
  bool bio = false;
  var distance;
  var profileimage = null;
  var rates;
  String? pimage;
  var profile;
  String? userType;
  String? sellerType;
  List? sub = [];
  var lat;
  var long;
  List<Widget> subs = [];
  List<Widget> pricing = [];
  late Future myFuture;

  deleteWorkstation(index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    http.Response response = await http.post(
        body: {'id': '${index}'},
        Uri.parse(deleteworkstation),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body = jsonDecode(response.body);
    if (body['status'] == 'failed') {
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
    } else {
      setState(() {
        myFuture = getWorkstations();
      });
      // Navigator.of(context).pop();

      // Navigator.of(context)
      // .pushNamedAndRemoveUntil('Profile', (route) => false);
    }
  }

  getWorkstations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    String? profileid = await prefs.getString('profileid');
    print(profileid);
    http.Response response = await http.get(
        Uri.parse(getworkstations + '/${profileid}'),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body = jsonDecode(response.body);
    if (body['status'] == 'success') {
      // setState(() {});
      return body['message'];
    }
  }

  getProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('usertoken');
    String? profileid = await prefs.getString('profileid');
    http.Response response = await http.get(
        Uri.parse(getprofileimage + '/${profileid}'),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    setState(() {
      pimage = (jsonDecode(response.body));
    });
  }

  getProfile() async {
    // print('ddddddddddddd');
    var body;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sellerType = await prefs.getString('sellerType');
    // print(sellerType);
    // print(sellerType);
    // print('ddddddddddddd');

    String? token = prefs.getString('usertoken');
    String? userid = await prefs.getString('userid');
    http.Response response = await http.get(
        Uri.parse('${getprofile}' + '/${userid}'),
        headers: {'Authorization': 'Bearer ${token}'});
    body = jsonDecode(response.body);
    if (!mounted) return;
    if (body['status'] == 'success') {
      setState(() {
        profile = body['message'];
        distance = profile['profiledata']['distance'];
        lat = profile['profiledata']['lat'];
        long = profile['profiledata']['long'];
        userType = '${profile['roleid']}';
        prefs.setString('userType', '${userType}');
        sub = profile['subcategorydata'];
        biovalue = profile['profiledata']['bio'];
        print(lat);
      });
      getProfileImage();
      prefs.setString('profileid', '${profile['profiledata']['id']}');
      for (int i = 0; i < sub!.length; i++) {
        setState(() {
          subs.add(Text(
            '${sub![i]['name']}',
            style: greyts,
          ));
        });
      }
      getRates();
      if (userType == "1") {
        getPricing();
        myFuture = getWorkstations();
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

  getRates() async {
    var body;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    String? profileid = await prefs.getString('profileid');
    http.Response response = await http.get(
      Uri.parse(getrates + '/${profileid}'),
      headers: {'Authorization': 'Bearer ${token}'},
    );
    if (!mounted) return;

    body = (jsonDecode(response.body));
    setState(() {
      rates = body;
    });
  }

  getPricing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');

    String? profileid = await prefs.getString('profileid');
    http.Response response = await http.get(
      Uri.parse('${getpricing}' + '/' + '${profileid}'),
      headers: {'Authorization': 'Bearer ${token}'},
    );
    var body = jsonDecode(response.body);
    if (!mounted) return;
    if (body['status'] == 'success') {
      setState(() {
        pp = body['message'];
        print('0000000000000000000000000000000000000000000000000');
        print(pp);
        print('98888888888888888888888888888888888888888');
      });
      for (int i = 0; i < body['message'].length; i++) {
        pricing.add(
          pricetagDesign(
            context,
            body['message'][i]['pricingdata']['price'] == null
                ? Text(
                    'Tell customers about the Price',
                    style: psmallts,
                  )
                : Text('${body['message'][i]['pricingdata']['price']}',
                    style: psmallts),
            Text(
              '${body['message'][i]['pricingsubcategory']['name']}',
              style: psubts,
            ),
            body['message'][i]['pricingdata']['content'] == null
                ? Text(
                    'This is the default pricetage please edit this and tell us what you are providing',
                    style: bg)
                : Text('${body['message'][i]['pricingdata']['content']}',
                    style: bg),
          ),
        );
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

  logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    String? userid = prefs.getString('userid');

    // String? apptoken = await FirebaseMessaging.instance.getToken();
    // http.Response response = await http.post(
    //   Uri.parse('${deletetoken}'),
    //   body: {'token': '${apptoken}', 'userid': '${userid}'},
    //   headers: {'Authorization': 'Bearer ${token}'},
    // );
    // print(jsonDecode(response.body)['status']);
    // if (jsonDecode(response.body)['status'] == 'success') {
      prefs.clear();
      Navigator.of(context).pushNamedAndRemoveUntil('signIn', (route) => false);
    // }
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  void initState() {
    if (widget.i == "1") {
      getPricing();
    }
    getProfile();
    myFuture = getWorkstations();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: SafeArea(
        child: SingleChildScrollView(
          child: SideMenu(
            hasResizer: false,
            minWidth: MediaQuery.of(context).size.width - 90,
            maxWidth: MediaQuery.of(context).size.width - 50,
            builder: (data) => SideMenuData(
              header: Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          width: 100,
                          height: 100,
                          child: pimage == null
                              ? CircleAvatar(
                                  backgroundColor:
                                      Color.fromARGB(93, 83, 81, 81)
                                          .withOpacity(0.4),
                                  backgroundImage:
                                      AssetImage('assets/images/user.png'),
                                )
                              : CircleAvatar(
                                  backgroundColor:
                                      Color.fromARGB(93, 83, 81, 81)
                                          .withOpacity(0.4),
                                  backgroundImage: NetworkImage("$pimage"),
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            profile == null
                                ? CircularProgressIndicator(
                                    color: maincolor,
                                  )
                                : Text(
                                    profile != null ? '${profile['name']}' : '',
                                    style: btitle,
                                  ),
                            if (userType == "1")
                              ...([
                                Text(
                                  profile != null
                                      ? '${profile['profiledata']['teamsize']}'
                                      : '',
                                  style: greyts,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: subs,
                                ),
                              ])
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              items: [
                SideMenuItemDataTile(
                  margin: EdgeInsetsDirectional.only(
                      bottom: 20, start: 10, end: 10),
                  badgeColor: Colors.white,
                  selectedColor: maincolor,
                  unSelectedColor: Colors.white,
                  isSelected: true,
                  onTap: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('Home', (route) => false);
                  },
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Image.asset(
                            'assets/images/home.png',
                            width: 15,
                          ),
                        ),
                        Text(
                          '  Home',
                          style: psmallts,
                        )
                      ],
                    ),
                  ),
                ),
                SideMenuItemDataTile(
                  margin: EdgeInsetsDirectional.only(
                      bottom: 20, start: 10, end: 10),
                  badgeColor: Colors.white,
                  selectedColor: maincolor,
                  unSelectedColor: Colors.white,
                  isSelected: true,
                  onTap: () {},
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: InkWell(
                      onTap: () async {
                        final imagepicker = await ImagePicker();
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        PickedFile? pickedfile = await imagepicker.getImage(
                            source: ImageSource.gallery);
                        if (pickedfile != null) {
                          image = File(pickedfile.path);
                          var response = await postWithFile(
                              updateprofile,
                              {'profileid': '${prefs.getString('profileid')}'},
                              image!);

                          getProfileImage();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.person,
                            size: 20,
                            color: Color.fromARGB(255, 85, 30, 152),
                          ),
                          Text(
                            ' Edit profile image',
                            style: psmallts,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SideMenuItemDataTile(
                  itemHeight: bio ? 120 : 40,
                  margin: EdgeInsetsDirectional.only(
                      bottom: 20, start: 10, end: 10),
                  badgeColor: Colors.white,
                  selectedColor: maincolor,
                  unSelectedColor: Colors.white,
                  isSelected: true,
                  onTap: () {},
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          bio = !bio;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.short_text_rounded,
                                color: Color.fromARGB(255, 85, 30, 152),
                              ),
                              Text(
                                ' Edit bio',
                                style: psmallts,
                              )
                            ],
                          ),
                          if (bio)
                            ...([
                              customField(
                                fromkey: formkey,
                                style: psmallts,
                                val: biovalue != null ? biovalue : '',
                                hint: 'Bio',
                                validator: (p0) {
                                  if (p0!.length == 0) {
                                    return 'Bio can\'t be empty';
                                  }
                                  if (p0.length > 150) {
                                    return 'Bio is too long';
                                  }
                                  if (p0.length < 50) {
                                    return 'Bio is too short';
                                  }
                                  setState(() {
                                    biovalue = p0;
                                  });
                                  return null;
                                },
                              ),
                              Container(
                                padding: EdgeInsets.only(right: 10, top: 9),
                                child: InkWell(
                                  onTap: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();

                                    if (formkey.currentState!.validate()) {
                                      var body = await updateProfile({
                                        'profileid':
                                            '${prefs.getString('profileid')}',
                                        'bio': '${biovalue}'
                                      });

                                      if (body['status'] == 'success') {
                                        Navigator.of(context).pop();
                                      } else {
                                        Blurry.error(
                                            title: 'Opps error',
                                            description:
                                                'Something went wrong please try again',
                                            confirmButtonText: 'Okay',
                                            titleTextStyle: const TextStyle(
                                                fontFamily: 'Zen'),
                                            buttonTextStyle: const TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontFamily: 'Zen'),
                                            descriptionTextStyle:
                                                const TextStyle(
                                                    fontFamily: 'Zen'),
                                            onConfirmButtonPressed: () {
                                              Navigator.of(context).pop();
                                            }).show(context);
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Done',
                                        style: psmallts,
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: maincolor,
                                        size: 15,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ])
                        ],
                      ),
                    ),
                  ),
                ),
                if (userType == "1" && lat!=null)
                  ...([
                    SideMenuItemDataTile(
                      margin: EdgeInsetsDirectional.only(
                          bottom: 20, start: 10, end: 10),
                      badgeColor: Colors.white,
                      selectedColor: maincolor,
                      unSelectedColor: Colors.white,
                      isSelected: true,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return GMap(
                              post: false,
                              lat: double.parse(lat),
                              long: double.parse(long),
                              distance: distance,
                            );
                          },
                        ));
                      },
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.social_distance_outlined,
                              size: 20,
                              color: Color.fromARGB(255, 85, 30, 152),
                            ),
                            Text(
                              ' edit distance',
                              style: psmallts,
                            )
                          ],
                        ),
                      ),
                    ),
                    SideMenuItemDataTile(
                      margin: EdgeInsetsDirectional.only(
                          bottom: 20, start: 10, end: 10),
                      badgeColor: Colors.white,
                      selectedColor: maincolor,
                      unSelectedColor: Colors.white,
                      isSelected: true,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return GMap(
                              post: false,
                              lat: double.parse(lat),
                              long: double.parse(long),
                              distance: distance,
                            );
                          },
                        ));
                      },
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: Color.fromARGB(255, 85, 30, 152),
                            ),
                            Text(
                              ' Edit location',
                              style: psmallts,
                            )
                          ],
                        ),
                      ),
                    ),
                  ]),
                if (userType == "1")
                  ...([
                    SideMenuItemDataTile(
                      margin: EdgeInsetsDirectional.only(
                          bottom: 20, start: 10, end: 10),
                      badgeColor: Colors.white,
                      selectedColor: maincolor,
                      unSelectedColor: Colors.white,
                      isSelected: true,
                      onTap: () {},
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return Workstation(subcategories: sub!);
                              },
                            ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.workspaces_filled,
                                size: 20,
                                color: Color.fromARGB(255, 85, 30, 152),
                              ),
                              Text(
                                ' New workstation',
                                style: psmallts,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                SideMenuItemDataTile(
                  margin: EdgeInsetsDirectional.only(
                      bottom: 20, start: 10, end: 10),
                  badgeColor: Colors.white,
                  selectedColor: maincolor,
                  unSelectedColor: Colors.white,
                  isSelected: true,
                  onTap: () {},
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return Post();
                          },
                        ));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.photo_size_select_actual,
                            size: 20,
                            color: Color.fromARGB(255, 85, 30, 152),
                          ),
                          Text(
                            ' New post',
                            style: psmallts,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SideMenuItemDataTile(
                  margin: EdgeInsetsDirectional.only(
                      bottom: 20, start: 10, end: 10),
                  badgeColor: Colors.white,
                  selectedColor: maincolor,
                  unSelectedColor: Colors.white,
                  isSelected: true,
                  onTap: () {},
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: InkWell(
                      onTap: () async {
                        logOut();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.logout_outlined,
                            size: 20,
                            color: Color.fromARGB(255, 85, 30, 152),
                          ),
                          Text(
                            ' Logout',
                            style: psmallts,
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
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(border_rad_size),
            bottomRight: Radius.circular(border_rad_size),
          ),
        ),
        toolbarHeight: 70,
        elevation: 0,
        backgroundColor: maincolor,
        // leading: widget.leading,
        title: InkWell(
          child: Row(
            children: [
              Image.asset(
                'assets/images/bell.png',
                width: 20,
              ),
              Text(
                ' Latest notifications',
                style: wsmallts,
              ),
            ],
          ),
          onTap: () {},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              child: Image.asset(
                'assets/images/list.png',
                width: 20,
              ),
              onTap: () {
                scaffoldKey.currentState!.openEndDrawer();
              },
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        width: 100,
                        height: 100,
                        child: pimage == null
                            ? CircleAvatar(
                                backgroundColor: Color.fromARGB(93, 83, 81, 81)
                                    .withOpacity(0.4),
                                backgroundImage:
                                    AssetImage('assets/images/user.png'),
                              )
                            : CircleAvatar(
                                backgroundColor: Color.fromARGB(93, 83, 81, 81)
                                    .withOpacity(0.4),
                                backgroundImage: NetworkImage("$pimage"),
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          profile == null
                              ? CircularProgressIndicator(
                                  color: maincolor,
                                )
                              : Text(
                                  profile != null ? '${profile['name']}' : '',
                                  style: btitle,
                                ),
                          if (userType == "1")
                            ...([
                              Text(
                                profile != null
                                    ? '${profile['profiledata']['teamsize']}'
                                    : '',
                                style: greyts,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: subs,
                              ),
                            ])
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 30, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bio',
                      style: bsubts,
                    ),
                    Text(
                      biovalue != null
                          ? '${biovalue}'
                          : 'Tell people about yourself',
                      style: greyts,
                    ),
                  ],
                ),
              ),

              distance != null 
                  ? Container(
                      margin: EdgeInsets.only(top: 30, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance',
                            style: bsubts,
                          ),
                          distance != null
                              ? Text(
                                  '${profile['profiledata']['distance']} km',
                                  style: greyts,
                                )
                              : Text(
                                  '',
                                  style: greyts,
                                ),
                        ],
                      ),
                    )
                  : Text(''),
              Container(
                margin: EdgeInsets.only(top: 40),
                alignment: Alignment.topLeft,
                child: Wrap(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (userType == "1")
                          ...([
                            Card(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    widget.i = "0";
                                    index = 0;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 5),
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 8,
                                  child: Text(
                                    'Workstation',
                                    style: bsmallts,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Card(
                                child: InkWell(
                              onTap: () {
                                setState(() {
                                  widget.i = "1";

                                  index = 1;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 5),
                                width: MediaQuery.of(context).size.width / 4,
                                height: MediaQuery.of(context).size.width / 8,
                                child: Text(
                                  'Pricing',
                                  style: bsmallts,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )),
                          ]),
                        Card(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                    return showPosts(posts: false);
                                  },
                                ));
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 5),
                              width: MediaQuery.of(context).size.width / 4,
                              height: MediaQuery.of(context).size.width / 8,
                              child: Text(
                                'Posts',
                                style: bsmallts,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (userType == "1")
                ...([
                  widget.i == "0"
                      ? Container(
                          margin: EdgeInsets.only(top: 40, left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'workstation',
                                style: bsubts,
                              ),
                              Text(
                                'show people your work',
                                style: greyts,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                height: MediaQuery.of(context).size.height / 6,
                                child: FutureBuilder(
                                    future: myFuture,
                                    builder: (context, AsyncSnapshot snapshot) {
                                      if (snapshot.hasData) {
                                        return ListView.builder(
                                          physics: BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (context, index) {
                                            return FocusedMenuHolder(
                                              openWithTap: true,
                                              onPressed: () {},
                                              menuItems: <FocusedMenuItem>[
                                                FocusedMenuItem(
                                                  title: Text(
                                                    'show',
                                                    style: bsmallts,
                                                  ),
                                                  trailingIcon: Icon(
                                                    Icons.slideshow_rounded,
                                                    size: 22,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                      builder: (context) {
                                                        return showWorkstation(
                                                          workstation: snapshot
                                                              .data[index],
                                                        );
                                                      },
                                                    ));
                                                  },
                                                ),
                                                FocusedMenuItem(
                                                  title: Text(
                                                    'create',
                                                    style: bsmallts,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                      builder: (context) {
                                                        return Workstation(
                                                            subcategories:
                                                                sub!);
                                                      },
                                                    ));
                                                  },
                                                  trailingIcon: Icon(
                                                    Icons.create,
                                                    size: 22,
                                                  ),
                                                ),
                                                FocusedMenuItem(
                                                  title: Text(
                                                    'update',
                                                    style: bsmallts,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                      builder: (context) {
                                                        return Workstation(
                                                            wk: snapshot
                                                                .data[index],
                                                            subcategories:
                                                                sub!);
                                                      },
                                                    ));
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
                                                    deleteWorkstation(snapshot
                                                                .data[index]
                                                            ['workstationdata']
                                                        ['id']);
                                                  },
                                                )
                                              ],
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          '$serverlink' +
                                                              '/storage/' +
                                                              '${snapshot.data[index]['image']}'),
                                                      fit: BoxFit.cover),
                                                  color: Color.fromARGB(
                                                          93, 83, 81, 81)
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          border_rad_size),
                                                ),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    6,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                              )
                                              //  Container(
                                              //     decoration:
                                              //         BoxDecoration(
                                              //       image: DecorationImage(
                                              //           image: AssetImage("assets/images/google.png"
                                              //               ),
                                              //           fit: BoxFit
                                              //               .cover),
                                              //       color: Color
                                              //               .fromARGB(
                                              //                   93,
                                              //                   83,
                                              //                   81,
                                              //                   81)
                                              //           .withOpacity(
                                              //               0.4),
                                              //       borderRadius:
                                              //           BorderRadius
                                              //               .circular(
                                              //                   border_rad_size),
                                              //     ),
                                              //     width: MediaQuery.of(
                                              //                 context)
                                              //             .size
                                              //             .height /
                                              //         6,
                                              //     margin: EdgeInsets
                                              //         .symmetric(
                                              //             horizontal:
                                              //                 10),
                                              //   )
                                              ,
                                            );
                                          },
                                        );
                                      } else if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator(
                                          color: maincolor,
                                        ));
                                      } else {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/images/planet.png',
                                                height: 100,
                                                width: 100,
                                              ),
                                              Text(
                                                'No workstations yet',
                                                style: psubts,
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                    }),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 40, left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'pricing your service',
                                style: bsubts,
                              ),
                              Text(
                                'tell people about your services and their prices',
                                style: bg,
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child:
                                      Divider(color: Colors.grey, height: 1)),
                              pricing == null
                                  ? CircularProgressIndicator(
                                      color: maincolor,
                                    )
                                  : Container(
                                      margin: EdgeInsets.only(top: 9),
                                      alignment: Alignment.topLeft,
                                      width: MediaQuery.of(context).size.width,
                                      height: 20,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: sub!.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20),
                                            child: InkWell(
                                                onTap: () {
                                                  setState(() {});
                                                },
                                                child: subs[index]),
                                          );
                                        },
                                      ),
                                    ),
                              pp != null
                                  ? Container(
                                      margin: EdgeInsets.only(top: 20),
                                      height:
                                          MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        itemCount: sub!.length,
                                        itemBuilder: (context, index) {
                                          return FocusedMenuHolder(
                                            bottomOffsetHeight: 200,
                                            openWithTap: true,
                                            onPressed: () {},
                                            menuItems: <FocusedMenuItem>[
                                              FocusedMenuItem(
                                                backgroundColor: maincolor,
                                                title: Text(
                                                  'update',
                                                  style: wsmallts,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return priceTag(
                                                          pricingdata:
                                                              pp[index],
                                                        );
                                                      },
                                                    ),
                                                  );
                                                  ;
                                                },
                                                trailingIcon: Icon(
                                                  Icons.update,
                                                  size: 22,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                            child: Container(
                                              margin: EdgeInsets.only(top: 20),
                                              alignment: Alignment.topLeft,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.4,
                                              child: pricing[index],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: CircularProgressIndicator(
                                      color: maincolor,
                                    ))
                            ],
                          ),
                        )
                ])
              // Container(
              //   margin: EdgeInsets.only(top: 9),
              //   alignment: Alignment.topLeft,
              //   width: MediaQuery.of(context).size.width,
              //   height: MediaQuery.of(context).size.height,
              //   child: ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: sub!.length,
              //     itemBuilder: (context, index) {
              //       return Padding(
              //           padding: const EdgeInsets.only(right: 20),
              //           child: Container(
              //               margin: EdgeInsets.only(top: 20),
              //               width: double.infinity,
              //               child: FocusedMenuHolder(
              //                 child: Text('kkkkkkkkkkkk'),
              // child: Container(
              //   alignment: Alignment.topLeft,
              //   width: MediaQuery.of(context)
              //           .size
              //           .width /
              //       1.4,
              //   child: pricetagDesign(
              //     context,
              //     Text(
              //       'starts at 6700 S.P',
              //       style: greyts,
              //     ),
              //     Text(
              //       'Flutter',
              //       style: bsmallts,
              //     ),
              //     Text(
              //       '''I am a talented developer based in Syria, with a passion for creating innovative solutions using Flutter, PHP, and WordPress. Outside of work, I am an extroverted individual who loves to connect with people and enjoys the simple pleasures of life. I believe that my positive outlook on life and my attention to detail are what make me successful in both my personal and professional endeavors.''',
              //       style: bg,
              //     ),
              //   ),
              // ),
              //                 onPressed: () {},
              //                 menuItems: <FocusedMenuItem>[
              //                   FocusedMenuItem(
              //                     title: Text(
              //                       'create',
              //                       style: bsmallts,
              //                     ),
              //                     onPressed: () {
              //                       Navigator.of(context)
              //                           .push(MaterialPageRoute(
              //                         builder: (context) {
              //                           return priceTag(
              //                               subcategories: sub!);
              //                         },
              //                       ));
              //                     },
              //                     trailingIcon: Icon(
              //                       Icons.create,
              //                       size: 22,
              //                     ),
              //                   ),
              //                   FocusedMenuItem(
              //                     title: Text(
              //                       'update',
              //                       style: bsmallts,
              //                     ),
              //                     onPressed: () {
              //                       Navigator.of(context)
              //                           .pushNamed('priceTag');
              //                     },
              //                     trailingIcon: Icon(
              //                       Icons.update,
              //                       size: 22,
              //                     ),
              //                   ),
              //                   FocusedMenuItem(
              //                     backgroundColor: errorcolor,
              //                     title: Text(
              //                       'delete',
              //                       style: wsmallts,
              //                     ),
              //                     trailingIcon: Icon(
              //                       Icons.delete,
              //                       size: 22,
              //                       color: Colors.white,
              //                     ),
              //                     onPressed: () {},
              //                   )
              //                 ],
              //               )));
              //     },
              //   ),
              // ),
              // ListView.builder(
              //   itemCount: sub!.length,
              //   itemBuilder: (context, index) {
              //     return Container(
              //       margin: EdgeInsets.only(top: 20),
              //       width: double.infinity,
              //       child: FocusedMenuHolder(
              //         onPressed: () {},
              //         menuItems: <FocusedMenuItem>[
              //           FocusedMenuItem(
              //             title: Text(
              //               'create',
              //               style: bsmallts,
              //             ),
              //             onPressed: () {
              //               Navigator.of(context)
              //                   .push(MaterialPageRoute(
              //                 builder: (context) {
              //                   return priceTag(
              //                       subcategories: sub!);
              //                 },
              //               ));
              //             },
              //             trailingIcon: Icon(
              //               Icons.create,
              //               size: 22,
              //             ),
              //           ),
              //           FocusedMenuItem(
              //             title: Text(
              //               'update',
              //               style: bsmallts,
              //             ),
              //             onPressed: () {
              //               Navigator.of(context)
              //                   .pushNamed('priceTag');
              //             },
              //             trailingIcon: Icon(
              //               Icons.update,
              //               size: 22,
              //             ),
              //           ),
              //           FocusedMenuItem(
              //             backgroundColor: errorcolor,
              //             title: Text(
              //               'delete',
              //               style: wsmallts,
              //             ),
              //             trailingIcon: Icon(
              //               Icons.delete,
              //               size: 22,
              //               color: Colors.white,
              //             ),
              //             onPressed: () {},
              //           )
              //         ],
              //         child: Container(
              //           alignment: Alignment.topLeft,
              //           width:
              //               MediaQuery.of(context).size.width / 1.4,
              //           child: pricetagDesign(
              //             context,
              //             Text(
              //               'starts at 6700 S.P',
              //               style: greyts,
              //             ),
              //             Text(
              //               'Flutter',
              //               style: bsmallts,
              //             ),
              //             Text(
              //               '''I am a talented developer based in Syria, with a passion for creating innovative solutions using Flutter, PHP, and WordPress. Outside of work, I am an extroverted individual who loves to connect with people and enjoys the simple pleasures of life. I believe that my positive outlook on life and my attention to detail are what make me successful in both my personal and professional endeavors.''',
              //               style: bg,
              //             ),
              //           ),
              //         ),
              //       ),
              //     );
              //   },
              // ),
              // : Container(
              //     margin: EdgeInsets.only(top: 20),
              //     width: double.infinity,
              //     child: FocusedMenuHolder(
              //       onPressed: () {},
              //       menuItems: <FocusedMenuItem>[
              //         FocusedMenuItem(
              //           title: Text(
              //             'create',
              //             style: bsmallts,
              //           ),
              //           onPressed: () {
              //             Navigator.of(context).push(MaterialPageRoute(
              //               builder: (context) {
              //                 return priceTag(subcategories: sub!);
              //               },
              //             ));
              //           },
              //           trailingIcon: Icon(
              //             Icons.create,
              //             size: 22,
              //           ),
              //         ),
              //         FocusedMenuItem(
              //           title: Text(
              //             'upttdate',
              //             style: bsmallts,
              //           ),
              //           onPressed: () {
              //             Navigator.of(context).push(MaterialPageRoute(
              //               builder: (context) {
              //                 return priceTag(
              //                   subcategories: sub!,
              //                   pricingid: 13,
              //                 );
              //               },
              //             ));
              //           },
              //           trailingIcon: Icon(
              //             Icons.update,
              //             size: 22,
              //           ),
              //         ),
              //         FocusedMenuItem(
              //           backgroundColor: errorcolor,
              //           title: Text(
              //             'delete',
              //             style: wsmallts,
              //           ),
              //           trailingIcon: Icon(
              //             Icons.delete,
              //             size: 22,
              //             color: Colors.white,
              //           ),
              //           onPressed: () {},
              //         )
              //       ],
              //       child: Container(
              //         alignment: Alignment.topLeft,
              //         width: MediaQuery.of(context).size.width / 1.4,
              //         child: pricetagDesign(
              //           context,
              //           Text(
              //             'starts at 6700 S.P',
              //             style: greyts,
              //           ),
              //           Text(
              //             'Flutter',
              //             style: bsmallts,
              //           ),
              //           Text(
              //             '''I am a talented developer based in Syria, with a passion for creating innovative solutions using Flutter, PHP, and WordPress. Outside of work, I am an extroverted individual who loves to connect with people and enjoys the simple pleasures of life. I believe that my positive outlook on life and my attention to detail are what make me successful in both my personal and professional endeavors.''',
              //             style: bg,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }
}
                        
                    
                    
              // index == 0
              //     ? Container(
              //         margin: EdgeInsets.only(top: 30, left: 10),
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'My rates',
              //               style: bsubts,
              //             ),
              //             rates != null
              //                 ? StreamBuilder(
              //                     stream: rates.snapshots(),
              //                     builder: (context, AsyncSnapshot snapshot) {
              //                       if (snapshot.connectionState ==
              //                           ConnectionState.waiting) {
              //                         return CircularProgressIndicator(
              //                           color: maincolor,
              //                         );
              //                       } else {
              //                         return Text('');
              //                       }
              //                     },
              //                   )
              //                 : Text('')
              //           ],
              //         ),
              //       )
              //     : Text('')
            // ],
          // ),
        // ),
      

