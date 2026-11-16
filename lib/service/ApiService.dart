import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@injectable
class MockApiService {
  final String _endpoint = 'https://api.mocklets.com/p87/card-management';

  Future<Map<String,dynamic>> fetchSDUIData() async {
    try {
      final response = await http.get(Uri.parse(_endpoint));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catching network errors (e.g., no internet)
      throw Exception('Network error occurred: $e');
    }
  }
}