import 'dart:convert';

import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_custom_selector/flutter_custom_selector.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

GlobalKey<FormState> formkey = GlobalKey();

class add extends StatefulWidget {
  const add({Key? key}) : super(key: key);

  @override
  State<add> createState() => _addState();
}

class _addState extends State<add> {
  var selectuser;
  int? roleid;
  String? name;
  String? email;
  String? password;
  String? selectedsub;
  _onCountriesSelectionComplete(value) {
    selectedsub = null;
    if (value.length == 0) {
      Blurry.error(
          title: 'Opps',
          description: 'User type must be selected',
          confirmButtonText: 'Okay',
          titleTextStyle: const TextStyle(fontFamily: 'Zen'),
          buttonTextStyle: const TextStyle(
              decoration: TextDecoration.underline, fontFamily: 'Zen'),
          descriptionTextStyle: const TextStyle(fontFamily: 'Zen'),
          onConfirmButtonPressed: () {
            Navigator.of(context).pop();
          }).show(context);
    } else if (value.length > 1) {
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
    } else if (value.length == 1) {
      setState(() {
        selectedsub = value[0];
      });
    }
  }

  addUser1() async {
    if (formkey.currentState!.validate() && selectedsub != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('usertoken');
      Map data = {
        'name': '${name}',
        'email': '${email}',
        'password': '${password}',
        'roleid': selectedsub == 'Admin' ? '${4}' : '${3}'
      };

      http.Response response =
          await http.post(Uri.parse(adduser), body: data, headers: {
        'Authorization': 'Bearer $token',
      });
      var body = jsonDecode(response.body);
      print(body);
      if (body['status'] == 'success') {
        formkey.currentState!.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User has been successfully added.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
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
        body: SingleChildScrollView(
      child: SafeArea(
        child: Center(
            child: Column(children: [
          Container(
              margin: EdgeInsets.only(top: 20, bottom: 40),
              child: Text(
                'Add User',
                style: pmaints,
              )),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.transparent.withOpacity(0.9),
              ),
            ),
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(top: 50, left: 10, right: 10),
            child: SingleChildScrollView(
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Add New Account',
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
                        },
                        hint: 'Password',
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: CustomMultiSelectField<String>(
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: maincolor,
                            ),
                            label: Text(
                              'User type',
                              style: psmallts,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: maincolor),
                              borderRadius:
                                  BorderRadius.circular(border_rad_size),
                            ),
                          ),
                          selectedItemColor: maincolor,
                          items: ['Admin', 'Mediator'],
                          title: "User type",
                          onSelectionDone: _onCountriesSelectionComplete,
                          itemAsString: (item) {
                            return item.toString();
                          }),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextButton(
                          onPressed: () {
                            addUser1();
                          },
                          child: Text(
                            "Click to add",
                            style: TextStyle(color: Colors.white),
                          )),
                      decoration: BoxDecoration(
                        color: maincolor,
                        borderRadius: BorderRadius.circular(border_rad_size),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ])),
      ),
    ));
  }
}
