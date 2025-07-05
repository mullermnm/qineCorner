import 'package:qine_corner/features/quotes/domain/models/quote.dart';

abstract class QuoteRepository {
  Future<List<Quote>> getQuotes();
  Future<void> addQuote(Quote quote);
  Future<void> deleteQuote(String id);
  Future<void> clearQuotes();
}