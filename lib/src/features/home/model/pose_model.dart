class PoseModel {
  final int id;
  final String image;
  String? contourWhite;

  PoseModel({
    required this.id,
    required this.image,
    this.contourWhite,
  });

  factory PoseModel.fromJson(Map<String, dynamic> json) {
    return PoseModel(
      id: json['id'] as int,
      image: json['url_rectangle'] ?? json['url'] ?? '',
    );
  }
}