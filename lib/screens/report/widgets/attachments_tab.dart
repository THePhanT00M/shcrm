import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AttachmentsTab extends StatelessWidget {
  final List<PlatformFile> selectedFiles;
  final Future<void> Function() onPickFile;
  final Function(PlatformFile) onRemoveFile;
  final Future<void> Function() onRefresh;

  const AttachmentsTab({
    Key? key,
    required this.selectedFiles,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: Colors.white,
      color: Color(0xFF009EB4),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.grey[50],
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 3.0,
            ),
            width: double.infinity,
            child: Text(
              "첨부파일",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: const Color.fromARGB(255, 224, 224, 224),
                  width: 1.0,
                ),
                bottom: BorderSide(
                  color: const Color.fromARGB(255, 224, 224, 224),
                  width: 1.0,
                ),
              ),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              vertical: 3.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onPickFile,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: 45 * 3.1415926535897932 / 180,
                        child: Icon(
                          Icons.attach_file,
                          size: 13,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 3),
                      Text(
                        "파일 추가",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                ...selectedFiles.map((file) {
                  return ListTile(
                    leading: Icon(Icons.insert_drive_file),
                    title: Text(file.name),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onRemoveFile(file),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
