import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:open_file/open_file.dart';
import 'package:servigo/admin/Admin.dart';
import 'package:servigo/admin/dash.dart';
import 'package:servigo/db/components.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Download extends StatefulWidget {
  String? url1;
  String? id;
  String? buyerid;

  Download({this.url1, this.id, this.buyerid});
  @override
  State<Download> createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  @override
  void initState() {
    gg();
    super.initState();
  }

  String? path1;
  String? roleid;
  gg() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    roleid = await prefs.getString('userType');
    setState(() {});
    String url1 = '${serverlink}' + '/storage/' + '${widget.url1}';
    
    widget.url1 != "null" ? path1 = await loadPDF(url1) : "null";
  }

  updateProject() async {
    // id isapprov userid
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');
    Map data = {
      'id': '${widget.id}',
      'isapprov': '${1}',
      'userid': '${widget.buyerid}'
    };

    http.Response response = await http.post(
        body: data,
        Uri.parse(updatefile),
        headers: {'Authorization': 'Bearer ${token}'});
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project has been successfully approved'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop(true);
    // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
    //   builder: (context) {
    //     return Admin(title: 'f',);
    //   },
    // ), (route) => false);
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
                  'assets/images/d.png',
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
                    await OpenFile.open(path1);
                  },
                  child: Text(
                    'Open file',
                    style: wsmallts,
                  ),
                ),
              ),
              roleid == '${4}' || '${roleid}' == '${3}'
                  ? Container(
                      margin: EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(border_rad_size)),
                      child: InkWell(
                        onTap: () async {
                          updateProject();
                        },
                        child: Text(
                          'Approv',
                          style: wsmallts,
                        ),
                      ),
                    )
                  : Text(''),
            ],
          ),
        ),
      ),
    );
  }
}
