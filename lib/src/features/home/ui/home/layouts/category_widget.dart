// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pose_selfie_app/src/constants/app_constants.dart';
import 'package:pose_selfie_app/src/features/home/model/category_model.dart';
import 'package:pose_selfie_app/src/features/home/ui/detail_category/detail_category_binding.dart';
import 'package:pose_selfie_app/src/features/home/ui/detail_category/detail_category_screen.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryModel poseItem;
  const CategoryWidget({super.key, required this.poseItem});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => DetailCategoryScreen(poseItem: poseItem),
        binding: DetailCategoryBinding(poseItem.id),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: DecorationImage(
            image: NetworkImage(poseItem.mainImage),
            fit: BoxFit.cover,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poseItem.title,
                    style: const TextStyle(
                      color: AppColor.white,
                      fontSize: AppFontSize.large,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'BowlbyOne',
                    ),
                  ),
                  Text(
                    '${poseItem.totalPoses} Poses',
                    style: const TextStyle(
                      color: AppColor.white,
                      fontSize: AppFontSize.mediumSmall,
                      fontFamily: 'Comfortaa',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
