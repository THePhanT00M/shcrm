import 'package:flutter/material.dart';
import 'api_service.dart';

class CategoryScreen extends StatefulWidget {
  final int? selectedCategoryId; // 선택된 카테고리 ID를 받을 필드 추가

  CategoryScreen({this.selectedCategoryId});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await ApiService.fetchCategoriesData();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load categories: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f0f0),
      appBar: AppBar(
        backgroundColor: Color(0xFF009EB4),
        toolbarHeight: 50,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.chevron_left, size: 24, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          '카테고리',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SafeArea(
                  child: Container(
                    color: const Color(0xFFffffff),
                    child: ListView.builder(
                      itemCount: _categories.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected =
                            widget.selectedCategoryId == category['categoryId'];

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Color(0xFFF1F1F1)), // 보더 색과 두께 설정
                            ),
                          ),
                          child: ListTile(
                            title: Text(category['categoryName']),
                            trailing: isSelected
                                ? Icon(Icons.check, color: Colors.blue)
                                : null,
                            onTap: () {
                              Navigator.pop(context, category); // 선택한 카테고리를 반환
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
