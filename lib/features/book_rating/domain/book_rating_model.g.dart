// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookRatingImpl _$$BookRatingImplFromJson(Map<String, dynamic> json) =>
    _$BookRatingImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bookId: json['bookId'] as String,
      rating: (json['rating'] as num).toDouble(),
      review: json['review'] as String?,
      userName: json['userName'] as String?,
      userProfileImage: json['userProfileImage'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$BookRatingImplToJson(_$BookRatingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'bookId': instance.bookId,
      'rating': instance.rating,
      'review': instance.review,
      'userName': instance.userName,
      'userProfileImage': instance.userProfileImage,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
