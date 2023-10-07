import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';

class Cat extends StatefulWidget {
  final String pdfUrl;
  Cat(this.pdfUrl, {Key key}) : super(key: key);

  @override
  State<Cat> createState() => _Cat();
}

class _Cat extends State<Cat> {
  bool _isLoading = true;
  PDFDocument document;
  DownloadProgress downloadProgress;

  @override
  void initState() {
    loadDocument();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void loadDocument() async {
    /// Clears the cache before download, so [PDFDocument.fromURLWithDownloadProgress.downloadProgress()]
    /// is always executed (meant only for testing).
    await DefaultCacheManager().emptyCache();

    PDFDocument.fromURLWithDownloadProgress(
      widget.pdfUrl,
      downloadProgress: (downloadProgress) => setState(() {
        this.downloadProgress = downloadProgress;
      }),
      onDownloadComplete: (document) => setState(() {
        this.document = document;
        _isLoading = false;
      }),
      cacheManager: CacheManager(
        Config(
          "customCacheKey",
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 30,
        ),
      ),
    );
  }

  Widget buildProgress() {
    if (downloadProgress == null) return SizedBox();

    String parseBytesToKBs(int bytes) {
      if (bytes == null) return '0 KBs';

      return '${(bytes / 1000).toStringAsFixed(2)} KBs';
    }

    String progressString = parseBytesToKBs(downloadProgress.downloaded);
    if (downloadProgress.totalSize != null) {
      progressString += '/ ${parseBytesToKBs(downloadProgress.totalSize)}';
    }

    return Column(
      children: [
        SizedBox(height: 20),
        Text(progressString),
      ],
    );
  }

  /* changePDF(value) async {
    setState(() => _isLoading = true);
    if (value == 1) {
      document = await PDFDocument.fromAsset('assets/sample2.pdf');
    } else if (value == 2) {
      document = await PDFDocument.fromURL(
        "https://www.africau.edu/images/default/sample.pdf",
        cacheManager: CacheManager(
          Config(
            "customCacheKey",
            stalePeriod: const Duration(days: 10),
            maxNrOfCacheObjects: 10,
          ),
        ),
      );
    } else {
      document = await PDFDocument.fromAsset('assets/sample.pdf');
    }
    setState(() => _isLoading = false);
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الكتالوج'),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    buildProgress(),
                  ],
                ),
              )
            : PDFViewer(
                pickerIconColor: Colors.white,
                document: document,
                maxScale: 3.0,
                minScale: 1.0,
                scrollDirection: Axis.horizontal,
                showPicker: true,
                showIndicator: true,
                panLimit: 5.0,
                enableSwipeNavigation: true,
                numberPickerConfirmWidget: const Icon(
                  GroovinMaterialIcons.check_circle_outline,
                  color: Colors.green,
                  size: 32,
                ),
              ),
      ),
    );
  }
}
