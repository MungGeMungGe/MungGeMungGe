import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    search('google', 1);

    return Container(
    );
  }

  Future<void> search(String searchText, int start) async {
    Uri uri = Uri.parse('https://openapi.naver.com/v1/search/webkr.json?query=$searchText&start=$start');
    print(uri);
    Map<String, String> headers = {};
    headers['X-Naver-Client-Id'] = 'w2wHKPfNvc2R3FqPeaCd';
    headers['X-Naver-Client-Secret'] = 'dise3YJPmh';
    http.get(uri, headers: headers).then((response) {
      print('result');
      print(response.statusCode);

      if (response.statusCode == 200) {
        dynamic resultJson = jsonDecode(response.body);
        print(resultJson['items']);
        // print(jsonDecode(response.body));
      }
    });
  }
}
