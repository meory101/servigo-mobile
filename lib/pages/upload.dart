import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:blurry/blurry.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:servigo/categories/categories.dart';
import 'package:servigo/db/components.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/dashboard.dart';
import 'package:servigo/pages/home.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Upload extends StatefulWidget {
  var subid;
  String? orderid;
  String? sellerid;
  Upload({this.subid, this.orderid, this.sellerid});
  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  @override
  void initState() {
    print(widget.subid);
    getselectedsubID();
    super.initState();
  }

  var servicetype;
  getselectedsubID() async {
    var subs = await getsubCategories();
    subs = subs['message'];
    for (int i = 0; i < subs.length; i++) {
      if ('${subs[i]['subcategorydata']['id']}' == '${widget.subid}') {
        setState(() {
          servicetype =
              subs[i]['subcategorydata']['maincategory']['servicetype']['id'];
        });
      }
    }
    print(servicetype);
  }

  FilePickerResult? res;

  uploadFiles(context) async {
    if (res != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString('usertoken');
      Map data = {
        'orderid': '${widget.orderid}',
        'sellerid': '${widget.sellerid}',
        'isapprov': '${0}'
      };

      http.Response response =
          await postWithFile11(addfile, data, File('${res!.files[0].path}'));
      http.Response response1 = await http.post(Uri.parse('${updateorder}'),
          body: {'id': '${widget.orderid}', 'status': 'unavailable'},
          headers: {'Authorization': 'Bearer ${token}'});

      var body = jsonDecode(response1.body);
      if (!mounted) return;
      if (body['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File has been  successfully uploaded'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return Home();
          },
        ), (route) => false);
      }
    } else {
      Blurry.error(
          title: 'Opps error',
          description: 'Select file',
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

  postWithFile11(String url, Map data, File file) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('usertoken');
    var multipartrequest = await http.MultipartRequest('POST', Uri.parse(url));
    var length = await file.length();
    var stream = await http.ByteStream(file.openRead());
    var multipartfile = await http.MultipartFile('file', stream, length,
        filename: basename(file.path));
    multipartrequest.files.add(multipartfile);
    multipartrequest.headers.addAll({'Authorization': 'Bearer ${token}'});
    data.forEach((key, value) {
      multipartrequest.fields[key] = value;
    });
    http.StreamedResponse sresponce = await multipartrequest.send();
    http.Response response = await http.Response.fromStream(sresponce);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/images/upload.png',
                  height: 100,
                  width: 100,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                    color: maincolor,
                    borderRadius: BorderRadius.circular(border_rad_size)),
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
              SizedBox(height: 16),
              Text('Selected Files:'),
              Column(
                children: [
                  res != null
                      ? Text(
                          '${res!.names[0]}'
                              .replaceAll('[', '')
                              .replaceAll(']', ''),
                        )
                      : Text('')
                ],
              ),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                    color: maincolor,
                    borderRadius: BorderRadius.circular(border_rad_size)),
                child: InkWell(
                  onTap: () async {
                    uploadFiles(context);
                  },
                  child: Text(
                    'Upload file',
                    style: wsmallts,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
