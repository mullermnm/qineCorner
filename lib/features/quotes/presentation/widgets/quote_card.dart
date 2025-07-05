import 'package:flutter/material.dart';
import 'package:qine_corner/features/quotes/domain/models/quote.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final String templateId;

  const QuoteCard({
    Key? key,
    required this.quote,
    this.templateId = 'default',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (templateId) {
      case 'bold':
        content = _buildBoldTemplate(context);
        break;
      case 'calm':
        content = _buildCalmTemplate(context);
        break;
      case 'dark':
        content = _buildDarkTemplate(context);
        break;
      case 'poetic':
        content = _buildPoeticTemplate(context);
        break;
      case 'minimalist':
        content = _buildMinimalistTemplate(context);
        break;
      default:
        content = _buildDefaultTemplate(context);
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }

  Widget _buildDefaultTemplate(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${quote.text}"',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 16.0),
          if (quote.authorName != null || quote.bookTitle != null)
            Text(
              '— ${quote.authorName ?? 'Unknown'}${quote.bookTitle != null ? ', ${quote.bookTitle}' : ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
            ),
          if (quote.userName != null)
            Text(
              'Shared by: ${quote.userName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black45,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildBoldTemplate(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.deepPurple.shade700,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '"${quote.text}"',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(3.0, 3.0),
                    ),
                  ],
                ),
          ),
          const SizedBox(height: 24.0),
          if (quote.authorName != null || quote.bookTitle != null)
            Text(
              '— ${quote.authorName ?? 'Unknown'}${quote.bookTitle != null ? ', ${quote.bookTitle}' : ''}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          if (quote.userName != null)
            Text(
              'Shared by: ${quote.userName}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalmTemplate(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300, width: 2.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${quote.text}"',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'serif', // Example of a custom font
                  color: Colors.grey.shade800,
                ),
          ),
          const SizedBox(height: 16.0),
          if (quote.authorName != null || quote.bookTitle != null)
            Text(
              '— ${quote.authorName ?? 'Unknown'}${quote.bookTitle != null ? ', ${quote.bookTitle}' : ''}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          if (quote.userName != null)
            Text(
              'Shared by: ${quote.userName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildDarkTemplate(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${quote.text}"',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 16.0),
          if (quote.authorName != null || quote.bookTitle != null)
            Text(
              '— ${quote.authorName ?? 'Unknown'}${quote.bookTitle != null ? ', ${quote.bookTitle}' : ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          if (quote.userName != null)
            Text(
              'Shared by: ${quote.userName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildPoeticTemplate(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade200, Colors.pink.shade200],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '"${quote.text}"',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'PlayfairDisplay', // Example of a custom font
                  color: Colors.purple.shade900,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 20.0),
          if (quote.authorName != null || quote.bookTitle != null)
            Text(
              '— ${quote.authorName ?? 'Unknown'}${quote.bookTitle != null ? ', ${quote.bookTitle}' : ''}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'PlayfairDisplay',
                    color: Colors.purple.shade700,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          if (quote.userName != null)
            Text(
              'Shared by: ${quote.userName}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.purple.shade600,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildMinimalistTemplate(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${quote.text}"',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 16.0),
          if (quote.authorName != null || quote.bookTitle != null)
            Text(
              '— ${quote.authorName ?? 'Unknown'}${quote.bookTitle != null ? ', ${quote.bookTitle}' : ''}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
            ),
          if (quote.userName != null)
            Text(
              'Shared by: ${quote.userName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
        ],
      ),
    );
  }
}
