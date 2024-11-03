import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const OptionTile({required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 외부에서 onTap을 주입
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                )
              ],
            ),
            // Optional Trailing Widget Row
            if (trailing != null) ...[
              SizedBox(height: 8), // Spacing between title and trailing
              Row(
                children: [
                  trailing!,
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
