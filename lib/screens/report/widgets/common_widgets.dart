import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommonHeader extends StatelessWidget {
  final String? reportTitle;
  final double totalAmount;
  final VoidCallback onTitleEdit;
  final VoidCallback onStatistics;

  const CommonHeader({
    Key? key,
    required this.reportTitle,
    required this.totalAmount,
    required this.onTitleEdit,
    required this.onStatistics,
  }) : super(key: key);

  String _formatNumber(num number) {
    int integerNumber = number.toInt();

    String formattedNumber = integerNumber.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    if (formattedNumber.endsWith(',')) {
      formattedNumber =
          formattedNumber.substring(0, formattedNumber.length - 1);
    }

    return formattedNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      color: Color(0xFF009EB4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                reportTitle ?? '새 보고서',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onTitleEdit,
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 8,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 총 보고 금액
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '총 보고 금액',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '₩${_formatNumber(totalAmount)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // 경비 환급 금액
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '경비 환급 금액',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            '₩0',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: Color(0xFF007792),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      FontAwesomeIcons.chartPie,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: onStatistics,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
