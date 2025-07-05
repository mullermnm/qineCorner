// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'milestone_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Milestone _$MilestoneFromJson(Map<String, dynamic> json) {
  return _Milestone.fromJson(json);
}

/// @nodoc
mixin _$Milestone {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get achievedDate => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;

  /// Serializes this Milestone to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MilestoneCopyWith<Milestone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MilestoneCopyWith<$Res> {
  factory $MilestoneCopyWith(Milestone value, $Res Function(Milestone) then) =
      _$MilestoneCopyWithImpl<$Res, Milestone>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      DateTime achievedDate,
      String type,
      String? imageUrl,
      String? userId});
}

/// @nodoc
class _$MilestoneCopyWithImpl<$Res, $Val extends Milestone>
    implements $MilestoneCopyWith<$Res> {
  _$MilestoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? achievedDate = null,
    Object? type = null,
    Object? imageUrl = freezed,
    Object? userId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      achievedDate: null == achievedDate
          ? _value.achievedDate
          : achievedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MilestoneImplCopyWith<$Res>
    implements $MilestoneCopyWith<$Res> {
  factory _$$MilestoneImplCopyWith(
          _$MilestoneImpl value, $Res Function(_$MilestoneImpl) then) =
      __$$MilestoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      DateTime achievedDate,
      String type,
      String? imageUrl,
      String? userId});
}

/// @nodoc
class __$$MilestoneImplCopyWithImpl<$Res>
    extends _$MilestoneCopyWithImpl<$Res, _$MilestoneImpl>
    implements _$$MilestoneImplCopyWith<$Res> {
  __$$MilestoneImplCopyWithImpl(
      _$MilestoneImpl _value, $Res Function(_$MilestoneImpl) _then)
      : super(_value, _then);

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? achievedDate = null,
    Object? type = null,
    Object? imageUrl = freezed,
    Object? userId = freezed,
  }) {
    return _then(_$MilestoneImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      achievedDate: null == achievedDate
          ? _value.achievedDate
          : achievedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MilestoneImpl implements _Milestone {
  const _$MilestoneImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.achievedDate,
      required this.type,
      this.imageUrl,
      this.userId});

  factory _$MilestoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$MilestoneImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final DateTime achievedDate;
  @override
  final String type;
  @override
  final String? imageUrl;
  @override
  final String? userId;

  @override
  String toString() {
    return 'Milestone(id: $id, name: $name, description: $description, achievedDate: $achievedDate, type: $type, imageUrl: $imageUrl, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MilestoneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.achievedDate, achievedDate) ||
                other.achievedDate == achievedDate) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, description, achievedDate, type, imageUrl, userId);

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MilestoneImplCopyWith<_$MilestoneImpl> get copyWith =>
      __$$MilestoneImplCopyWithImpl<_$MilestoneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MilestoneImplToJson(
      this,
    );
  }
}

abstract class _Milestone implements Milestone {
  const factory _Milestone(
      {required final String id,
      required final String name,
      required final String description,
      required final DateTime achievedDate,
      required final String type,
      final String? imageUrl,
      final String? userId}) = _$MilestoneImpl;

  factory _Milestone.fromJson(Map<String, dynamic> json) =
      _$MilestoneImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  DateTime get achievedDate;
  @override
  String get type;
  @override
  String? get imageUrl;
  @override
  String? get userId;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MilestoneImplCopyWith<_$MilestoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
