import 'dart:convert';

import 'package:blurry/blurry.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class signUp extends StatefulWidget {
  const signUp({Key? key}) : super(key: key);

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  bool showpassword = true;
  String email = '';
  String name = '';
  String password = '';
  int role = 2;

  GlobalKey<FormState> formkey = new GlobalKey();
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  signup() async {
    var body;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (formkey.currentState!.validate()) {
      Map data = {
        'name': name,
        'email': email,
        'password': password,
        'roleid': '${role}'
      };
      http.Response response = await http.post(
        Uri.parse(signupurl),
        body: data,
      );

      body = jsonDecode(response.body);

      print(body);
      if (body['status'] == 'success') {
        await prefs.setString('userid', body['userid']);
        await prefs.setString('usertoken', body['token']);
        http.Response r = await http.post(
          Uri.parse(addapptoken),
          body: {
            'token': '${await FirebaseMessaging.instance.getToken()}',
            'userid': '${body['userid']}'
          },
          headers: {'Authorization': 'Bearer ${body['token']}'},
        );
        print(jsonDecode(r.body));
        Navigator.of(context)
            .pushNamedAndRemoveUntil('userOption', (route) => false);
      } else if (body['status'] == 'failed') {
        Blurry.error(
            title: 'Opps error',
            description: body['message']['name'] != null
                ? 'Name has already been taking'
                : 'Email has already been taking',
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
              // color: maincolor
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
                  left: 10,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('signIn', (route) => false);
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                                size: 20,
                                color: Colors.white,
                              ),
                              Text(
                                'signin',
                                style: wsubts,
                              ),
                            ],
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
                        'Create an account',
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
                                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$')
                                .hasMatch(p0)) {
                              return 'name format is wrong';
                            }
                            setState(() {
                              name = p0;
                            });
                          } else
                            return 'name can\'t be empty';
                          return null;
                        },
                        hint: 'name',
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
                          signup();
                        },
                        child: Text(
                          'SignUp',
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
                              'signup with',
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
