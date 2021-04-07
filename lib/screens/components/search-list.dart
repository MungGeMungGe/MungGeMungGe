import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mung_ge_mung_ge/models/search-model.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchList extends StatelessWidget {
  const SearchList({
    Key? key,
    required PagingController<int, SearchModel> pagingController,
  }) : _pagingController = pagingController, super(key: key);

  final PagingController<int, SearchModel> _pagingController;

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, SearchModel>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<SearchModel>(
        itemBuilder: (context, item, index) {
          return GestureDetector(
            onTap: () {
              canLaunch(item.link).then((can) {
                if (can == true) {
                  launch(item.link);
                }
              });
            },
            child: Column(
              children: [
                Html(
                  data: item.title,
                  style: {
                    '*': Style(fontSize: FontSize.xLarge),
                  },
                ),
                Html(data: item.description),
                Divider(),
              ],
            ),
          );
        },
      ),
    );
  }
}
