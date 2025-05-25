import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pose_selfie_app/src/common_widgets/gradient_border.dart';
import 'package:pose_selfie_app/src/constants/app_constants.dart';
import 'package:pose_selfie_app/src/features/home/ui/detail_category/detail_category_controller.dart';

class DetailCategoryPreview extends GetView<DetailCategoryController> {
  final int categoryId;

  const DetailCategoryPreview({
    Key? key,
    required this.categoryId,
  }) : super(key: key);

  @override
  String? get tag => categoryId.toString();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Preview',
            style: TextStyle(
              fontSize: AppFontSize.normal,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            if (controller.error.value == 'Error fetching poses for category $categoryId') {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Unable to load poses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.listPose.length,
              itemBuilder: (context, index) {
                final pose = controller.listPose[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GradientBorderContainer(
                    child: Container(
                      width: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: Colors.grey[800],
                        image: DecorationImage(
                          image: NetworkImage(pose.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
