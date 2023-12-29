import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:servigo/db/links.dart';
import 'package:shared_preferences/shared_preferences.dart';

getServiceTypes() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('usertoken');
  http.Response response =
      await http.get(Uri.parse(getservicetypesurl), headers: {
    'Authorization': 'Bearer $token',
  });
  return (jsonDecode(response.body));
}

getMainCategories() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('usertoken');
  http.Response response =
      await http.get(Uri.parse(getmaincategoriesurl), headers: {
    'Authorization': 'Bearer $token',
  });
  return (jsonDecode(response.body));
}

getsubCategories() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('usertoken');
  http.Response response =
      await http.get(Uri.parse(getsubcategoriesurl), headers: {
    'Authorization': 'Bearer $token',
  });
  var body = jsonDecode(response.body);
  return (jsonDecode(response.body));
}

getSpecial(List<String> subcategoriesid) async {
  List gy = [];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('usertoken');
  http.Response response =
      await http.get(Uri.parse(getsubcategoriesurl), headers: {
    'Authorization': 'Bearer $token',
  });
  var body = jsonDecode(response.body);
  for (int i = 0; i < body['message'].length; i++) {
    for (int j = 0; j < subcategoriesid.length; j++) {
      if ('${body['message'][i]['subcategorydata']['id']}' ==
          subcategoriesid[j]) {
        gy.add(body['message'][i]['subcategorydata']);
      }
    }
  }

  return gy;
}

getTechnicals() async {
  var elements = [];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('usertoken');
  http.Response response =
      await http.get(Uri.parse(getmaincategoriesurl), headers: {
    'Authorization': 'Bearer $token',
  });
  var body = jsonDecode(response.body);
  if (body['status'] == 'success') {
    body = body['message'];
    for (int i = 0; i < body.length; i++) {
      if (body[i]['servicetypedata']['name'] == "Technical services") {
        elements.add(body[i]);
      }
    }
    return (elements);
  }
}

getHumans() async {
  var elements = [];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('usertoken');
  http.Response response =
      await http.get(Uri.parse(getmaincategoriesurl), headers: {
    'Authorization': 'Bearer $token',
  });
  var body = jsonDecode(response.body);
  if (body['status'] == 'success') {
    body = body['message'];
    for (int i = 0; i < body.length; i++) {
      if (body[i]['servicetypedata']['name'] == "Human services") {
        elements.add(body[i]);
      }
    }
    return (elements);
  }
}
