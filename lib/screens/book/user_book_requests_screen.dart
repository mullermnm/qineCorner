import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/models/book_request.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/services/book_request_service.dart';

class UserBookRequestsScreen extends ConsumerStatefulWidget {
  const UserBookRequestsScreen({super.key});

  @override
  ConsumerState<UserBookRequestsScreen> createState() => _UserBookRequestsScreenState();
}

class _UserBookRequestsScreenState extends ConsumerState<UserBookRequestsScreen> {
  List<BookRequest>? _requests;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final userId = ref.read(authNotifierProvider).whenOrNull(
        data: (state) => state?.userId,
      );

      if (userId == null) {
        setState(() {
          _error = 'Please login to view your requests';
          _isLoading = false;
        });
        return;
      }

      final requests = await ref.read(bookRequestServiceProvider).getUserRequests(userId);
      
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteRequest(String requestId) async {
    try {
      await ref.read(bookRequestServiceProvider).deleteRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request deleted successfully')),
      );
      _loadRequests(); // Reload the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Book Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _requests?.isEmpty ?? true
                  ? const Center(child: Text('No requests found'))
                  : RefreshIndicator(
                      onRefresh: _loadRequests,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _requests!.length,
                        itemBuilder: (context, index) {
                          final request = _requests![index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              title: Text(
                                request.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (request.author != null) ...[
                                    const SizedBox(height: 4),
                                    Text('Author: ${request.author}'),
                                  ],
                                  const SizedBox(height: 4),
                                  Text('Status: ${request.status}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Requested on: ${request.createdAt.toLocal().toString().split('.')[0]}',
                                    style: TextStyle(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: request.status.toLowerCase() == 'pending'
                                  ? IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Request'),
                                            content: const Text(
                                                'Are you sure you want to delete this request?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteRequest(request.id);
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
} 