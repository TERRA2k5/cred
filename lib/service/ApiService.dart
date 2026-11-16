import 'dart:convert';
import 'package:credd/models/SDUI_model.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@injectable
class MockApiService {
  static const String endpoint = 'https://api.mocklets.com/p87/card-management';

  Future<List<SDUIModel>> fetchScreenComponents() async {
    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['items'] is List) {
          final itemsList = decoded['items'] as List;
          return itemsList
              .whereType<Map<String, dynamic>>()
              .map((item) => SDUIModel.fromJson(item))
              .toList();
        }
        throw const FormatException('Expected "items" array in response root');
      } else {
        throw Exception('Failed to fetch data (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
