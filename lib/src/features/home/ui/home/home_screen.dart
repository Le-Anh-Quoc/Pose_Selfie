// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pose_selfie_app/src/constants/app_constants.dart';
import 'package:pose_selfie_app/src/features/collection/collection_screen.dart';
import 'package:pose_selfie_app/src/features/home/ui/home/home_controller.dart';
import 'package:pose_selfie_app/src/features/home/ui/home/layouts/category_widget.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A), // Pure black
            Color(0xFF1A1A1A), // Soft black
            Color(0xFF1A1A24), // Very dark purple tint
            Color(0xFF1E1B2B), // Dark purple transition
            Color(0xFF251D39), // Deep purple
            Color(0xFF2C1F47), // Darker deep purple
          ],
          stops: [0.0, 0.3, 0.5, 0.7, 0.85, 1.0], // Extended black portion
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 16),
              _buildPoseGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Pose selfie',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSize.large,
              fontWeight: FontWeight.w400,
              fontFamily: 'BowlbyOne'
            ),
          ),
          TextButton(
            onPressed: () => Get.to(() => const CollectionScreen()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'My Collection',
                  style: TextStyle(color: Colors.white, fontSize: AppFontSize.extraSmall),
                ),
                const SizedBox(width: 8),
                AppIcon.collection,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.tabs.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.selectedTabIndex.value == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.changeTab(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.yellowButton : Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildPoseGrid() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.white),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    size: 80,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Unable to load categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please check your network connection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      controller.getCategories();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        final categories = controller.listCategories;
        if (categories.isEmpty) {
          return const Center(
            child: Text(
              'No data about categories',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            // if (index == 3) {
            //   return _buildAdCard();
            // }
            // final itemIndex = index > 3 ? index - 1 : index;
            final poseItem = categories[index];
            return CategoryWidget(poseItem: poseItem);
          },
        );
      }),
    );
  }
}
