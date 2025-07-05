import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote.freezed.dart';
part 'quote.g.dart';

@freezed
class Quote with _$Quote {
  const factory Quote({
    required String id,
    required String text,
    String? bookTitle,
    String? authorName,
    String? userName,
    required DateTime createdAt,
    @Default('default') String templateId,
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}
