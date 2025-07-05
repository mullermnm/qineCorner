import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qine_corner/features/quotes/data/quote_repository.dart';
import 'package:qine_corner/features/quotes/domain/models/quote.dart';

class LocalQuoteDataSource implements QuoteRepository {
  static const String _quotesKey = 'quotes';

  @override
  Future<List<Quote>> getQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? quotesJson = prefs.getStringList(_quotesKey);
    if (quotesJson == null) {
      return [];
    }
    return quotesJson
        .map((jsonString) => Quote.fromJson(json.decode(jsonString)))
        .toList();
  }

  @override
  Future<void> addQuote(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Quote> currentQuotes = await getQuotes();
    currentQuotes.add(quote);
    final List<String> updatedQuotesJson = currentQuotes
        .map((quote) => json.encode(quote.toJson()))
        .toList();
    await prefs.setStringList(_quotesKey, updatedQuotesJson);
  }

  @override
  Future<void> deleteQuote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<Quote> currentQuotes = await getQuotes();
    currentQuotes.removeWhere((quote) => quote.id == id);
    final List<String> updatedQuotesJson = currentQuotes
        .map((quote) => json.encode(quote.toJson()))
        .toList();
    await prefs.setStringList(_quotesKey, updatedQuotesJson);
  }

  @override
  Future<void> clearQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_quotesKey);
  }
}