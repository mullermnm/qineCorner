// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuoteImpl _$$QuoteImplFromJson(Map<String, dynamic> json) => _$QuoteImpl(
      id: json['id'] as String,
      text: json['text'] as String,
      bookTitle: json['bookTitle'] as String?,
      authorName: json['authorName'] as String?,
      userName: json['userName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      templateId: json['templateId'] as String? ?? 'default',
    );

Map<String, dynamic> _$$QuoteImplToJson(_$QuoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'bookTitle': instance.bookTitle,
      'authorName': instance.authorName,
      'userName': instance.userName,
      'createdAt': instance.createdAt.toIso8601String(),
      'templateId': instance.templateId,
    };
