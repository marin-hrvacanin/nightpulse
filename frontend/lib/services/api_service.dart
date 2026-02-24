import 'package:http/http.dart' as http;

class ApiService {
  static Future<String> fetchExample() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.66:8000/example'),
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
