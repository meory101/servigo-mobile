import 'dart:convert';

import 'package:blurry/blurry.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_custom_selector/flutter_custom_selector.dart';
import 'package:servigo/categories/categories.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/dashboard.dart';
import 'package:servigo/pages/map.dart';
import 'package:servigo/pages/test.dart';
import 'package:servigo/payment/pay.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

GlobalKey<FormState> formkey = new GlobalKey();

class documentForm extends StatefulWidget {
  String? sellerid;
  String? buyerid;
  var lat;
  var long;

  documentForm({this.sellerid, this.buyerid, this.lat, this.long});
  @override
  State<documentForm> createState() => _documentFormState();
}

class _documentFormState extends State<documentForm> {
  List<DateTime?> today1 = [DateUtils.dateOnly(DateTime.now())];
  List<DateTime?> today2 = [DateUtils.dateOnly(DateTime.now())];
  String? title;
  String? content;
  String? price;
  int? servicetype;
  bool i = false;
  var latlong;
  var lat;
  var long;
  bool j = false;
  List<String> names = [];
  var selectedsub;
  @override
  void initState() {
    gg();
    super.initState();
  }

  gg() async {
    print(widget.lat);
    print(widget.long);
    lat = widget.lat;
    long = widget.long;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> orderids = await prefs.getStringList('orderids')!;
    print('000000000000000000000000000000000');
    print(orderids);
    print('000000000000000000000000000000000');
    // return;
    var response = await getSpecial(orderids);
    print(response);
    if (!mounted) return;
    for (int i = 0; i < response.length; i++) {
      setState(() {
        setState(() {
          names.add('${response[i]['name']}');
        });
      });
    }
    print(names);
  }

  String? id;
  getselectedsubID() async {
    var subs = await getsubCategories();
    subs = subs['message'];
    for (int i = 0; i < subs.length; i++) {
      if (subs[i]['subcategorydata']['name'] == '$selectedsub') {
        setState(() {
          id = '${subs[i]['subcategorydata']['id']}';
          servicetype =
              subs[i]['subcategorydata']['maincategory']['servicetype']['id'];
        });
      }
    }
    print(servicetype);
    print(id);
  }

  CreateOrder() async {
    print(servicetype);
    print(today2.first!.difference(today1.first!).inDays);
    if (formkey.currentState!.validate() &&
        selectedsub != null &&
        today1 != null &&
        today2 != null) {
      if ("${servicetype}" == "${2}" ? (lat != null && long != null) : (true)) {
        String? uid;
        if ((today1.first!.isAfter(DateTime.now()) ||
                "${today1.first!.day}" == '${DateTime.now().day}') &&
            (today1.first!.isBefore(today2.first!) ||
                today1.first!.isAtSameMomentAs(today2.first!)) &&
            today2.first!.difference(today1.first!).inDays <= 365) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? token = await prefs.getString('usertoken');
          String? userid = await prefs.getString('usertoken');
          if ('$userid' != '${widget.sellerid}') {
            uid = '${widget.sellerid}';
          } else {
            uid = '${widget.buyerid}';
          }
          http.Response response = await http.post(
              body: {
                'sellerid': '${widget.sellerid}',
                'buyerid': '${widget.buyerid}',
                'status': 'waiting',
                'subcategoryid': '${id}'
              },
              Uri.parse(addorder),
              headers: {'Authorization': 'Bearer ${token}'});
          if (!mounted) return;
          var body = jsonDecode(response.body);
          int orderid = body['orderid'];
          print(orderid);
          Map data = {
            'startuptime': '${today1.first}',
            'deliverytime': '${today2.first}',
            'isapprov': '${0}',
            'price': '$price',
            'title': '$title',
            'content': '$content',
            'orderid': '$orderid',
            'userid': '${uid}',
            'sellerid': '${widget.sellerid}',
            'buyerid': '${widget.buyerid}',
            'type': 'new order'
          };
          if ('${servicetype}' == '${2}') {
            data.addAll({
              'worklocation': '$lat/$long',
            });
          } else {
            data.addAll({
              'worklocation': 'null/null',
            });
          }

          http.Response response1 = await http.post(
              body: data,
              Uri.parse(adddocument),
              headers: {'Authorization': 'Bearer ${token}'});
          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return PaymentScreen(
                price: price,
              );
            },
          ));
        } else {
          Blurry.error(
              title: 'Opps',
              description: 'Wrong dates',
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
            title: 'Opps',
            description: 'Location is required',
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
          title: 'Opps',
          description: 'All fields are required',
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

  @override
  Widget build(BuildContext context) {
    _onCountriesSelectionComplete(value) {
      selectedsub = null;
      if (value.length == 0) {
        setState(() {
          servicetype = 0;
        });
        Blurry.error(
            title: 'Opps',
            description: 'Sub category must be selected',
            confirmButtonText: 'Okay',
            titleTextStyle: const TextStyle(fontFamily: 'Zen'),
            buttonTextStyle: const TextStyle(
                decoration: TextDecoration.underline, fontFamily: 'Zen'),
            descriptionTextStyle: const TextStyle(fontFamily: 'Zen'),
            onConfirmButtonPressed: () {
              Navigator.of(context).pop();
            }).show(context);
      } else if (value.length > 1) {
        setState(() {
          servicetype = 0;
        });
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
          getselectedsubID();
        });
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document',
                    style: pmaints,
                  ),
                  Text(
                    'PLease make sure to insert correct data the other user will take or cancle the order based on this document',
                    style: psmallts,
                  ),
                  names.length == 0
                      ? CircularProgressIndicator(
                          color: maincolor,
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 20),
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
                                  borderRadius:
                                      BorderRadius.circular(border_rad_size),
                                ),
                              ),
                              selectedItemColor: maincolor,
                              items: names,
                              title: "sub category",
                              onSelectionDone: _onCountriesSelectionComplete,
                              itemAsString: (item) {
                                return item.toString();
                              }),
                        ),
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      child: TextFormField(
                        validator: (p0) {
                          if (p0!.length > 0) {
                            if (p0.length < 50) {
                              return 'Title must be at least 50';
                            }
                            if (p0.length > 100) {
                              return 'Title must be at most 100';
                            }
                          } else {
                            return 'Can\'t be empty';
                          }
                          setState(() {
                            title = p0;
                          });
                          return null;
                        },
                        minLines: 1,
                        maxLines: 50,
                        maxLength: 100,
                        cursorColor: maincolor.withOpacity(0.4),
                        decoration: InputDecoration(
                          hintText: 'Workstation title',
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(border_rad_size),
                            borderSide: BorderSide(
                              color:
                                  maincolor.withOpacity(0.4).withOpacity(0.4),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(border_rad_size),
                            borderSide:
                                BorderSide(color: maincolor.withOpacity(0.4)),
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
                        minLines: 1,
                        maxLines: 100,
                        maxLength: 1000,
                        cursorColor: maincolor.withOpacity(0.4),
                        decoration: InputDecoration(
                          hintText: 'Workstation content',
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(border_rad_size),
                            borderSide: BorderSide(
                              color:
                                  maincolor.withOpacity(0.4).withOpacity(0.4),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(border_rad_size),
                            borderSide:
                                BorderSide(color: maincolor.withOpacity(0.4)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(border_rad_size),
                            borderSide: BorderSide(color: errorcolor),
                          ),
                        ),
                      )),
                  Container(
                      margin: EdgeInsets.only(top: 20),
                      child: customField(
                        hint: 'price',
                        validator: (p0) {
                          if (p0!.length == 0) {
                            return 'Can\'t be empty';
                          }
                          setState(() {
                            price = p0;
                            print(price);
                          });
                          return null;
                        },
                        ketype: TextInputType.number,
                      )),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        color: maincolor,
                        borderRadius: BorderRadius.circular(border_rad_size)),
                    child: InkWell(
                      onTap: () {
                        j = !j;
                        setState(() {});
                      },
                      child: Text(
                        'Start time',
                        style: wsmallts,
                      ),
                    ),
                  ),
                  if (j == true)
                    ...([
                      CalendarDatePicker2(
                          config: CalendarDatePicker2Config(
                            selectedDayHighlightColor: maincolor,
                            calendarType: CalendarDatePicker2Type.single,
                          ),
                          value: today1,
                          onValueChanged: (dates) => setState(() {
                                today1 = dates;
                              }))
                    ]),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        color: maincolor,
                        borderRadius: BorderRadius.circular(border_rad_size)),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          i = !i;
                        });
                      },
                      child: Text(
                        'Deliver time',
                        style: wsmallts,
                      ),
                    ),
                  ),
                  if (i == true)
                    ...([
                      CalendarDatePicker2(
                          config: CalendarDatePicker2Config(
                            selectedDayHighlightColor: maincolor,
                            calendarType: CalendarDatePicker2Type.single,
                          ),
                          value: today2,
                          onValueChanged: (dates) => setState(() {
                                today2 = dates;
                              }))
                    ]),
                  servicetype == 2
                      ? Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                              color: maincolor,
                              borderRadius:
                                  BorderRadius.circular(border_rad_size)),
                          child: InkWell(
                            onTap: () async {
                              latlong = await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (context) {
                                  return GMap(
                                    post: true,
                                    lat: lat != null ? double.parse(lat) : null,
                                    long: long != null
                                        ? double.parse(long)
                                        : null,
                                  );
                                },
                              ));
                              if (latlong != null) {
                                latlong = latlong.split('/');
                                lat = latlong[0];
                                long = latlong[1];
                                setState(() {});
                              }
                              print(latlong);
                            },
                            child: Text(
                              'Location',
                              style: wsmallts,
                            ),
                          ),
                        )
                      : Text(''),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        color: maincolor,
                        borderRadius: BorderRadius.circular(border_rad_size)),
                    child: InkWell(
                      onTap: () {
                        CreateOrder();
                      },
                      child: Text(
                        'Done',
                        style: wsmallts,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
