// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MilestoneImpl _$$MilestoneImplFromJson(Map<String, dynamic> json) =>
    _$MilestoneImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      achievedDate: DateTime.parse(json['achievedDate'] as String),
      type: json['type'] as String,
      imageUrl: json['imageUrl'] as String?,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$$MilestoneImplToJson(_$MilestoneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'achievedDate': instance.achievedDate.toIso8601String(),
      'type': instance.type,
      'imageUrl': instance.imageUrl,
      'userId': instance.userId,
    };
