// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PriceStore {

 Chain get chain;/// `addressId` del punto vendita; null = listino online della catena.
 int? get storeId; String get name; String? get address;
/// Create a copy of PriceStore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceStoreCopyWith<PriceStore> get copyWith => _$PriceStoreCopyWithImpl<PriceStore>(this as PriceStore, _$identity);

  /// Serializes this PriceStore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PriceStore;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceStore&&(identical(other.chain, _this.chain) || other.chain == _this.chain)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PriceStore;
  return Object.hash(runtimeType,_this.chain,_this.storeId,_this.name,_this.address);
}

@override
String toString() {
  final _this = this as PriceStore;
  return 'PriceStore(chain: ${_this.chain}, storeId: ${_this.storeId}, name: ${_this.name}, address: ${_this.address})';
}


}

/// @nodoc
abstract mixin class $PriceStoreCopyWith<$Res>  {
  factory $PriceStoreCopyWith(PriceStore value, $Res Function(PriceStore) _then) = _$PriceStoreCopyWithImpl;
@useResult
$Res call({
 Chain chain, int? storeId, String name, String? address
});




}
/// @nodoc
class _$PriceStoreCopyWithImpl<$Res>
    implements $PriceStoreCopyWith<$Res> {
  _$PriceStoreCopyWithImpl(this._self, this._then);

  final PriceStore _self;
  final $Res Function(PriceStore) _then;

/// Create a copy of PriceStore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chain = null,Object? storeId = freezed,Object? name = null,Object? address = freezed,}) {
  return _then(PriceStore(
chain: null == chain ? _self.chain : chain // ignore: cast_nullable_to_non_nullable
as Chain,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceStore].
extension PriceStorePatterns on PriceStore {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceStore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceStore() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceStore value)  $default,){
final _that = this;
switch (_that) {
case _PriceStore():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceStore value)?  $default,){
final _that = this;
switch (_that) {
case _PriceStore() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Chain chain,  int? storeId,  String name,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceStore() when $default != null:
return $default(_that.chain,_that.storeId,_that.name,_that.address);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Chain chain,  int? storeId,  String name,  String? address)  $default,) {final _that = this;
switch (_that) {
case _PriceStore():
return $default(_that.chain,_that.storeId,_that.name,_that.address);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Chain chain,  int? storeId,  String name,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _PriceStore() when $default != null:
return $default(_that.chain,_that.storeId,_that.name,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceStore extends PriceStore {
  const _PriceStore({required this.chain, this.storeId, required this.name, this.address}): super._();
  factory _PriceStore.fromJson(Map<String, dynamic> json) => _$PriceStoreFromJson(json);

@override final  Chain chain;
/// `addressId` del punto vendita; null = listino online della catena.
@override final  int? storeId;
@override final  String name;
@override final  String? address;

/// Create a copy of PriceStore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceStoreCopyWith<_PriceStore> get copyWith => __$PriceStoreCopyWithImpl<_PriceStore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceStoreToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceStore&&(identical(other.chain, chain) || other.chain == chain)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,chain,storeId,name,address);
}

@override
String toString() {
    return 'PriceStore(chain: $chain, storeId: $storeId, name: $name, address: $address)';
}


}

/// @nodoc
abstract mixin class _$PriceStoreCopyWith<$Res> implements $PriceStoreCopyWith<$Res> {
  factory _$PriceStoreCopyWith(_PriceStore value, $Res Function(_PriceStore) _then) = __$PriceStoreCopyWithImpl;
@override @useResult
$Res call({
 Chain chain, int? storeId, String name, String? address
});




}
/// @nodoc
class __$PriceStoreCopyWithImpl<$Res>
    implements _$PriceStoreCopyWith<$Res> {
  __$PriceStoreCopyWithImpl(this._self, this._then);

  final _PriceStore _self;
  final $Res Function(_PriceStore) _then;

/// Create a copy of PriceStore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chain = null,Object? storeId = freezed,Object? name = null,Object? address = freezed,}) {
  return _then(_PriceStore(
chain: null == chain ? _self.chain : chain // ignore: cast_nullable_to_non_nullable
as Chain,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
