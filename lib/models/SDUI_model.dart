class SDUIModel {
  final String templateName;
  final Map<String, dynamic> templateProperties;
  final List<SDUIModel>? childList;

  SDUIModel({required this.templateName, required this.templateProperties, this.childList});


  factory SDUIModel.fromJson(Map<String, dynamic> json) {
    return SDUIModel(
      templateName: json['template_name'] ?? '',
      templateProperties: json['template_properties'] ?? {},
      childList: json['template_properties']?['child_list'] != null
          ? (json['template_properties']['child_list'] as List)
          .map((child) => SDUIModel.fromJson(child))
          .toList()
          : null,
    );
  }
}