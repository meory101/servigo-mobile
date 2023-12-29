import 'dart:convert';

import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_custom_selector/flutter_custom_selector.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:servigo/categories/categories.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/main.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

GlobalKey<FormState> yy = new GlobalKey();

class subcategories extends StatefulWidget {
  const subcategories({Key? key}) : super(key: key);

  @override
  State<subcategories> createState() => _subcategoriesState();
}

class _subcategoriesState extends State<subcategories> {
  @override
  void initState() {
    futuresubs = getsubs();
    getmainCategoriesNames();
    super.initState();
  }

  String? id;
  getselectedmainID() async {
    var subs = await getMainCategories();
    subs = subs['message'];
    for (int i = 0; i < subs.length; i++) {
      if (subs[i]['maincategorydata']['name'] == '$selectedsub') {
        setState(() {
          id = '${subs[i]['maincategorydata']['id']}';
        });
      }
    }
    print(id);
  }

  var selectedsub;
  _onCountriesSelectionComplete(value) {
    selectedsub = null;
    if (value.length == 0) {
      Blurry.error(
          title: 'Opps',
          description: 'Main category must be selected',
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
        getselectedmainID();
      });
    }
  }

  List<String> names = [];
  getmainCategoriesNames() async {
    var data = await getMainCategories();
    print(data);
    data = data['message'];
    if (!mounted) return;
    for (int i = 0; i < data.length; i++) {
      setState(() {
        names.add('${data[i]['maincategorydata']['name']}');
      });
    }
  }

  String? name;
  late Future futuresubs;
  getsubs() async {
    var response = await getsubCategories();
    if (!mounted) return;
    if (response['status'] == 'success') {
      setState(() {});
      return response['message'];
    } else
      return null;
  }

  addSubCategory() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Create sub category',
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
                      names == null
                          ? CircularProgressIndicator(
                              color: maincolor,
                            )
                          : Container(
                              margin: EdgeInsets.only(top: 10),
                              child: CustomMultiSelectField<String>(
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: maincolor,
                                    ),
                                    label: Text(
                                      'Main category',
                                      style: psmallts,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: maincolor),
                                      borderRadius: BorderRadius.circular(
                                          border_rad_size),
                                    ),
                                  ),
                                  selectedItemColor: maincolor,
                                  items: names,
                                  title: "Main category",
                                  onSelectionDone:
                                      _onCountriesSelectionComplete,
                                  itemAsString: (item) {
                                    return item.toString();
                                  }),
                            ),
                      Container(
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
                            if (yy.currentState!.validate()) {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String? token =
                                  await prefs.getString('usertoken');
                              http.Response response = await http.post(
                                  body: {
                                    'name': '${name}',
                                    'maincategoryid': '${id}'
                                  },
                                  Uri.parse(addsubcategory),
                                  headers: {
                                    'Authorization': 'Bearer ${token}'
                                  });
                              var body = jsonDecode(response.body);
                              if (body['status'] == 'success') {
                                setState(() {
                                  futuresubs = getsubs();
                                });
                                Navigator.of(context).pop();
                              } else {
                                Blurry.error(
                                    title: 'Opps',
                                    description: body['message'] != null
                                        ? '${body['message']['name']}'
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
            },
          ),
        );
      },
    );
  }

  updateSubCategory(index, val) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Update sub category',
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
                        val: val,
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
                      Container(
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
                            if (yy.currentState!.validate()) {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String? token =
                                  await prefs.getString('usertoken');
                              http.Response response = await http.post(
                                  body: {'id': '${index}', 'name': '${name}'},
                                  Uri.parse(updatesubcategory),
                                  headers: {
                                    'Authorization': 'Bearer ${token}'
                                  });
                              var body = jsonDecode(response.body);
                              if (body['status'] == 'success') {
                                setState(() {
                                  futuresubs = getsubs();
                                });
                                Navigator.of(context).pop();
                              } else {
                                Blurry.error(
                                    title: 'Opps',
                                    description: body['message'] != null
                                        ? '${body['message']['name']}'
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
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.only(left: 20, top: 9),
          child: Text(
            'Sub Categories',
            style: pmaints,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: FutureBuilder(
          future: futuresubs,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return FocusedMenuHolder(
                    menuWidth: 200,
                    onPressed: () {},
                    menuItems: [
                      FocusedMenuItem(
                        backgroundColor: maincolor1,
                        title: Text(
                          'create',
                          style: wsmallts,
                        ),
                        onPressed: () {
                          addSubCategory();
                        },
                        trailingIcon: Icon(
                          Icons.create,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      FocusedMenuItem(
                        title: Text(
                          'update',
                          style: psmallts,
                        ),
                        onPressed: () {
                          updateSubCategory(
                              snapshot.data[index]['subcategorydata']['id'],
                              '${snapshot.data[index]['subcategorydata']['name']}');
                        },
                        trailingIcon: Icon(
                          Icons.update,
                          color: maincolor1,
                          size: 22,
                        ),
                      ),
                    ],
                    child: Container(
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(border_rad_size),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Name:',
                                        style: psubts,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${snapshot.data[index]['subcategorydata']['name']}',
                                        style: psmallts,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Main category:',
                                        style: psubts,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${snapshot.data[index]['maincategorydata']['name']}',
                                        style: psmallts,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Service type:',
                                        style: psubts,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${snapshot.data[index]['maincategorydata']['servicetype']['name']}',
                                        style: psmallts,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
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
    );
  }
}
