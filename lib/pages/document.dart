import 'dart:async';
import 'dart:convert';
// import 'dart:html';
import 'dart:io';

import 'package:blurry/blurry.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_custom_selector/flutter_custom_selector.dart';
import 'package:servigo/components/customfield.dart';
// import 'package:servigo/main.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:servigo/db/components.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/main.dart';
import 'package:servigo/pages/dashboard.dart';
import 'package:servigo/pages/home.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

GlobalKey<FormState> ffkey = new GlobalKey();

class Document extends StatefulWidget {
  String? title;
  String? content;
  String? Worklocation;
  String? time1;
  String? time2;
  String? price;
  String? status;
  String? sellerid;
  String? buyerid;
  String? orderid;

  Document(
      {this.title,
      this.content,
      this.Worklocation,
      this.time1,
      this.time2,
      this.price,
      this.orderid,
      required this.sellerid,
      required this.buyerid});

  @override
  State<Document> createState() => _DocumentState();
}

class _DocumentState extends State<Document> {
  @override
  void initState() {
    today = [DateUtils.dateOnly(DateTime.parse(widget.time2!))];
    super.initState();
  }

  @override
  FilePickerResult? res;
  String? price;
  List<DateTime?>? today;
  addNewDocument() async {
    // print(res!.names[0]!.split('.').last);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    String? userid = await prefs.getString('userid');
    String? uid;
    if ('$userid' == '${widget.sellerid}') {
      uid = '${widget.buyerid}';
    } else {
      uid = '${widget.sellerid}';
    }
    print(uid);
    print(userid);

    if (ffkey.currentState!.validate() && res != null
        ? '${res!.names[0]!.split('.').last}' == 'pdf'
        : true) {
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
          });
      print('ss');

      Map data = {
        'startuptime': '${widget.time1}',
        'deliverytime': today == [DateUtils.dateOnly(DateTime.now())]
            ? '${widget.time2}'
            : '${today!.first}',
        'isapprov': '${0}',
        'price': '$price',
        'title': '${widget.title}',
        'content': '${widget.content}',
        'worklocation': '${widget.Worklocation}',
        'orderid': '${widget.orderid}',
        'createrid': '${userid}',
        'userid': '${uid}',
        'sellerid': '${widget.sellerid}',
        'buyerid': '${widget.buyerid}',
        'type': 'new doc'
      };
      print(data);
      // return;
      if (res != null) {
        print('llllllllllllllllllllllllllllllllllllll');
        print('${res!.files[0].path}');
        // return;

        var body = await postWithFile2(
            adddocument, data, File('${res!.files[0].path}'));
        // if (body['status'] == 'success') {
           ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document has been successfully submitted'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return Home();
          },
        ), (route) => false);
        // }
      } else {
        http.Response response1 = await http.post(
            body: data,
            Uri.parse(adddocument),
            headers: {'Authorization': 'Bearer ${token}'});
        // var body1 = jsonDecode(response1.body);
        // print(body1);
        // if (body1['status'] == 'success') {
           ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document has been successfully submitted'),
            backgroundColor: Colors.green,
          ),
        );
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return Home();
          },
        ), (route) => false);
        // }
      }
    } else {
      Blurry.error(
          title: 'Opps',
          description: 'File should be pdf',
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

  checkDocument() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    http.Response response = await http.post(Uri.parse('${checkdocument}'),
        body: {'orderid': '${widget.orderid}'},
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;
    var body = jsonDecode(response.body);
    print(body);
    if (body['message'] == 'no document') {
      addNewDocument();
    } else {
      Blurry.error(
          title: 'Opps error',
          description:
              'You have document that is not acceptable or rejectable yet',
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
    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Form(
              key: ffkey,
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
                          child: Text(
                            'Document',
                            style: bsubts,
                          ),
                        ),
                        Container(
                            child: CalendarDatePicker2(
                                config: CalendarDatePicker2Config(
                                  selectedDayHighlightColor: maincolor,
                                  calendarType: CalendarDatePicker2Type.single,
                                ),
                                value: today!,
                                onValueChanged: (dates) => setState(() {
                                      setState(() {
                                        today = dates;
                                      });
                                    }))),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: customField(
                            hint: today != [DateUtils.dateOnly(DateTime.now())]
                                ? '$today'
                                : '${widget.time2}',
                            enabled: false,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: customField(
                              validator: (p0) {
                                if (p0!.length == 0) {}
                                setState(() {
                                  price = p0;
                                  print(price);
                                });
                                return null;
                              },
                              val: widget.price,
                              hint: 'Price',
                              ketype: TextInputType.number),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attachments',
                                style: bsubts,
                              ),
                              if (res != null)
                                ...([
                                  InkWell(
                                    onTap: () async {},
                                    child: Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${res!.names[0]}'
                                                  .replaceAll('[', '')
                                                  .replaceAll(']', ''),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 10),
                                      alignment: Alignment.center,
                                      width: double.infinity,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: maincolor,
                                          borderRadius: BorderRadius.circular(
                                              border_rad_size)),
                                      child: InkWell(
                                        onTap: () async {
                                          res = await FilePicker.platform
                                              .pickFiles(allowMultiple: false);
                                          setState(() {});
                                        },
                                        child: Text(
                                          'Browse files',
                                          style: wsmallts,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: IconButton(
                                        onPressed: () {
                                          checkDocument();
                                        },
                                        icon: Icon(
                                          Icons.download_sharp,
                                          color: maincolor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
