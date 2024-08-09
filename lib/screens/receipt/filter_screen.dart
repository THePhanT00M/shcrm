import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool isExpenseRefundAllActive = true;
  bool? isComplianceActive;
  bool isFilterButtonEnabled = false; // 필터 적용 버튼 활성화 상태 관리
  DateTime startDate = DateTime.now().subtract(Duration(days: 90));
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF007792),
      appBar: AppBar(
        backgroundColor: Color(0xFF007792),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                '지출',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              right: 0, // 오른쪽에 위치
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Color(0xFF007792),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 49, // 전체 TextField의 높이를 49px로 설정
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '검색어를 입력해주세요.',
                        hintStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 10), // 아이콘 왼쪽에 20px 패딩 추가
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14), // 패딩을 조정하여 높이를 맞춤
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
                  _buildExpenseReportButtons(),
                  SizedBox(height: 20),
                  _buildRegulationButtons(),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: isFilterButtonEnabled
                    ? () {
                        // Apply filter logic
                      }
                    : null, // 버튼 비활성화 처리
                child: Text(
                  '필터 적용',
                  style: TextStyle(
                    color: Colors.white, // 텍스트 색을 화이트로 설정
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF10D9B5), // 비활성화 상태에서는 #000000
                  disabledBackgroundColor:
                      Color(0xFFCCCCCC), // 비활성화 상태의 배경색을 지정
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 버튼을 사각형 모양으로 설정
                  ),
                ),
              ),
            )
          ],
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
                style: TextStyle(
                  fontSize: 13.0,
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 13.0),
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

  Widget _buildExpenseReportButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '경비 환급',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
                  minimumSize: Size(double.infinity, 49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: isExpenseRefundAllActive == true
                          ? Color(0xFF10D9B5)
                          : Colors.white54,
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
                  backgroundColor: isExpenseRefundAllActive == false
                      ? Color(0xFF10D9B5)
                      : Color(0xFF007792),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: isExpenseRefundAllActive == false
                          ? Color(0xFF10D9B5)
                          : Colors.white54,
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
                    isFilterButtonEnabled = true; // 버튼 활성화
                  });
                },
                child: Text('준수'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isComplianceActive == true
                      ? Color(0xFF10D9B5)
                      : Color(0xFF007792),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: isComplianceActive == true
                          ? Color(0xFF10D9B5)
                          : Colors.white54,
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
                    isFilterButtonEnabled = true; // 버튼 활성화
                  });
                },
                child: Text('위반'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isComplianceActive == false
                      ? Color(0xFF10D9B5)
                      : Color(0xFF007792),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: isComplianceActive == false
                          ? Color(0xFF10D9B5)
                          : Colors.white54,
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
