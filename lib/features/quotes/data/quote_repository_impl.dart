import 'package:qine_corner/features/quotes/data/local_quote_data_source.dart';
import 'package:qine_corner/features/quotes/data/quote_repository.dart';
import 'package:qine_corner/features/quotes/domain/models/quote.dart';
import 'package:qine_corner/core/services/quote_service.dart';

class QuoteRepositoryImpl implements QuoteRepository {
  final LocalQuoteDataSource _localDataSource;
  final QuoteService _quoteService;

  QuoteRepositoryImpl(this._localDataSource, this._quoteService);

  @override
  Future<List<Quote>> getQuotes() {
    return _localDataSource.getQuotes();
  }

  @override
  Future<void> addQuote(Quote quote) async {
    await _localDataSource.addQuote(quote);
    // Attempt to sync to backend, but don't block if it fails
    try {
      await _quoteService.syncQuote(quote);
    } catch (e) {
      // Log error or handle it as per app's error handling policy
      print('Failed to sync quote to backend: $e');
    }
  }

  @override
  Future<void> deleteQuote(String id) {
    return _localDataSource.deleteQuote(id);
  }

  @override
  Future<void> clearQuotes() {
    return _localDataSource.clearQuotes();
  }
}