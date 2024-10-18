import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'http://api.shcrm.site:8080';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Apikey': '4sfItxEd9YHjpTS96jxFnZoKseT5PdDM'
  };

  static Future<List<Map<String, dynamic>>> fetchReportsData() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/report/all'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        return {
          'status': item['status'] ?? '알 수 없음',
          'totalExpenses': item['totalExpenses'] ?? '총 지출 정보 없음',
          'title': item['title'] ?? '제목 없음',
          'amount': item['amount'] ?? '₩ 0',
        };
      }).toList();
    } else {
      throw Exception('Failed to load reports');
    }
  }
}
