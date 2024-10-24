import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String status;
  final String title;

  CustomCard({
    required this.status,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(status); // 상태에 따라 색상 결정

    return GestureDetector(
      onTap: () {
        // 클릭 시 이동하는 로직 구현 (필요에 따라 추가)
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15.0),
        padding: EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 71,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8)),
              ),
            ),
            SizedBox(width: 10), // 공간 확보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: statusColor, // 상태에 따라 색상 적용
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _getStatusText(status), // 한글 상태 텍스트
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange; // "작성 중"으로 해석
      case 'COMPLETE':
        return Colors.green; // "완료"로 해석
      case 'REJECTED':
        return Colors.red; // "반려"로 해석
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '작성 중'; // 한글로 변환
      case 'COMPLETE':
        return '완료'; // 한글로 변환
      case 'REJECTED':
        return '반려'; // 한글로 변환
      default:
        return '알 수 없음'; // 기본 값
    }
  }
}
