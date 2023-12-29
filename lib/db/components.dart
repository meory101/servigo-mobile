import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:servigo/db/links.dart';
import 'package:shared_preferences/shared_preferences.dart';

updateProfile(Map body) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  http.Response response = await http.post(
    Uri.parse(updateprofile),
    body: body,
    headers: {'Authorization': 'Bearer ${prefs.getString('usertoken')}'},
  );
  return jsonDecode(response.body);
}

postWithFile(String url, Map data, File file) async {
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
  print(jsonDecode(response.body));
  return jsonDecode(response.body);
}

postWithMultiFile(String url, Map data, List<File> files) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('usertoken');
  var multipartrequest = await http.MultipartRequest('POST', Uri.parse(url));
  for (int i = 0; i < files.length; i++) {
    var length = await files[i].length();
    var stream = await http.ByteStream(files[i].openRead());
    var multipartfile = await http.MultipartFile('file${i + 1}', stream, length,
        filename: basename(files[i].path));
    multipartrequest.files.add(multipartfile);
  }
  multipartrequest.headers.addAll({'Authorization': 'Bearer ${token}'});
  data.forEach((key, value) {
    multipartrequest.fields[key] = value;
  });
  http.StreamedResponse sresponce = await multipartrequest.send();
  http.Response response = await http.Response.fromStream(sresponce);
  print(jsonDecode(response.body));
  return jsonDecode(response.body);
}

postWithFile2(String url, Map data, File file) async {
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

Future<String> loadPDF(url) async {
  print('llllllllllllllllllllllllllllllllllll');
  print(url);
  var response = await http.get(Uri.parse(url));
  int i = Random().nextInt(100);
  print(i);
  var uu = '${url.split('/').last}';
  var dir = await getApplicationDocumentsDirectory();
  File file = new File("${dir.path}/$uu");
  file.writeAsBytesSync(response.bodyBytes, flush: true);
  print(file.path);
  return file.path;
}
