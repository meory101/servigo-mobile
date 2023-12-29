import 'dart:convert';

import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/profile.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<FormState> formkey = new GlobalKey();

class priceTag extends StatefulWidget {
  Map? pricingdata;

  priceTag({
    this.pricingdata,
  });

  @override
  State<priceTag> createState() => _priceTagState();
}

class _priceTagState extends State<priceTag> {
  String? price;
  String? content;

  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  updatePricing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (content != null && price != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('usertoken');
      Map data = {
        'id': '${widget.pricingdata!['pricingdata']['id']}',
        'content': '${content}',
        'price': '${price}',
        'subcategoryid':
            '${widget.pricingdata!['pricingdata']['subcategoryid']}',
        'profileid': '${prefs.getString('profileid')}'
      };

      http.Response response = await http.post(Uri.parse(updatepricing),
          body: data, headers: {'Authorization': 'Bearer ${token}'});
      if (jsonDecode(response.body)['status'] == 'success') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              return Profile(i: "1");
            },
          ),
          (route) => false,
        );
      } else {
        Blurry.error(
            title: 'Opps error',
            description:  '${jsonDecode(response.body)['message'].toString().replaceAll('[', "").replaceAll("]", "").replaceAll('}', "").replaceAll("{", "").replaceAll(',', "")} \n Please check if you have spaces.',
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
      body: SafeArea(
        child: ListView(physics: BouncingScrollPhysics(), children: [
          Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text('${widget.pricingdata!['pricingsubcategory']['name']}',style: pmaints,),
                            ),
                            Text(
                              'Update pricetag data',
                              style: bsubts,
                            ),
                            // Text('Users see this pricetag when they search your service',style: greyts,)
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          child: TextFormField(
                            validator: (p0) {
                              if (p0!.length > 0) {
                                if (p0.length < 100) {
                                  return 'Content must be at least 100';
                                }
                                if (p0.length > 1000) {
                                  return 'Content must be at most 1000';
                                }
                              } else {
                                return 'Can\'t be empty';
                              }
                              setState(() {
                                content = p0;
                              });
                              return null;
                            },
                            minLines: 3,
                            maxLines: 100,
                            maxLength: 1000,
                            cursorColor: maincolor.withOpacity(0.4),
                            initialValue: widget.pricingdata?['pricingdata']
                                        ['content'] !=
                                    null
                                ? '${widget.pricingdata!['pricingdata']['content']}'
                                : null,
                            decoration: InputDecoration(
                              hintText: 'Price tag content',
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(border_rad_size),
                                borderSide: BorderSide(
                                  color: maincolor
                                      .withOpacity(0.4)
                                      .withOpacity(0.4),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(border_rad_size),
                                borderSide: BorderSide(
                                    color: maincolor.withOpacity(0.4)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(border_rad_size),
                                borderSide: BorderSide(color: errorcolor),
                              ),
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: customField(
                            val: widget.pricingdata?['pricingdata']['price'] !=
                                    null
                                ? '${widget.pricingdata!['pricingdata']['price']}'
                                : null,
                            validator: (p0) {
                              if (p0!.length == 0) {
                                return 'Can\'t be empty';
                              }
                              setState(() {
                                price = p0;
                              });
                              return null;
                            },
                            ketype: TextInputType.number,
                            hint: 'price that you are expecting'),
                      ),
                    ],
                  ),
                ),
                BottomAppBar(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: maincolor,
                      borderRadius: BorderRadius.circular(border_rad_size),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            formkey.currentState!.validate();

                            updatePricing();
                          },
                          icon: Icon(
                            size: 25,
                            Icons.file_download_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
