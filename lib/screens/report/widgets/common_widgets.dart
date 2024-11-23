import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommonHeader extends StatelessWidget {
  final String? reportTitle;
  final double totalAmount;
  final VoidCallback onTitleEdit;
  final VoidCallback onStatistics;
  final VoidCallback onApproverEdit;
  final String submitterName;
  final String approverName;
  final String reportStatus; // New parameter

  const CommonHeader({
    Key? key,
    required this.reportTitle,
    required this.totalAmount,
    required this.onTitleEdit,
    required this.onStatistics,
    required this.onApproverEdit,
    required this.submitterName,
    required this.approverName,
    required this.reportStatus, // Initialize the new parameter
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
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      color: const Color(0xFF009EB4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
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
              // Conditionally display the edit button
              if (reportStatus.toUpperCase() == 'PENDING')
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: onTitleEdit,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // New Row with Two Fully Rounded Sections
          Row(
            children: [
              // Left Section: 제출자 and Submitter Name
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007792),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '작성자',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        submitterName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Gap between the two sections
              const SizedBox(width: 10),
              // Right Section: 승인자 and Approver Name
              Expanded(
                child: GestureDetector(
                  onTap: onApproverEdit, // Make it tappable
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007792),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '승인자',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              approverName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Existing Row with Total Amount and Statistics Button
          Row(
            children: [
              Expanded(
                flex: 8,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
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
                          const Text(
                            '총 보고 금액',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '₩${_formatNumber(totalAmount)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 경비 환급 금액
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF007792),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
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
