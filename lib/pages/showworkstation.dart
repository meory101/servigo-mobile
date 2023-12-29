import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_url_check/safe_url_check.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';

class showWorkstation extends StatefulWidget {
  var workstation;
  showWorkstation({this.workstation});

  @override
  State<showWorkstation> createState() => _showWorkstationState();
}

class _showWorkstationState extends State<showWorkstation> {
  String? link;
  void initState() {
    super.initState();
    print(widget.workstation);
    link = "${widget.workstation['workstationdata']['link']}";
    print(link);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage('$serverlink'+ '/storage/'+ '${widget.workstation['image']}'),
                      fit: BoxFit.cover),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.withOpacity(0.4)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(border_rad_size),
                    topRight: Radius.circular(border_rad_size),
                    bottomLeft: Radius.circular(border_rad_size),
                    bottomRight: Radius.circular(border_rad_size),
                  ),
                ),
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2 - 30,
                    left: 10,
                    right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.workstation['workstationdata']['title']}',
                      style: bsubts,
                    ),
                    Text(
                      '${widget.workstation['subcategorydata']['name']}',
                      style: greyts,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                        '${widget.workstation['workstationdata']['content']}',
                        style: bg,
                      ),
                    ),
                    if (link != "null")
                      ...([
                        Container(
                          margin: EdgeInsets.only(
                            top: 40,
                            bottom: 4,
                          ),
                          alignment: Alignment.bottomLeft,
                          child: InkWell(
                            onTap: () async {
                              Uri url = Uri.parse(link!);
                              final exists = await safeUrlCheck(url);
                              if (exists) {
                                if (await canLaunchUrl(url)) {
                                  launchUrl(url);
                                }
                              }else
                               {
                                  Blurry.error(
                                    title: 'Opps error',
                                    description: 'Url is not safe',
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
                            child: Text(
                              'Click Here',
                              style: psmallts,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ])
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
