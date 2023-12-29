import 'dart:convert';
import 'package:blurry/blurry.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servigo/admin/Admin.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/mediator/meditor.dart';
import 'package:servigo/pages/profile.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class signIn extends StatefulWidget {
  const signIn({Key? key}) : super(key: key);

  @override
  State<signIn> createState() => _signInState();
}

class _signInState extends State<signIn> {
  String email = '';
  String password = '';
  GlobalKey<FormState> formkey = new GlobalKey();

  bool showpassword = true;
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  signin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (formkey.currentState!.validate()) {
      Map data = {'email': email, 'password': password};
      http.Response response =
          await http.post(Uri.parse(signinurl), body: data);
      var body = jsonDecode(response.body);
      print(body);
      if (body['status'] == 'success') {
        prefs.setString('userid', body['userid']);
        prefs.setString('userType', body['roleid']);
        prefs.setString('usertoken', body['token']);
        http.Response r = await http.post(
          Uri.parse(addapptoken),
          body: {
            'token': '${await FirebaseMessaging.instance.getToken()}',
            'userid': '${body['userid']}'
          },
          headers: {'Authorization': 'Bearer ${body['token']}'},
        );
        String? rolid = await prefs.getString('userType');
        print(rolid);
        print('0000000000000000000000000000000000000000000000000000000');
        if (int.parse(rolid!) == 3) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              return Mediator();
            },
          ));
        } else if (int.parse(rolid) == 4) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              return Admin();
            },
          ));
        } else {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) {
              return Profile(i: "0");
            },
          ), (route) => false);
        }
      } else if (body['status'] == 'failed') {
        Blurry.error(
            title: 'Opps error',
            description: body['message']['email'] != null
                ? 'Email is not found'
                : 'Password is wrong',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(7),
                bottomRight: Radius.circular(7),
              ),
              gradient: LinearGradient(
                  colors: [maincolor, maincolor1, maincolor],
                  begin: Alignment.bottomLeft),
            ),
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2.5,
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'SERVIGO',
                    style: wmaints,
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 10,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('signUp', (route) => false);
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Text(
                            'signup',
                            style: wsubts,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.transparent.withOpacity(0.4),
              ),
            ),
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 4 + 10,
                left: 10,
                right: 10),
            child: SingleChildScrollView(
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Welcome back!!',
                        style: psubts,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(top: 20),
                      child: customField(
                        validator: (p0) {
                          if (p0!.isNotEmpty) {
                            if (!RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(p0)) {
                              return 'Email format is wrong';
                            }
                            setState(() {
                              email = p0;
                            });
                          } else
                            return 'Email can\'t be empty';
                          return null;
                        },
                        hint: 'Email',
                      ),
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(top: 20),
                      child: customField(
                        validator: (p0) {
                          if (p0!.isNotEmpty) {
                            if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$')
                                    .hasMatch(p0) ||
                                p0.length < 6) {
                              return 'password format is wrong';
                            }
                            setState(() {
                              password = p0;
                            });
                          } else
                            return 'password can\'t be empty';
                          return null;
                        },
                        hint: 'Password',
                        iconbtn: IconButton(
                          onPressed: () {
                            setState(() {
                              showpassword = !showpassword;
                            });
                          },
                          icon: !showpassword
                              ? Icon(
                                  Icons.remove_red_eye,
                                  color: maincolor,
                                )
                              : Icon(
                                  Icons.visibility_off_sharp,
                                  color: Colors.transparent.withOpacity(.4),
                                ),
                        ),
                        showpassword: showpassword,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 7, top: 5, bottom: 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Forgot password?',
                        style: psmallts,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      alignment: Alignment.center,
                      width: 160,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [maincolor, maincolor1, maincolor],
                            begin: Alignment.bottomLeft),
                        borderRadius: BorderRadius.circular(border_rad_size),
                      ),
                      child: InkWell(
                        onTap: () {
                          signin();
                        },
                        child: Text(
                          'SignIn',
                          textAlign: TextAlign.center,
                          style: wsubts,
                        ),
                      ),
                    ),
                    Divider(
                      color: Color.fromARGB(125, 0, 0, 0).withOpacity(0.4),
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'signIn with',
                              style: psmallts,
                              textAlign: TextAlign.center,
                            ),
                            Image.asset(
                              'assets/images/google.png',
                              width: 50,
                              height: 40,
                            )
                          ],
                        ),
                      ),
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
