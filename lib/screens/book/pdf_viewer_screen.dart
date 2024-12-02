import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../core/models/book.dart';
import '../../core/theme/app_colors.dart';
import '../../common/widgets/loading_animation.dart';
import '../../screens/error/widgets/animated_error_widget.dart';

class PdfViewerScreen extends StatefulWidget {
  final Book book;

  const PdfViewerScreen({
    super.key,
    required this.book,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  double _zoomLevel = 1.0;
  int _currentPage = 1;
  int _totalPages = 0;
  final TextEditingController _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    _pdfViewerController.zoomLevel = _zoomLevel + 0.25;
    setState(() {
      _zoomLevel = _pdfViewerController.zoomLevel;
    });
  }

  void _zoomOut() {
    if (_zoomLevel > 1.0) {
      _pdfViewerController.zoomLevel = _zoomLevel - 0.25;
      setState(() {
        _zoomLevel = _pdfViewerController.zoomLevel;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _pdfViewerController.nextPage();
      setState(() {
        _currentPage = _pdfViewerController.pageNumber;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _pdfViewerController.previousPage();
      setState(() {
        _currentPage = _pdfViewerController.pageNumber;
      });
    }
  }

  void _showGoToPageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        _pageController.text = _currentPage.toString();
        return AlertDialog(
          title: const Text('Go to Page'),
          content: TextField(
            controller: _pageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter page number (1-$_totalPages)',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final pageNumber = int.tryParse(_pageController.text);
                if (pageNumber != null &&
                    pageNumber >= 1 &&
                    pageNumber <= _totalPages) {
                  _pdfViewerController.jumpToPage(pageNumber);
                  setState(() {
                    _currentPage = pageNumber;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Go'),
            ),
          ],
        );
      },
    ).then((_) => _pageController.clear());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: isDark
            ? AppColors.darkSurfaceBackground
            : AppColors.lightSurfaceBackground,
        actions: [
          // Zoom controls and page navigation
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: _zoomOut,
              ),
              Text(
                '${(_zoomLevel * 100).toInt()}%',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: _zoomIn,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _previousPage,
              ),
              GestureDetector(
                onTap: _showGoToPageDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkTextPrimary.withOpacity(0.5)
                          : AppColors.lightTextPrimary.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$_currentPage / $_totalPages',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _nextPage,
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_hasError)
            Center(
              child: AnimatedErrorWidget(
                message: 'Error loading PDF!',
                onRetry: () {
                  setState(() {
                    _hasError = false;
                    _isLoading = true;
                  });
                },
              ),
            )
          else
            SfPdfViewer.asset(
              widget.book.filePath,
              controller: _pdfViewerController,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                setState(() {
                  _hasError = true;
                  _errorMessage = details.error;
                  _isLoading = false;
                });
              },
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                setState(() {
                  _isLoading = false;
                  _totalPages = details.document.pages.count;
                });
              },
              canShowPaginationDialog: false,
              enableDoubleTapZooming: true,
              initialScrollOffset: const Offset(0, 0),
              pageSpacing: 8,
              onPageChanged: (PdfPageChangedDetails details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
              },
            ),
          if (_isLoading)
            const Center(
              child: LoadingAnimation(),
            ),
        ],
      ),
    );
  }
}
