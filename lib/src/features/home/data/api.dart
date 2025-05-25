// ignore_for_file: use_rethrow_when_possible, avoid_print

import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:pose_selfie_app/src/features/home/model/category_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:pose_selfie_app/src/features/home/model/pose_model.dart';

abstract class HomeApi {
  Future<List<CategoryModel>> getCategories();
  Future<List<PoseModel>> getPoseByCategory(int idCategory);
  Future<Map<String, dynamic>> getContourData(int id);
}

class HomeApiImpl implements HomeApi {
  static const timeout = Duration(seconds: 15);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final List<int> ids = [31, 9469, 9520]; // Danh sách các số ID
      final random = Random();
      final selectedId = ids[random.nextInt(ids.length)];
      final url = Uri.parse('https://www.photoideas.mobi/api/image/$selectedId/');

      final response = await http.get(url).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Không thể tải dữ liệu. Vui lòng kiểm tra kết nối mạng và thử lại.');
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        final List<dynamic> categoriesJson = jsonResponse['data']['categories'];
        List<CategoryModel> categoriesItem = categoriesJson
            .map((item) => CategoryModel.fromJson(item))
            .toList();

        return categoriesItem;
      } else {
        throw Exception('Failed to load categories items');
      }
    } catch (e) {
      if (e is TimeoutException) {
        rethrow;
      }
      throw Exception('Failed to load categories items: $e');
    }
  }

  @override
  Future<List<PoseModel>> getPoseByCategory(int idCategory) async {
    try {
      final url = Uri.parse(
        'https://www.photoideas.mobi/api/v2/images/related/?limit=20&offset=0',
      );

      final Map<String, dynamic> data = {
        "category_ids": [idCategory],
      };

      final body = json.encode(data);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Không thể tải dữ liệu. Vui lòng kiểm tra kết nối mạng và thử lại.');
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        final List<dynamic> poseJson = jsonResponse['data']['images'];

        List<PoseModel> poseItems = poseJson
            .map((item) => PoseModel.fromJson(item))
            .toList();

        return poseItems;
      } else {
        throw Exception('Failed to load pose items');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw e;
      }
      throw Exception('Failed to load pose items: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getContourData(int id) async {
    try {
      final url = Uri.parse('https://www.photoideas.mobi/api/image/$id/');

      final response = await http.get(url).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Không thể tải dữ liệu. Vui lòng kiểm tra kết nối mạng và thử lại.');
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'] as Map<String, dynamic>;
        
        if (!data.containsKey('contour_white_url_png')) {
          throw Exception('No contour data available for this pose');
        }
        
        return data;
      }
      throw Exception('Failed to load contour data: ${response.statusCode}');
    } catch (e) {
      if (e is TimeoutException) {
        throw e;
      }
      print('Error fetching contour data: $e');
      throw Exception('Failed to load contour data: $e');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}
