import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_rating_model.freezed.dart';
part 'book_rating_model.g.dart';

@freezed
class BookRating with _$BookRating {
  const factory BookRating({
    required String id,
    required String userId,
    required String bookId,
    required double rating,
    String? review,
    String? userName,
    String? userProfileImage,
    required DateTime? createdAt,
    required DateTime? updatedAt,
  }) = _BookRating;

  factory BookRating.fromJson(Map<String, dynamic> json) =>
      _$BookRatingFromJson(json);
}
