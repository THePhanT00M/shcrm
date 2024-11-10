import 'package:flutter/material.dart';

class TitleEditScreen extends StatefulWidget {
  final String? currentTitle;

  TitleEditScreen({this.currentTitle});

  @override
  _TitleEditScreenState createState() => _TitleEditScreenState();
}

class _TitleEditScreenState extends State<TitleEditScreen> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the current title or an empty string
    _titleController = TextEditingController(text: widget.currentTitle ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submitTitle() {
    String updatedTitle = _titleController.text.trim();
    if (updatedTitle.isNotEmpty) {
      // Pop the screen and send the updated title back
      Navigator.pop(context, updatedTitle);
    } else {
      // Optionally, show a warning if the title is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목을 입력해주세요.')),
      );
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
          '보고서 수정',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _submitTitle,
            child: Text(
              '저장',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 8), // Optional: Add some spacing at the end
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: '제목',
            border: OutlineInputBorder(),
          ),
          maxLength: 100, // Optional: Limit the title length
        ),
      ),
    );
  }
}
