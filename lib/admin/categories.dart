import 'dart:convert';
import 'dart:io';

import 'package:blurry/blurry.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servigo/categories/categories.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/db/components.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/info.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  GlobalKey<FormState> yy = new GlobalKey();
  bool servicetype = true;
  var servicetypes;
  var image;
  String? name;
  List<String> stnames = [];

  servicetypesnames() async {
    servicetypes = await getServiceTypes();
    for (int i = 0; i < servicetypes.length; i++) {
      stnames.add(servicetypes[i]['name']);
    }
   
  }

  addNewMainCategory() async {
    setState(() {
      image = null;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Create main category',
            style: psubts,
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Form(
                key: yy,
                child: Column(
                  children: [
                    customField(
                      hint: 'name',
                      validator: (p0) {
                        if (p0!.length == 0) {
                          return 'Enter name';
                        } else if (p0.length > 20) {
                          return '20 charachter at most';
                        }
                        setState(() {
                          name = p0;
                        });
                      },
                    ),
                    image != null
                        ? Container(
                            margin: EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                            ),
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: FileImage(image)),
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
                        onTap: () async {
                          image = null;
                          final imagepicker = await ImagePicker();
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          PickedFile? pickedfile = await imagepicker.getImage(
                              source: ImageSource.camera);
                          if (pickedfile != null) {
                            setState(() {
                              image = File(pickedfile.path);
                            });
                          }
                        },
                        child: Text(
                          'Main category image',
                          style: wsmallts,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          color: maincolor,
                          borderRadius: BorderRadius.circular(border_rad_size)),
                      child: InkWell(
                        onTap: () async {
                          int? servicetypeid = servicetype ? 1 : 2;
                          print(servicetypeid);
                          if (yy.currentState!.validate() && image != null) {
                            var response = await postWithFile(
                                addmaincategory,
                                {
                                  'name': '${name}',
                                  'servicetypeid': '${servicetypeid}'
                                },
                                image!);
                            if (response['status'] == 'success') {
                              servicetypesnames();
                              setState(
                                () {},
                              );
                              Navigator.of(context).pop();
                            } else {
                              Blurry.error(
                                  title: 'Opps',
                                  description: response['message'] != null
                                      ? '${response['message']['name']}'
                                          .replaceAll('[', '')
                                          .replaceAll(']', '')
                                      : 'Something went wrong',
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
                          } else {
                            Blurry.error(
                                title: 'Opps',
                                description: 'All fields are required',
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
                          'Done',
                          style: wsmallts,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  upadteMainCategory(name, url, index) async {
    var image;
    setState(() {
      image == null;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Update main category',
            style: psubts,
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Form(
                key: yy,
                child: Column(
                  children: [
                    customField(
                      val: name,
                      hint: 'name',
                      validator: (p0) {
                        if (p0!.length == 0) {
                          return 'Enter name';
                        } else if (p0.length > 20) {
                          return '20 charachter at most';
                        }
                        setState(() {
                          name = p0;
                        });
                      },
                    ),
                    image != null
                        ? Container(
                            margin: EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                            ),
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: FileImage(image)),
                            ),
                          )
                        : url != null
                            ? Container(
                                margin: EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                ),
                                height: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage('$serverlink' +
                                          '/storage/' +
                                          '${url}')),
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
                        onTap: () async {
                          final imagepicker = await ImagePicker();
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          PickedFile? pickedfile = await imagepicker.getImage(
                              source: ImageSource.camera);
                          if (pickedfile != null) {
                            setState(() {
                              image = File(pickedfile.path);
                            });
                          }
                        },
                        child: Text(
                          'Main category image',
                          style: wsmallts,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          color: maincolor,
                          borderRadius: BorderRadius.circular(border_rad_size)),
                      child: InkWell(
                          onTap: () async {
                            int? servicetypeid = servicetype ? 1 : 2;
                            print(servicetypeid);
                            if (yy.currentState!.validate() && image != null) {
                              var response = await postWithFile(
                                  updatemaincategory,
                                  {
                                    'id': '${index}',
                                    'name': '${name}',
                                    'servicetypeid': '${servicetypeid}'
                                  },
                                  image!);
                              if (response['status'] == 'success') {
                                servicetypesnames();
                                setState(
                                  () {},
                                );
                                Navigator.of(context).pop();
                              } else {
                                Blurry.error(
                                    title: 'Opps',
                                    description: response['message'] != null
                                        ? '${response['message']['name']}'
                                            .replaceAll('[', '')
                                            .replaceAll(']', '')
                                        : 'Something went wrong',
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
                            } else if (yy.currentState!.validate()) {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String? token =
                                  await prefs.getString('usertoken');
                              http.Response response = await http.post(
                                  body: {'id': '${index}', 'name': '${name}'},
                                  Uri.parse(updatemaincategory),
                                  headers: {
                                    'Authorization': 'Bearer ${token}'
                                  });
                              var body = jsonDecode(response.body);
                              if (body['status'] == 'success') {
                                servicetypesnames();
                                setState(
                                  () {},
                                );
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          child: Text(
                            'Done',
                            style: wsmallts,
                          )),
                    )
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
    // String? token = await prefs.getString('usertoken');
    // http.Response response = await postWithFile(
    //   addmaincategory,
    //   {},
    // );
  }

  @override
  void initState() {
    servicetypesnames();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                margin: EdgeInsets.only(top: 20, bottom: 40),
                child: Text(
                  'Main Categories',
                  style: pmaints,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  alignment: Alignment.topLeft,
                  child: Text(
                    stnames.length > 0
                        ? servicetype
                            ? "${stnames[0]}"
                            : "${stnames[1]}"
                        : 'Waiting',
                    style: psubts,
                    textAlign: TextAlign.left,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      servicetype = !servicetype;
                    });
                  },
                  icon: Icon(
                    Icons.swap_horiz,
                    color: maincolor,
                  ),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder(
                future: servicetype == true ? getTechnicals() : getHumans(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return GridView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.8),
                      itemBuilder: (context, index) {
                        return FocusedMenuHolder(
                          menuWidth: 200,
                          // openWithTap: true,
                          onPressed: () {},
                          menuItems: [
                            FocusedMenuItem(
                              title: Text(
                                'create',
                                style: psmallts,
                              ),
                              onPressed: () {
                                addNewMainCategory();
                              },
                              trailingIcon: Icon(
                                Icons.create,
                                color: maincolor1,
                                size: 22,
                              ),
                            ),
                            FocusedMenuItem(
                              title: Text(
                                'update',
                                style: psmallts,
                              ),
                              onPressed: () {
                                upadteMainCategory(
                                  snapshot.data[index]['maincategorydata']
                                      ['name'],
                                  snapshot.data[index]['maincategorydata']
                                      ['imageurl'],
                                  snapshot.data[index]['maincategorydata']
                                      ['id'],
                                );
                              },
                              trailingIcon: Icon(
                                Icons.update,
                                color: maincolor1,
                                size: 22,
                              ),
                            ),
                          ],
                          child: InkWell(
                            onTap: () {},
                            child: Card(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(border_rad_size),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          image: DecorationImage(
                                              image: NetworkImage('$serverlink' +
                                                  '/storage/' +
                                                  '${snapshot.data[index]['maincategorydata']['imageurl']}'),
                                              fit: BoxFit.cover),
                                          color: Colors.transparent,
                                        ),
                                        margin: EdgeInsets.all(10),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${snapshot.data[index]['maincategorydata']['name']}',
                                          style: psubts,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height / 2),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: maincolor,
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height / 2),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/planet.png',
                              height: 100,
                              width: 100,
                            ),
                            Text(
                              'No main categories yet',
                              style: psubts,
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
