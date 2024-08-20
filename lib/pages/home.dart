import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';
import '../api/api_services.dart';
import './variables.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _fullName = '';
  ApiService apiService = ApiService();

  late Widget centeredContent;
  late Widget button;
  late Widget loader;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeWidgets();
    _updateHandbook();
  }

  void _initializeWidgets() {
    button = ElevatedButton(
      onPressed: _loadAndReadHandbook,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorGreen,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        "Open Handbook",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );

    loader = LinearProgressIndicator(color: colorGreen);
    centeredContent = button;
  }

  Future<void> _loadUserData() async {
    final userData = await storage.read(key: 'user_data');
    if (userData != null) {
      final data = jsonDecode(userData);
      setState(() {
        _fullName = data['full_name'] ?? 'User';
      });
    }
  }

  void _logoutEvent() async {
    await apiService.logout();
    Navigator.pushNamed(context, "auth");
  }

  void _loadAndReadHandbook() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PdfViewerPage()),
    );
  }

  Future<void> _updateHandbook() async {
    setState(() {
      centeredContent = loader;
    });

    try {
      String? res = await Future.any([
        apiService.downloadPdf(),
        Future.delayed(Duration(seconds: 20), () => throw TimeoutException('Download took too long'))
      ]);

      if (res == "1" && mounted) {
        await storage.write(key: "databaseLastUpdate", value: DateTime.now().toString());
        _showToast('Handbook updated successfully', ToastificationType.success);
      } else {
        _showToast('Error: $res', ToastificationType.error);
      }
    } catch (e) {
      _showToast('Error: ${e.toString()}', ToastificationType.error);
    } finally {
      if (mounted) {
        setState(() {
          centeredContent = button;
        });
      }
    }
  }

  void _showToast(String message, ToastificationType type) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      style: ToastificationStyle.fillColored,
      backgroundColor: colorGreen,
      primaryColor: colorGreen,
      type: type,
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorGreen,
        title: Text("Hello, $_fullName", style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          IconButton(
            onPressed: _showAboutDialog,
            icon: const Icon(Icons.info_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: const DecorationImage(
              image: AssetImage('assets/nsuk2.png'),
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              opacity: 0.05
          ),
          color: Colors.black.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Expanded(child: Center(child: centeredContent)),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _logoutEvent,
                    icon: Transform.flip(flipX: true, child: const Icon(Icons.logout_rounded, color: Colors.red)),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "complaints");
                      },
                      child: Text("Log Complaints", style: TextStyle(color: colorGreen, fontSize: 16)),
                    ),
                  ),
                  IconButton(
                      onPressed: _updateHandbook,
                      icon: Row(
                        children: [
                          Text("Update", style: TextStyle(color: colorGreen)),
                          Icon(Icons.download, color: colorGreen),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() async {
    String databaseLastUpdate = await storage.read(key: "databaseLastUpdate") ?? "Not available";
    showAboutDialog(
        context: context,
        applicationIcon: Image.asset('assets/book.png'),
        applicationVersion: "1.1",
        applicationName: "CMP Handbook",
        children: [
          Text(
              "Developed by: \nDAMIAN PROSPER CHIMAOBI\n\nFor:\nComputer Science department, NSUK.\n\nHandbook last updated on:\n $databaseLastUpdate",
              style: TextStyle(color: colorGreen)
          )
        ]
    );
  }
}

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localFilePath;
  int currentPage = 0;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdfFromAssets();
  }

  Future<void> _loadPdfFromAssets() async {
    try {
      // final ByteData bytes = await DefaultAssetBundle.of(context).load('assets/handbook.pdf');
      // final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/handbook.pdf');
      // await file.writeAsBytes(list, flush: true);

      setState(() {
        localFilePath = file.path;
      });
    } catch (error) {
      print("Error loading PDF: $error");
    }
  }

  void _goToPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        _goToPage(currentPage);
      });
    }
  }

  void _goToNextPage() {
    if (currentPage < (totalPages - 1)) {
      setState(() {
        currentPage+=1;
        _goToPage(currentPage);
      });
    }
  }

  Future<void> _goToTop() async {
    if (_controller.getCurrentPage() != 0 ) {
      setState(() {
        _goToPage(0);
      });
    }
  }


  void _goToPage(int pageNumber) {
    _controller.setPage(pageNumber);
  }

  late final PDFViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios, color: colorGreen),
            ),
            Text(
              'Computer Science Handbook',
              style: TextStyle(color: colorGreen, fontSize: 18),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          localFilePath != null
              ? PDFView(
            filePath: localFilePath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: false,
            onRender: (pages) {
              setState(() {
                totalPages = pages ?? 0;
              });
              print('PDF rendered with $pages pages');
            },
            onError: (error) {
              print('PDF error: ${error.toString()}');
            },
            onPageError: (page, error) {
              print('Error on page $page: ${error.toString()}');
            },
            onViewCreated: (controller){
              _controller = controller;

            },
          )
              : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: LinearProgressIndicator(color: colorGreen),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _goToPreviousPage,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      foregroundColor: colorGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle
                        ),
                        child: Icon(Icons.arrow_back_ios)),
                  ),
                  ElevatedButton(
                    onPressed: _goToTop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: colorGreen,
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.keyboard_arrow_up_rounded),
                        Text("${currentPage+1} of $totalPages")
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _goToNextPage,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      foregroundColor: colorGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.arrow_forward_ios)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
