import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_selector/flutter_custom_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe_url_check/safe_url_check.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/db/components.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/profile.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<FormState> formkey = new GlobalKey();

class Workstation extends StatefulWidget {
  List subcategories;
  var wk;

  Workstation({required this.subcategories, this.wk});

  @override
  State<Workstation> createState() => _WorkstationState();
}

class _WorkstationState extends State<Workstation> {
  File? image;
  int sublen = 0;
  List<String> names = [];
  String? selectedsub;
  String? title;
  String? content;
  String? link = null;

  updateWorkstation() async {
    print(selectedsub);
    print(link);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (image != null) {
      if (title != null && content != null && selectedsub != null) {
        String? subcategoryid;
        for (int i = 0; i < widget.subcategories.length; i++) {
          if (widget.subcategories[i]['name'] == selectedsub) {
            if (!mounted) return;

            setState(() {
              subcategoryid = '${widget.subcategories[i]['id']}';
            });
          }
        }
        if (subcategoryid != null) {
          Map data = {
            'title': '${title}',
            'content': '${content}',
            'link': '${link}',
            'subcategoryid': '${subcategoryid}',
            'profileid': '${prefs.getString('profileid')}',
            'wkid': '${widget.wk['workstationdata']['id']}'
          };
          var body = await postWithFile(updateworkstation, data, image!);
          if (body['status'] == 'success') {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
              builder: (context) {
                return Profile(
                  i: "0",
                );
              },
            ), (route) => false);
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
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('usertoken');
      if (title != null && content != null && selectedsub != null) {
        String? subcategoryid;
        for (int i = 0; i < widget.subcategories.length; i++) {
          if (widget.subcategories[i]['name'] == selectedsub) {
            if (!mounted) return;

            setState(() {
              subcategoryid = '${widget.subcategories[i]['id']}';
            });
          }
        }
        if (subcategoryid != null) {
          Map data = {
            'title': '${title}',
            'content': '${content}',
            'subcategoryid': '${subcategoryid}',
            'link': '${link}',
            'profileid': '${prefs.getString('profileid')}',
            'wkid': '${widget.wk['workstationdata']['id']}'
          };
          http.Response response = await http.post(Uri.parse(updateworkstation),
              body: data, headers: {'Authorization': 'Bearer ${token}'});
          var body = jsonDecode(response.body);
          print(body);
          if (body['status'] == 'success') {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
              builder: (context) {
                return Profile(i: "0");
              },
            ), (route) => false);
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
      }
    }
  }

  addWorkstation() async {
    print(selectedsub);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (image != null) {
      if (title != null && content != null && selectedsub != null) {
        String? subcategoryid;
        for (int i = 0; i < widget.subcategories.length; i++) {
          if (widget.subcategories[i]['name'] == selectedsub) {
            if (!mounted) return;

            setState(() {
              subcategoryid = '${widget.subcategories[i]['id']}';
            });
          }
        }
        if (subcategoryid != null) {
          Map data = {
            'title': '${title}',
            'content': '${content}',
            'link': '${link}',
            'subcategoryid': '${subcategoryid}',
            'profileid': '${prefs.getString('profileid')}'
          };
          var body = await postWithFile(addworkstation, data, image!);
          if (body['status'] == 'success') {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
              builder: (context) {
                return Profile(i: "0");
              },
            ), (route) => false);
          } else {
            Blurry.error(
                title: 'Opps error',
                description:
                    '${body['message'].toString().replaceAll('[', "").replaceAll("]", "").replaceAll('}', "").replaceAll("{", "").replaceAll(',', "")} \n Please check if you have spaces.',
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
    } else {
      Blurry.error(
          title: 'Opps',
          description: 'Workstation image is required',
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

  getsubCategoriesNames() {
    for (int i = 0; i < widget.subcategories.length; i++) {
      names.add('${widget.subcategories[i]['name']}');
    }
  }

  void initState() {
    print('--------------------------------');
    print(widget.wk);
    print('--------------------------------');

    super.initState();

    getsubCategoriesNames();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _onCountriesSelectionComplete(value) {
      selectedsub = null;
      if (value.length == 0) {
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

    return Scaffold(
      body: SafeArea(
        child: ListView(physics: BouncingScrollPhysics(), children: [
          Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    final imagepicker = await ImagePicker();

                    PickedFile? pickedfile =
                        await imagepicker.getImage(source: ImageSource.gallery);
                    if (pickedfile != null) {
                      setState(() {
                        image = File(pickedfile.path);
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 3,
                    child: Center(
                      child: image == null
                          ? "${widget.wk}" != "null"
                              ? Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage('$serverlink' +
                                              '/storage/' +
                                              '${widget.wk['image']}'),
                                          fit: BoxFit.cover)),
                                )
                              : Center(
                                  child: Icon(Icons.image),
                                )
                          : Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height / 3,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(image!),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(
                          widget.wk == null
                              ? 'Create new workstation'
                              : 'Update workstation',
                          style: bsubts,
                        ),
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(top: 10),
                      //   child: customField(

                      //     hint: 'Workstation title',
                      //   ),
                      // ),
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          child: TextFormField(
                            initialValue: widget.wk != null
                                ? '${widget.wk['workstationdata']['title']}'
                                : null,
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
                          child: TextFormField(
                            initialValue: widget.wk != null
                                ? '${widget.wk['workstationdata']['content']}'
                                : null,
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
                            val: '${widget.wk}' != "null"
                                ? '${widget.wk['workstationdata']['link']}' !=
                                        "null"
                                    ? '${widget.wk['workstationdata']['link']}'
                                    : ''
                                : null,
                            validator: (p0) {
                              if (p0!.length > 0) {
                                if (!RegExp(
                                        "((http|https)://)(www.)?[a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)")
                                    .hasMatch(p0)) {
                                  return 'Url is not valid';
                                }
                                if (safeUrlCheck(Uri.parse(p0)) == true) {
                                  return 'Url is not safe';
                                }
                              }
                              setState(() {
                                link = p0;
                                print(link);
                              });
                              return null;
                            },
                            hint: 'Workstation link (optional)'),
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
                            // initialValue: widget.wk != null
                            //     ? ['${widget.wk['subcategorydata']['name']}']
                            //     : [],
                            items: names,
                            title: "sub category",
                            onSelectionDone: _onCountriesSelectionComplete,
                            itemAsString: (item) {
                              return item.toString();
                            }),
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
                            if (formkey.currentState!.validate()) {
                              if (selectedsub == null) {
                                Blurry.error(
                                    title: 'Opps',
                                    description:
                                        'Please select One sub category',
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
                              widget.wk == null
                                  ? addWorkstation()
                                  : updateWorkstation();
                            }
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
