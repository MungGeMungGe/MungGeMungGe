import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mung_ge_mung_ge/models/search-model.dart';

import 'components/search-list.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final int _pageSize = 20;
  final PagingController<int, SearchModel> _pagingController = PagingController(firstPageKey: 1);

  List<SearchModel> items = [];
  String? _searchedText;
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = new TextEditingController();
    _pagingController.addPageRequestListener((pageKey) {
      if (_searchedText != null) {
        search(_searchedText!, pageKey);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                  ),
                ),
                ElevatedButton(
                  child: Text('검색'),
                  onPressed: () {
                    String text = _searchCtrl.text;
                    if (text.isEmpty) { return; }
                    search(text, 1);
                  },
                )
              ],
            ),
            Expanded(
              child: SearchList(pagingController: _pagingController),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> search(String searchText, int start) async {
    int testStart = (start - 1) * _pageSize + 1;
    _searchedText = searchText;
    Uri uri = Uri.parse('https://openapi.naver.com/v1/search/webkr.json?query=$searchText&start=$testStart&display=$_pageSize');
    Map<String, String> headers = {};
    headers['X-Naver-Client-Id'] = 'w2wHKPfNvc2R3FqPeaCd';
    headers['X-Naver-Client-Secret'] = 'dise3YJPmh';
    http.get(uri, headers: headers).then((response) {
      if (response.statusCode == 200) {
        dynamic resultJson = jsonDecode(response.body);
        List<dynamic> list = resultJson['items'];
        final isLastPage = list.length < _pageSize;
        setState(() {
          items = list.map((item) => SearchModel.formJson(item)).toList();
        });
        if (isLastPage) {
          _pagingController.appendLastPage(items);
        } else {
          _pagingController.appendPage(items, start + 1);
        }
      }
    });
  }
}

