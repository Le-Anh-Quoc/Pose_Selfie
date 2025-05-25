class CategoryModel {
  final int id;
  final String title;
  final String mainImage;
  final int totalPoses;

  CategoryModel({
    required this.id,
    required this.title,
    required this.mainImage,
    required this.totalPoses,
  });
  
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? '',
      mainImage: json['image_rectangle'] ?? '',
      totalPoses: json['ideas'] ?? 0,
    );
  }
  @override
  String toString() {
    return 'PoseItem(id: $id, title: $title, mainImage: $mainImage, totalPoses: $totalPoses)';
  }
}
