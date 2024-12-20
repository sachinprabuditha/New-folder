import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String url = 'https://api.ezuite.com/api/External_Api/Mobile_Api/Invoke';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final body = jsonEncode({
      "API_Body": [{"Unique_Id": "", "Pw": password}],
      "Api_Action": "GetUserData",
      "Company_Code": username,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Login failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
