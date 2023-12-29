import 'dart:convert';
import 'package:blurry/resources/extensions.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:blurry/blurry.dart';
import 'package:flutter_custom_selector/flutter_custom_selector.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:servigo/categories/categories.dart';
import 'package:servigo/components/customfield.dart';
import 'package:servigo/db/components.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:servigo/db/links.dart';
import 'package:servigo/pages/map.dart';
import 'package:servigo/pages/profile.dart';
import 'package:servigo/pages/showposts.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';
import 'package:servigo/theme/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<FormState> formkey = new GlobalKey();

class updatePost extends StatefulWidget {
  var post;
  var images;
  var subcategorydata;
  updatePost({this.post, this.images, this.subcategorydata});

  @override
  State<updatePost> createState() => _updatePostState();
}

class _updatePostState extends State<updatePost> {
  @override
  void initState() {
    print(widget.post);
    print(widget.subcategorydata['maincategory']['servicetype']['name']);
    super.initState();
  }

  List<String> names = [];

  List<File> images = [File('dd'), File('dd'), File('dd')];
  List<File> newimages = [];
  List<String> imagesid = [];
  var latlong;
  String? title;
  String? content;
  String? price;
  var lat;
  var long;
  String? selectedsub;
  // _onCountriesSelectionComplete(value) {
  //   selectedsub = null;
  //   if (value.length == 0) {
  //     Blurry.error(
  //         title: 'Opps',
  //         description: 'Sub category must be selected',
  //         confirmButtonText: 'Okay',
  //         titleTextStyle: const TextStyle(fontFamily: 'Zen'),
  //         buttonTextStyle: const TextStyle(
  //             decoration: TextDecoration.underline, fontFamily: 'Zen'),
  //         descriptionTextStyle: const TextStyle(fontFamily: 'Zen'),
  //         onConfirmButtonPressed: () {
  //           Navigator.of(context).pop();
  //         }).show(context);
  //   } else if (value.length > 1) {
  //     Blurry.error(
  //         title: 'Opps error',
  //         description: 'You can\'t choose more than one please choose again',
  //         confirmButtonText: 'Okay',
  //         titleTextStyle: const TextStyle(fontFamily: 'Zen'),
  //         buttonTextStyle: const TextStyle(
  //             decoration: TextDecoration.underline, fontFamily: 'Zen'),
  //         descriptionTextStyle: const TextStyle(fontFamily: 'Zen'),
  //         onConfirmButtonPressed: () {
  //           Navigator.of(context).pop();
  //         }).show(context);
  //   } else if (value.length == 1) {
  //     setState(() {
  //       selectedsub = value[0];
  //     });
  //   }
  // }

  // var subcategories;
  // gg() async {
  //   subcategories = await getsubCategories();

  //   if (subcategories['status'] == 'success') {
  //     setState(() {
  //       subcategories = subcategories['message'];
  //     });
  //   }
  //   setState(() {
  //     getsubcategorynames();
  //   });
  // }

  // getsubcategorynames() {
  //   print(subcategories);
  //   for (int i = 0; i < subcategories.length; i++) {
  //     setState(() {
  //       names.add('${subcategories[i]['subcategorydata']['name']}');
  //     });
  //   }
  //   print(names);
  // }

  updatePost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('usertoken');

    if (latlong != null) {
      lat = latlong[0];
      long = latlong[1];
    } else {
      lat = widget.post['lat'];
      long = widget.post['long'];
    }
    print(lat);

    // for (int i = 0; i < subcategories.length; i++) {
    //   if (subcategories[i]['subcategorydata']['name'] == selectedsub) {
    //     print(subcategories[i]['subcategorydata']['name']);
    //     setState(() {
    //       subcategoryid = '${subcategories[i]['subcategorydata']['id']}';
    //       print(subcategoryid);
    //     });
    //   }
    // }

    String url = '$updatepost';
    Map data = {
      'id': '${widget.post['id']}',
      'title': '${title}',
      'content': '${content}',
      'price': '${price}',
      'status': 'available',
      'date': 'Updated at ${Jiffy().yMMMMd}',
      'subcategoryid': '${widget.subcategorydata['id']}',
      'profileid': '${prefs.getString('profileid')}',
    };
    for (int i = 0; i < newimages.length; i++) {
      data.addAll({'imageid[$i]': '${imagesid[i]}'});
    }
    data.addAll({'lat': '$lat', 'long': '$long'});
    print(data);
    print('=============================');
    print(images);
    print(imagesid);
    print(newimages);
    if (newimages.length > 0) {
      var body = await postWithMultiFile(url, data, newimages);
      if (body['status'] == 'success') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return showPosts(
            posts: false,
            );
          },
        ));
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
    } else {
      http.Response response = await http.post(Uri.parse(url),
          body: data, headers: {'Authorization': 'Bearer ${token}'});
      var body = jsonDecode(response.body);
      if (body['status'] == 'success') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return showPosts(posts: false,);
          },
        ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  height: MediaQuery.of(context).size.height / 3,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          final imagepicker = await ImagePicker();
                          PickedFile? pickedfile = await imagepicker.getImage(
                              source: ImageSource.gallery);
                          if (pickedfile != null) {
                            File file = await File(pickedfile.path);
                            setState(() {
                              images.insert(index, file);
                              newimages.add(file);
                              print(newimages);
                              imagesid.add('${widget.images[index]['id']}');
                            });
                          }
                        },
                        child: images[index].path == "dd"
                            ? Container(
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(93, 83, 81, 81)
                                      .withOpacity(0.4),
                                  borderRadius:
                                      BorderRadius.circular(border_rad_size),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        '$serverlink' +
                                            '/storage/' +
                                            '${widget.images[index]['imageurl']}',
                                      ),
                                      fit: BoxFit.cover),
                                ),
                                margin: EdgeInsets.only(right: 10),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(93, 83, 81, 81)
                                      .withOpacity(0.4),
                                  borderRadius:
                                      BorderRadius.circular(border_rad_size),
                                  image: DecorationImage(
                                      image: FileImage(images[index]),
                                      fit: BoxFit.cover),
                                ),
                                margin: EdgeInsets.only(right: 10),
                              ),
                      );
                    },
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
                            initialValue: '${widget.post['title']}',
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
                            initialValue: '${widget.post['content']}',
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
                            val: widget.post['price'] != null
                                ? '${widget.post['price']}'
                                : '',
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
                      widget.subcategorydata['maincategory']['servicetype']
                                  ['name'] ==
                              "Human services"
                          ? Container(
                              height: 50,
                              margin: EdgeInsets.only(
                                  top: 20, left: 0, right: 0, bottom: 0),
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
                                          lat: double.parse(widget.post['lat']),
                                          long: double.parse(
                                              widget.post['long']));
                                    },
                                  ));
                                  if (latlong != null) {
                                    latlong = latlong.split('/');
                                  }
                                },
                                child: Text(
                                  'Edit Location',
                                  style: wsmallts,
                                ),
                              ),
                            )
                          : Text(''),

                      // names.length > 0
                      //     ? Container(
                      //         margin: EdgeInsets.only(top: 10),
                      //         child: CustomMultiSelectField<String>(
                      //           decoration: InputDecoration(
                      //             suffixIcon: Icon(
                      //               Icons.arrow_drop_down_rounded,
                      //               color: maincolor,
                      //             ),
                      //             label: Text(
                      //               'sub category',
                      //               style: psmallts,
                      //             ),
                      //             border: OutlineInputBorder(
                      //               borderSide: BorderSide(color: maincolor),
                      //               borderRadius:
                      //                   BorderRadius.circular(border_rad_size),
                      //             ),
                      //           ),
                      //           selectedItemColor: maincolor,
                      //           items: names,
                      //           title: "sub category",
                      //           onSelectionDone: _onCountriesSelectionComplete,
                      //           itemAsString: (item) => item.toString(),
                      //         ),
                      //       )
                      //     : Text(''),
                    ],
                  ),
                ),
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
                            // if (selectedsub == null) {
                            //   Blurry.error(
                            //       title: 'Opps',
                            //       description: 'Please select One sub category',
                            //       confirmButtonText: 'Okay',
                            //       titleTextStyle:
                            //           const TextStyle(fontFamily: 'Zen'),
                            //       buttonTextStyle: const TextStyle(
                            //           decoration: TextDecoration.underline,
                            //           fontFamily: 'Zen'),
                            //       descriptionTextStyle:
                            //           const TextStyle(fontFamily: 'Zen'),
                            //       onConfirmButtonPressed: () {
                            //         Navigator.of(context).pop();
                            //       }).show(context);
                            // }
                            updatePost();
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
        ),
      ),
    );
  }
}
