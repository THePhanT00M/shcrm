import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool isExpenseRefundAllActive = true;
  bool?
      isComplianceActive; // Change this to nullable boolean to allow unselected state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF007792),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 48), // Placeholder for alignment
            Text(
              '보고서',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Color(0xFF007792),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style:
                  TextStyle(color: Colors.white), // Text color inside TextField
              decoration: InputDecoration(
                hintText: '검색어를 입력해주세요.',
                hintStyle: TextStyle(color: Colors.white54), // Hint text color
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white54), // Border color when enabled
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // Border color when focused
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildDateRangePicker(context),
            SizedBox(height: 20),
            _buildDropdown('플러시', '모든 Policy'),
            SizedBox(height: 20),
            _buildDropdown('카테고리', '모든 카테고리'),
            SizedBox(height: 20),
            _buildDropdown('지출방법', '모든 지출 방법'),
            SizedBox(height: 20),
            _buildDropdown('지출 상태별', '내 지출'),
            SizedBox(height: 20),
            _buildExpenseRefundButtons(),
            SizedBox(height: 20),
            _buildRegulationButtons(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Apply filter logic
                },
                child: Text('필터 적용'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF10D9B5),
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDatePicker(context, '2024.07.01'),
        Text(
          ' ㅡ ',
          style: TextStyle(color: Colors.white),
        ),
        _buildDatePicker(context, '2024.08.29'),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String date) {
    return InkWell(
      onTap: () {
        // Date picker logic
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.white),
            SizedBox(width: 10),
            Text(
              date,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value) {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8), // Space between the label and the dropdown
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white54),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(color: Colors.white),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseRefundButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '경비 환급',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isExpenseRefundAllActive = true;
                  });
                },
                child: Text('모두'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpenseRefundAllActive
                      ? Color(0xFF10D9B5)
                      : Color(0xFF007792),
                  foregroundColor: Colors.white,
                  minimumSize:
                      Size(double.infinity, 56), // Set the height to 37px
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: isExpenseRefundAllActive
                          ? Color(0xFF10D9B5)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isExpenseRefundAllActive = false;
                  });
                },
                child: Text('경비 환급'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isExpenseRefundAllActive
                      ? Color(0xFF10D9B5)
                      : Color(0xFF007792),
                  foregroundColor: Colors.white,
                  minimumSize:
                      Size(double.infinity, 56), // Set the height to 37px
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: !isExpenseRefundAllActive
                          ? Color(0xFF10D9B5)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegulationButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '규정',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isComplianceActive = true;
                  });
                },
                child: Text('준수'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isComplianceActive == true
                      ? Color(0xFF10D9B5)
                      : Color(0xFF007792),
                  foregroundColor: Colors.white,
                  minimumSize:
                      Size(double.infinity, 56), // Set the height to 37px
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: isComplianceActive == true
                          ? Color(0xFF10D9B5)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isComplianceActive = false;
                  });
                },
                child: Text('위반'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isComplianceActive == false
                      ? Color(0xFF10D9B5)
                      : Color(0xFF007792),
                  foregroundColor: Colors.white,
                  minimumSize:
                      Size(double.infinity, 56), // Set the height to 37px
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: isComplianceActive == false
                          ? Color(0xFF10D9B5)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
