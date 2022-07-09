import 'package:dio/dio.dart';
import 'package:electricbills/helper/helper_func.dart';
import 'package:electricbills/widgets/buttons.dart';
import 'package:flutter/material.dart';

class DownloadFile extends StatefulWidget {
  final String url;
  final String filePath;
  const DownloadFile({Key? key, required this.url, required this.filePath})
      : super(key: key);

  @override
  State<DownloadFile> createState() => _DownloadFileState();
}

class _DownloadFileState extends State<DownloadFile> {
  double _progress = 0.0;
  bool _isDownloading = false;

  @override
  void initState() {
    Dio dio = Dio();
    dio.download(widget.url, widget.filePath,
        onReceiveProgress: (int received, int total) {
        setState(() {
          _progress = ((received / total) * 100);
          _isDownloading = true;
          if (_progress >= 100) {
            _isDownloading = false;
          }
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Downloading"),
      content: LinearProgressIndicator(
        value: _progress,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        backgroundColor: Colors.grey,
      ),
      actions: <Widget>[
        MyTextButton(
          label: Text(_isDownloading ? "Cancel" : "Done"),
          onPressed: () async {
            await openFile(widget.filePath);
          },
        ),
      ],
    );
  }
}
