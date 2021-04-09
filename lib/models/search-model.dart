class SearchModel {
  String title;
  String link;
  String description;

  SearchModel({
    required this.title,
    required this.link,
    required this.description
  });

  factory SearchModel.formJson(Map<String, dynamic> json) {
    return SearchModel(
      title: json['title'] as String,
      link: json['link'] as String,
      description: json['description'] as String,
    );
  }
}