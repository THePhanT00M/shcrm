import 'package:http/http.dart' as http;
import 'dart:convert';

// Helper function to check if a URL is an image
bool isImageUrl(String? url) {
  if (url == null) return false;
  final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
  return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
}

class ApiService {
  static const String _baseUrl = 'http://shcrm.ddns.net:8080';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Apikey': '4sfItxEd9YHjpTS96jxFnZoKseT5PdDM'
  };

  static Future<List<Map<String, dynamic>>> fetchCategoriesData() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/category/all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(decodedBody);

        if (responseData['resultCode'] == 'SUCCESS' &&
            responseData['result'] != null) {
          // Assuming responseData['result'] is a list of categories
          final List<dynamic> categoriesList = responseData['result'];

          return categoriesList.map<Map<String, dynamic>>((item) {
            return {
              'categoryId': item['categoryId'] ?? '알 수 없음',
              'categoryName': item['categoryName'] ?? '이름 없음',
            };
          }).toList();
        } else {
          throw Exception('Error: ${responseData['resultMsg']}');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);

        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to fetch categories data: $e');
      throw Exception('Error fetching categories data');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchExpensesData(
      String employeeId) async {
    try {
      final body = json.encode({'employeeId': employeeId});

      final response = await http.post(
        Uri.parse('$_baseUrl/expense/all'),
        headers: _headers,
        body: body,
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(decodedBody);

        print('print : ${responseData}');

        if (responseData['resultCode'] == 'SUCCESS' &&
            responseData['result'] != null) {
          final List<dynamic> results = responseData['result'];

          return results.map<Map<String, dynamic>>((item) {
            print('print : ${item}');
            return {
              'expenseId': item['expenseId'],
              'amount': item['amount'],
              'merchantName': item['merchantName'] ?? '알 수 없음',
              'expenseDate': item['expenseDate'],
              'categoryId': item['categoryId'] ?? '',
              // Set 'url' to null if it's not an image URL
              'url': isImageUrl(item['url'] as String?) ? item['url'] : null,
            };
          }).toList();
        } else {
          throw Exception('Error: ${responseData['resultMsg']}');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);

        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to fetch expenses data: $e');
      throw Exception('Error fetching expenses data');
    }
  }

  static Future<Map<String, dynamic>> fetchExpenseDetails(
      int expenseId, String employeeId) async {
    try {
      final body = json.encode({
        'expenseId': expenseId,
        'employeeId': employeeId,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/expense/details'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(decodedBody);

        print(responseData['result']);

        if (responseData['resultCode'] == 'SUCCESS' &&
            responseData['result'] != null) {
          return {
            'expenseId': responseData['result']['expenseId'],
            'amount': responseData['result']['amount'],
            'merchantName': responseData['result']['merchantName'],
            'address': responseData['result']['address'],
            'expenseDate': responseData['result']['expenseDate'],
            'paymentMethod': responseData['result']['paymentMethod'],
            'url': isImageUrl(responseData['result']['url'] as String?)
                ? responseData['result']['url']
                : null,
            'categoryId':
                responseData['result']['categoryId']['categoryId'] ?? '',
            'categoryName':
                responseData['result']['categoryId']['categoryName'] ?? '',
            'reportId': responseData['result']['reportId']['reportId'] ?? '',
            'reportTitle': responseData['result']['reportId']['title'] ?? '',
          };
        } else {
          throw Exception('Error: ${responseData['resultMsg']}');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);

        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to fetch expense details: $e');
      throw Exception('Error fetching expense details');
    }
  }

  static Future<void> createExpenseData(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/expense/create'),
        headers: _headers,
        body: json.encode(data),
      );

      print('print : ${json.encode(data)}');
      print('print : ${response.statusCode}');

      if (response.statusCode == 200) {
        // 성공적으로 업데이트된 경우 처리
      } else {
        // 오류 처리
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);
        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to update expense data: $e');
      throw Exception('Error updating expense data');
    }
  }

  static Future<void> updateExpenseData(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/expense/update'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // 성공적으로 업데이트된 경우 처리
      } else {
        // 오류 처리
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);
        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to update expense data: $e');
      throw Exception('Error updating expense data');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchReportsData(
      String employeeId) async {
    try {
      final body = json.encode({'employeeId': employeeId});

      final response = await http.post(
        Uri.parse('$_baseUrl/report/all'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(decodedBody);

        if (responseData['resultCode'] == 'SUCCESS' &&
            responseData['result'] != null) {
          final List<dynamic> results = responseData['result'];

          return results.map<Map<String, dynamic>>((item) {
            return {
              'reportId': item['reportId'],
              'status': item['status'] ?? '알 수 없음',
              'title': item['title'] ?? '제목 없음',
            };
          }).toList();
        } else {
          throw Exception('Error: ${responseData['resultMsg']}');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);

        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to fetch reports data: $e');
      throw Exception('Error fetching reports data');
    }
  }

  static Future<Map<String, dynamic>> fetchReportDetails(
      int reportId, String employeeId) async {
    try {
      print(reportId);

      final body = json.encode({
        'reportId': reportId,
        'employeeId': employeeId,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/report/find'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(decodedBody);

        if (responseData['resultCode'] == 'SUCCESS' &&
            responseData['result'] != null) {
          return {
            'reportData': responseData['result']['report'],
            'expensesData': responseData['result']['expenses'],
            'attachmentsData': responseData['result']['attachments'],
            'commentsData': responseData['result']['comments'],
            'categoryId': responseData['result']['categoryId'],
            'authorData': responseData['result']['report']['employeeId'],
            'approverData': responseData['result']['report']
                ['approvalRequestId'],
            'historyData': responseData['result']['history']
          };
        } else {
          throw Exception('Error: ${responseData['resultMsg']}');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);

        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to fetch expense details: $e');
      throw Exception('Error fetching expense details');
    }
  }

  static Future<Map<String, dynamic>> createReportData(
      Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/report/create'),
        headers: _headers,
        body: json.encode(data),
      );

      print('보고서 신규 생성');

      if (response.statusCode == 200) {
        // 성공적으로 업데이트된 경우 처리
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(decodedBody);

        print('API 결과 : ${responseData}');

        if (responseData['resultCode'] == 'SUCCESS' &&
            responseData['result'] != null) {
          return {
            'reportId': responseData['result']['reportId'],
          };
        } else {
          throw Exception('Error: ${responseData['resultMsg']}');
        }
      } else {
        // 오류 처리
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);
        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to update expense data: $e');
      throw Exception('Error updating expense data');
    }
  }

  static Future<void> updateReportData(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/report/update'),
        headers: _headers,
        body: json.encode(data),
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        // 성공적으로 업데이트된 경우 처리
      } else {
        // 오류 처리
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);
        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to update expense data: $e');
      throw Exception('Error updating expense data');
    }
  }

  static Future<List<dynamic>> fetchCommentData(int reportId) async {
    try {
      final body = json.encode({'reportId': reportId});

      final response = await http.post(
        Uri.parse('$_baseUrl/comment/all'),
        headers: _headers,
        body: body,
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(decodedBody);

        print('Response Data: $responseData');

        if (responseData['resultCode'] == 'SUCCESS' &&
            responseData['result'] != null) {
          // Return the entire 'result' array as is
          return List<Map<String, dynamic>>.from(responseData['result']);
        } else {
          throw Exception('Error: ${responseData['resultMsg']}');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsg = responseJson['resultMsg'] ?? 'Unknown error';

        throw Exception('Error: ${response.statusCode}, Message: $resultMsg');
      }
    } catch (e) {
      print('Failed to fetch comment data: $e');
      throw Exception('Error fetching comment data');
    }
  }

  static Future<Map<String, dynamic>> submitComment(
      Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/comment/create'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(decodedBody);

        if (responseData['resultCode'] == 'SUCCESS' &&
            responseData['result'] != null) {
          return {
            'reportData': responseData['result']['report'],
            'expensesData': responseData['result']['expenses'],
            'attachmentsData': responseData['result']['attachments'],
            'commentsData': responseData['result']['comments'],
          };
        } else {
          throw Exception('Error: ${responseData['resultMsg']}');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);

        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to fetch expense details: $e');
      throw Exception('Error fetching expense details');
    }
  }

  static Future<void> sendMail(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/report/generate-pdf'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // 성공적으로 업데이트된 경우 처리
      } else {
        // 오류 처리
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);
        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to update expense data: $e');
      throw Exception('Error updating expense data');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchMembersData() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/member/all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(decodedBody);

        print(responseData);

        if (responseData['resultCode'] == 'SUCCESS' &&
            responseData['result'] != null) {
          final List<dynamic> results = responseData['result'];

          return results.map<Map<String, dynamic>>((item) {
            return {
              'employeeId': item['employeeId'],
              'firstName': item['firstName'],
              'lastName': item['lastName'],
              'email': item['email'],
            };
          }).toList();
        } else {
          throw Exception('Error: ${responseData['resultMsg']}');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decodedBody);
        final resultMsgBytes = (responseJson['resultMsg'] as String).codeUnits;
        final decodedResultMsg = utf8.decode(resultMsgBytes);

        throw Exception(
            'Error: ${response.statusCode}, Message: $decodedResultMsg');
      }
    } catch (e) {
      print('Failed to fetch reports data: $e');
      throw Exception('Error fetching reports data');
    }
  }
}
