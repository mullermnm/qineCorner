import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/features/quotes/domain/models/quote.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final quoteServiceProvider = Provider((ref) => QuoteService(ref.read(apiServiceProvider)));

class QuoteService {
  final ApiService _apiService;

  QuoteService(this._apiService);

  Future<void> syncQuote(Quote quote) async {
    try {
      // TODO: Implement actual API call to sync quote to backend
      // await _apiService.post('/quotes/sync', quote.toJson());
      print('Simulating quote sync to backend: ${quote.id}');
    } catch (e) {
      rethrow;
    }
  }
}