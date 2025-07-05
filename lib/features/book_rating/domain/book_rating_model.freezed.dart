// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_rating_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BookRating _$BookRatingFromJson(Map<String, dynamic> json) {
  return _BookRating.fromJson(json);
}

/// @nodoc
mixin _$BookRating {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get bookId => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  String? get review => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;
  String? get userProfileImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BookRating to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookRatingCopyWith<BookRating> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookRatingCopyWith<$Res> {
  factory $BookRatingCopyWith(
          BookRating value, $Res Function(BookRating) then) =
      _$BookRatingCopyWithImpl<$Res, BookRating>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String bookId,
      double rating,
      String? review,
      String? userName,
      String? userProfileImage,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$BookRatingCopyWithImpl<$Res, $Val extends BookRating>
    implements $BookRatingCopyWith<$Res> {
  _$BookRatingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bookId = null,
    Object? rating = null,
    Object? review = freezed,
    Object? userName = freezed,
    Object? userProfileImage = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      bookId: null == bookId
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      review: freezed == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userProfileImage: freezed == userProfileImage
          ? _value.userProfileImage
          : userProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookRatingImplCopyWith<$Res>
    implements $BookRatingCopyWith<$Res> {
  factory _$$BookRatingImplCopyWith(
          _$BookRatingImpl value, $Res Function(_$BookRatingImpl) then) =
      __$$BookRatingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String bookId,
      double rating,
      String? review,
      String? userName,
      String? userProfileImage,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$BookRatingImplCopyWithImpl<$Res>
    extends _$BookRatingCopyWithImpl<$Res, _$BookRatingImpl>
    implements _$$BookRatingImplCopyWith<$Res> {
  __$$BookRatingImplCopyWithImpl(
      _$BookRatingImpl _value, $Res Function(_$BookRatingImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bookId = null,
    Object? rating = null,
    Object? review = freezed,
    Object? userName = freezed,
    Object? userProfileImage = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BookRatingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      bookId: null == bookId
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      review: freezed == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userProfileImage: freezed == userProfileImage
          ? _value.userProfileImage
          : userProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookRatingImpl implements _BookRating {
  const _$BookRatingImpl(
      {required this.id,
      required this.userId,
      required this.bookId,
      required this.rating,
      this.review,
      this.userName,
      this.userProfileImage,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$BookRatingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookRatingImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String bookId;
  @override
  final double rating;
  @override
  final String? review;
  @override
  final String? userName;
  @override
  final String? userProfileImage;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BookRating(id: $id, userId: $userId, bookId: $bookId, rating: $rating, review: $review, userName: $userName, userProfileImage: $userProfileImage, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookRatingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.review, review) || other.review == review) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userProfileImage, userProfileImage) ||
                other.userProfileImage == userProfileImage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, bookId, rating,
      review, userName, userProfileImage, createdAt, updatedAt);

  /// Create a copy of BookRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookRatingImplCopyWith<_$BookRatingImpl> get copyWith =>
      __$$BookRatingImplCopyWithImpl<_$BookRatingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookRatingImplToJson(
      this,
    );
  }
}

abstract class _BookRating implements BookRating {
  const factory _BookRating(
          {required final String id,
          required final String userId,
          required final String bookId,
          required final double rating,
          final String? review,
          final String? userName,
          final String? userProfileImage,
          @JsonKey(name: 'created_at') required final DateTime? createdAt,
          @JsonKey(name: 'updated_at') required final DateTime? updatedAt}) =
      _$BookRatingImpl;

  factory _BookRating.fromJson(Map<String, dynamic> json) =
      _$BookRatingImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get bookId;
  @override
  double get rating;
  @override
  String? get review;
  @override
  String? get userName;
  @override
  String? get userProfileImage;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of BookRating
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookRatingImplCopyWith<_$BookRatingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
