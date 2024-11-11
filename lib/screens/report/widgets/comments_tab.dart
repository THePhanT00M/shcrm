import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentsTab extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> commentsByDate;
  final String? employeeId;
  final TextEditingController commentController;
  final bool isCommentNotEmpty;
  final Future<void> Function(String) onSubmitComment;
  final Future<void> Function() onRefresh;
  final ScrollController scrollController;

  const CommentsTab({
    Key? key,
    required this.commentsByDate,
    required this.employeeId,
    required this.commentController,
    required this.isCommentNotEmpty,
    required this.onSubmitComment,
    required this.onRefresh,
    required this.scrollController,
  }) : super(key: key);

  String _formatTime(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
    return DateFormat('a h:mm', 'ko_KR').format(dateTime);
  }

  List<Widget> _buildCommentsByDate(BuildContext context) {
    List<String> sortedDates = commentsByDate.keys.toList()..sort();
    List<Widget> widgets = [];

    for (String date in sortedDates) {
      DateTime dateTime = DateTime.parse(date);
      String formattedDate =
          DateFormat('yyyy.MM.dd EEEE', 'ko_KR').format(dateTime);

      widgets.add(
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 12.0,
          ),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 3.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month_outlined,
                      size: 14, color: Colors.grey[700]),
                  SizedBox(width: 5),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      List<Map<String, dynamic>> comments = commentsByDate[date]!;

      for (var comment in comments) {
        bool isMyComment = employeeId == comment['employeeId'].toString();

        String formattedTime = '';
        if (comment['createdAt'] != null) {
          formattedTime = _formatTime(comment['createdAt']);
        }

        widgets.add(
          Align(
            alignment:
                isMyComment ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: isMyComment
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMyComment)
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      if (!isMyComment) SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          decoration: BoxDecoration(
                            color: isMyComment
                                ? Colors.white
                                : Colors.yellowAccent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(isMyComment ? 12 : 0),
                              bottomRight:
                                  Radius.circular(isMyComment ? 0 : 12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            comment['content'] ?? '',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      if (isMyComment) SizedBox(width: 8),
                      if (isMyComment)
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    formattedTime,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: Colors.white,
      color: Color(0xFF009EB4),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 3.0,
                  ),
                  width: double.infinity,
                  child: Text(
                    "코멘트",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ..._buildCommentsByDate(context),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 35.0,
                    decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFA3A3A3)),
                          bottom: BorderSide(color: Color(0xFFA3A3A3)),
                          left: BorderSide(color: Color(0xFFA3A3A3)),
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          bottomLeft: Radius.circular(5.0),
                        ),
                        color: Colors.white),
                    child: TextField(
                      controller: commentController,
                      style: TextStyle(
                        fontSize: 14.0,
                        decoration: TextDecoration.none,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: '내용을 입력해주세요',
                        hintStyle: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                          decoration: TextDecoration.none,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 12.0,
                        ),
                        counterText: '',
                      ),
                      maxLength: 200,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: isCommentNotEmpty
                      ? () {
                          onSubmitComment(commentController.text);
                        }
                      : null,
                  child: Container(
                    height: 35.0,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isCommentNotEmpty
                              ? Colors.blueAccent
                              : Color(0xFFA3A3A3),
                        ),
                        bottom: BorderSide(
                          color: isCommentNotEmpty
                              ? Colors.blueAccent
                              : Color(0xFFA3A3A3),
                        ),
                        right: BorderSide(
                          color: isCommentNotEmpty
                              ? Colors.blueAccent
                              : Color(0xFFA3A3A3),
                        ),
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0),
                      ),
                      color:
                          isCommentNotEmpty ? Colors.blueAccent : Colors.grey,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    alignment: Alignment.center,
                    child: Text(
                      '등록',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
