import 'dart:io';
import 'package:blurry/blurry.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_selector/flutter_custom_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:servigo/categories/categories.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/db/components.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/map.dart';
import 'package:servigo/pages/pricetag.dart';
import 'package:servigo/pages/showposts.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Post extends StatefulWidget {
  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  GlobalKey<FormState> formkey = new GlobalKey();
  var latlong;
  List<File> files = [];
  String? selectedsub;
  String? title;
  String? content;
  String? price;
  List<String> names = [];
  String? servicetype;
  var sub;
  var subcategories;
  gg() async {
    subcategories = await getsubCategories();

    if (subcategories['status'] == 'success') {
      if (!mounted) return;
      setState(() {
        subcategories = subcategories['message'];
      });
    }
    setState(() {
      getsubcategorynames();
    });
  }

  getselectedsubid() async {
    print(selectedsub);
    sub = await getsubCategories();
    if (sub['status'] == 'success') {
      sub = sub['message'];
      print(sub);
      for (int i = 0; i < sub.length; i++) {
        if (sub[i]['subcategorydata']['name'] == '$selectedsub') {
          setState(() {
            servicetype = (sub[i]['maincategorydata']['servicetype']['name']);
          });
        }
      }
    }
  }

  getsubcategorynames() {
    print(subcategories);
    for (int i = 0; i < subcategories.length; i++) {
      setState(() {
        names.add('${subcategories[i]['subcategorydata']['name']}');
      });
    }
    print(names);
  }

  void initState() {
    super.initState();

    gg();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  addPost() async {
    print(servicetype);
    print(latlong);
    if (servicetype == 'Human services') {
      if (latlong == null) {
        Blurry.error(
            title: 'Opps',
            description: 'Please add loaction',
            confirmButtonText: 'Okay',
            titleTextStyle: const TextStyle(fontFamily: 'Zen'),
            buttonTextStyle: const TextStyle(
                decoration: TextDecoration.underline, fontFamily: 'Zen'),
            descriptionTextStyle: const TextStyle(fontFamily: 'Zen'),
            onConfirmButtonPressed: () {
              Navigator.of(context).pop();
            }).show(context);

        return;
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (files.length > 0) {
      if (title != null && content != null && selectedsub != null) {
        String? subcategoryid;
        for (int i = 0; i < subcategories.length; i++) {
          if (subcategories[i]['subcategorydata']['name'] == selectedsub) {
            print(subcategories[i]['subcategorydata']['name']);
            setState(() {
              subcategoryid = '${subcategories[i]['subcategorydata']['id']}';
              print(subcategoryid);
            });
          }
        }
        if (subcategoryid != null) {
          Map data = {
            'title': '${title}',
            'content': '${content}',
            'price': '${price}',
            'status': 'available',
            'date': '${Jiffy().yMMMMd}',
            'subcategoryid': '${subcategoryid}',
            'profileid': '${prefs.getString('profileid')}',
          };
          if (latlong != null) {
            data.addAll({'lat': '${latlong[0]}', 'long': '${latlong[1]}'});
          }
          var body = await postWithMultiFile(addpost, data, files);
          if (!mounted) return;
          if (body['status'] == 'success') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return showPosts(posts: false);
                },
              ),
            );
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
    } else if (files.length >= 3) {
      Blurry.error(
          title: 'Opps',
          description: 'Only three images allowed',
          confirmButtonText: 'Okay',
          titleTextStyle: const TextStyle(fontFamily: 'Zen'),
          buttonTextStyle: const TextStyle(
              decoration: TextDecoration.underline, fontFamily: 'Zen'),
          descriptionTextStyle: const TextStyle(fontFamily: 'Zen'),
          onConfirmButtonPressed: () {
            Navigator.of(context).pop();
          }).show(context);
    } else {
      Blurry.error(
          title: 'Opps',
          description: 'Post image is required',
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

  _onCountriesSelectionComplete(value) {
    selectedsub = null;
    if (value.length == 0) {
      setState(() {
        servicetype = '';
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
        servicetype = '';
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
      });
      getselectedsubid();
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
                InkWell(
                  onTap: () async {
                    if (files.length >= 3) {
                      Blurry.error(
                          title: 'Opps',
                          description: 'Only three images allowed',
                          confirmButtonText: 'Okay',
                          titleTextStyle: const TextStyle(fontFamily: 'Zen'),
                          buttonTextStyle: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontFamily: 'Zen'),
                          descriptionTextStyle:
                              const TextStyle(fontFamily: 'Zen'),
                          onConfirmButtonPressed: () {
                            Navigator.of(context).pop();
                          }).show(context);
                    } else {
                      final imagepicker = await ImagePicker();
                      PickedFile? pickedfile = await imagepicker.getImage(
                          source: ImageSource.gallery);
                      if (pickedfile != null) {
                        setState(() {
                          files.add(File(pickedfile.path));
                        });
                        print(files);
                      }
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10, left: 9, right: 9),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 3,
                    child: Center(
                        child: files.length == 0
                            ? Center(
                                child: Icon(Icons.image),
                              )
                            : Container(
                                child: CarouselSlider(
                                  options: CarouselOptions(
                                    // aspectRatio: 2.0,
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                    animateToClosest: true,
                                    viewportFraction: 1.0,
                                    enlargeCenterPage: false,
                                    autoPlay: true,
                                  ),
                                  items: List.generate(
                                      files.length,
                                      (index) => Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        border_rad_size),
                                                image: DecorationImage(
                                                  image:
                                                      FileImage(files[index]),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          )).map((i) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return i;
                                      },
                                    );
                                  }).toList(),
                                ),
                              )),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(
                          'Create new post',
                          style: bsubts,
                        ),
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
                              hintText: 'Post title',
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
                              hintText: 'Post content',
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
                            ketype: TextInputType.number,
                            validator: (p0) {
                              if (p0!.length == 0) {}
                              setState(() {
                                price = p0;
                                print(price);
                              });
                              return null;
                            },
                            hint: 'Price (optional)'),
                      ),
                      names.length > 0
                          ? Container(
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
                                items: names,
                                title: "sub category",
                                onSelectionDone: _onCountriesSelectionComplete,
                                itemAsString: (item) => item.toString(),
                              ),
                            )
                          : Text(''),
                    ],
                  ),
                ),
                servicetype == "Human services"
                    ? Container(
                        height: 50,
                        margin: EdgeInsets.only(
                            top: 0, left: 20, right: 20, bottom: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: maincolor,
                            borderRadius:
                                BorderRadius.circular(border_rad_size)),
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async {
                            latlong = await Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (context) {
                                return GMap(
                                  post: true,
                                );
                              },
                            ));
                            if (latlong != null) {
                              latlong = latlong.split('/');
                            }
                          },
                          child: Text(
                            'Location',
                            style: wsmallts,
                          ),
                        ),
                      )
                    : Text(''),
                BottomAppBar(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    margin: EdgeInsets.only(
                        top: 0, left: 20, right: 20, bottom: 20),
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
                            if (selectedsub == null) {
                              Blurry.error(
                                  title: 'Opps',
                                  description: 'Please select One sub category',
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
                            addPost();
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
