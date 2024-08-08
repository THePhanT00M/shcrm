import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool isExpenseRefundAllActive = true;
  bool? isComplianceActive;
  DateTime startDate = DateTime.now().subtract(Duration(days: 90));
  DateTime endDate = DateTime.now();

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
            SizedBox(width: 48),
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
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFF007792),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '검색어를 입력해주세요.',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildDateRangePicker('기간', context),
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
      ),
    );
  }

  Widget _buildDateRangePicker(String label, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDatePicker(context, startDate, (selectedDate) {
              setState(() {
                startDate = selectedDate;
              });
            }),
            Text(
              ' ㅡ ',
              style: TextStyle(color: Colors.white),
            ),
            _buildDatePicker(context, endDate, (selectedDate) {
              setState(() {
                endDate = selectedDate;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, DateTime date,
      ValueChanged<DateTime> onDateSelected) {
    return GestureDetector(
      onTap: () async {
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Colors.blue,
                    ),
                  ),
                ),
                colorScheme: ColorScheme.light(
                  onPrimary: Colors.white,
                  primary: Colors.blue,
                  background: Colors.white,
                ),
                datePickerTheme: DatePickerThemeData(
                  headerBackgroundColor: Colors.blue,
                  backgroundColor: Colors.white,
                  headerForegroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  dividerColor: Colors.blue,
                ),
              ),
              child: child!,
            );
          },
        );

        if (selectedDate != null && selectedDate != date) {
          onDateSelected(selectedDate);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.40, // 너비를 45%로 설정
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white54),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
            children: [
              Text(
                value,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center, // Text 위젯 가운데 정렬
              ),
              // Icon(Icons.arrow_drop_down, color: Colors.white),
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
                  minimumSize: Size(double.infinity, 56),
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
                  minimumSize: Size(double.infinity, 56),
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
                  minimumSize: Size(double.infinity, 56),
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
                  minimumSize: Size(double.infinity, 56),
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
