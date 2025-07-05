import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/features/quotes/data/local_quote_data_source.dart';
import 'package:qine_corner/features/quotes/data/quote_repository.dart';
import 'package:qine_corner/features/quotes/data/quote_repository_impl.dart';
import 'package:qine_corner/features/quotes/domain/models/quote.dart';
import 'package:qine_corner/core/services/quote_service.dart';

final quoteRepositoryProvider = Provider<QuoteRepository>(
  (ref) => QuoteRepositoryImpl(
    LocalQuoteDataSource(),
    ref.read(quoteServiceProvider),
  ),
);

final quoteNotifierProvider = StateNotifierProvider<
    QuoteNotifier, AsyncValue<List<Quote>>>((ref) {
  final repository = ref.watch(quoteRepositoryProvider);
  return QuoteNotifier(repository);
});

class QuoteNotifier extends StateNotifier<AsyncValue<List<Quote>>> {
  final QuoteRepository _repository;

  QuoteNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    try {
      final quotes = await _repository.getQuotes();
      state = AsyncValue.data(quotes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addQuote(Quote quote) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addQuote(quote);
      await _loadQuotes(); // Reload to get the updated list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteQuote(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteQuote(id);
      await _loadQuotes(); // Reload to get the updated list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearQuotes() async {
    state = const AsyncValue.loading();
    try {
      await _repository.clearQuotes();
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
