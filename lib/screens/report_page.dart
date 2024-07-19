import 'package:flutter/material.dart';
import 'common/navigation_bar.dart'; // Import the new file

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Page'),
      ),
      body: Center(
        child: Text('This is the Report Page'),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        initialIndex: 1, // Set the initial index to 1
      ),
    );
  }
}
