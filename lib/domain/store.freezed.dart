// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Store {

 int get addressId; String get name; String? get address; String? get city; String? get province;
/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCopyWith<Store> get copyWith => _$StoreCopyWithImpl<Store>(this as Store, _$identity);

  /// Serializes this Store to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Store;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Store&&(identical(other.addressId, _this.addressId) || other.addressId == _this.addressId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.province, _this.province) || other.province == _this.province));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Store;
  return Object.hash(runtimeType,_this.addressId,_this.name,_this.address,_this.city,_this.province);
}

@override
String toString() {
  final _this = this as Store;
  return 'Store(addressId: ${_this.addressId}, name: ${_this.name}, address: ${_this.address}, city: ${_this.city}, province: ${_this.province})';
}


}

/// @nodoc
abstract mixin class $StoreCopyWith<$Res>  {
  factory $StoreCopyWith(Store value, $Res Function(Store) _then) = _$StoreCopyWithImpl;
@useResult
$Res call({
 int addressId, String name, String? address, String? city, String? province
});




}
/// @nodoc
class _$StoreCopyWithImpl<$Res>
    implements $StoreCopyWith<$Res> {
  _$StoreCopyWithImpl(this._self, this._then);

  final Store _self;
  final $Res Function(Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addressId = null,Object? name = null,Object? address = freezed,Object? city = freezed,Object? province = freezed,}) {
  return _then(Store(
addressId: null == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Store].
extension StorePatterns on Store {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Store value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Store value)  $default,){
final _that = this;
switch (_that) {
case _Store():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Store value)?  $default,){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int addressId,  String name,  String? address,  String? city,  String? province)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.addressId,_that.name,_that.address,_that.city,_that.province);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int addressId,  String name,  String? address,  String? city,  String? province)  $default,) {final _that = this;
switch (_that) {
case _Store():
return $default(_that.addressId,_that.name,_that.address,_that.city,_that.province);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int addressId,  String name,  String? address,  String? city,  String? province)?  $default,) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.addressId,_that.name,_that.address,_that.city,_that.province);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Store extends Store {
  const _Store({required this.addressId, required this.name, this.address, this.city, this.province}): super._();
  factory _Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

@override final  int addressId;
@override final  String name;
@override final  String? address;
@override final  String? city;
@override final  String? province;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCopyWith<_Store> get copyWith => __$StoreCopyWithImpl<_Store>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Store&&(identical(other.addressId, addressId) || other.addressId == addressId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.province, province) || other.province == province));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,addressId,name,address,city,province);
}

@override
String toString() {
    return 'Store(addressId: $addressId, name: $name, address: $address, city: $city, province: $province)';
}


}

/// @nodoc
abstract mixin class _$StoreCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$StoreCopyWith(_Store value, $Res Function(_Store) _then) = __$StoreCopyWithImpl;
@override @useResult
$Res call({
 int addressId, String name, String? address, String? city, String? province
});




}
/// @nodoc
class __$StoreCopyWithImpl<$Res>
    implements _$StoreCopyWith<$Res> {
  __$StoreCopyWithImpl(this._self, this._then);

  final _Store _self;
  final $Res Function(_Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addressId = null,Object? name = null,Object? address = freezed,Object? city = freezed,Object? province = freezed,}) {
  return _then(_Store(
addressId: null == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CartAddress {

 int get addressId; String? get addressName; String? get addressType; int? get deliveryServiceId;
/// Create a copy of CartAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartAddressCopyWith<CartAddress> get copyWith => _$CartAddressCopyWithImpl<CartAddress>(this as CartAddress, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CartAddress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartAddress&&(identical(other.addressId, _this.addressId) || other.addressId == _this.addressId)&&(identical(other.addressName, _this.addressName) || other.addressName == _this.addressName)&&(identical(other.addressType, _this.addressType) || other.addressType == _this.addressType)&&(identical(other.deliveryServiceId, _this.deliveryServiceId) || other.deliveryServiceId == _this.deliveryServiceId));
}


@override
int get hashCode {
  final _this = this as CartAddress;
  return Object.hash(runtimeType,_this.addressId,_this.addressName,_this.addressType,_this.deliveryServiceId);
}

@override
String toString() {
  final _this = this as CartAddress;
  return 'CartAddress(addressId: ${_this.addressId}, addressName: ${_this.addressName}, addressType: ${_this.addressType}, deliveryServiceId: ${_this.deliveryServiceId})';
}


}

/// @nodoc
abstract mixin class $CartAddressCopyWith<$Res>  {
  factory $CartAddressCopyWith(CartAddress value, $Res Function(CartAddress) _then) = _$CartAddressCopyWithImpl;
@useResult
$Res call({
 int addressId, String? addressName, String? addressType, int? deliveryServiceId
});




}
/// @nodoc
class _$CartAddressCopyWithImpl<$Res>
    implements $CartAddressCopyWith<$Res> {
  _$CartAddressCopyWithImpl(this._self, this._then);

  final CartAddress _self;
  final $Res Function(CartAddress) _then;

/// Create a copy of CartAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addressId = null,Object? addressName = freezed,Object? addressType = freezed,Object? deliveryServiceId = freezed,}) {
  return _then(CartAddress(
addressId: null == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as int,addressName: freezed == addressName ? _self.addressName : addressName // ignore: cast_nullable_to_non_nullable
as String?,addressType: freezed == addressType ? _self.addressType : addressType // ignore: cast_nullable_to_non_nullable
as String?,deliveryServiceId: freezed == deliveryServiceId ? _self.deliveryServiceId : deliveryServiceId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CartAddress].
extension CartAddressPatterns on CartAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartAddress value)  $default,){
final _that = this;
switch (_that) {
case _CartAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartAddress value)?  $default,){
final _that = this;
switch (_that) {
case _CartAddress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int addressId,  String? addressName,  String? addressType,  int? deliveryServiceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartAddress() when $default != null:
return $default(_that.addressId,_that.addressName,_that.addressType,_that.deliveryServiceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int addressId,  String? addressName,  String? addressType,  int? deliveryServiceId)  $default,) {final _that = this;
switch (_that) {
case _CartAddress():
return $default(_that.addressId,_that.addressName,_that.addressType,_that.deliveryServiceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int addressId,  String? addressName,  String? addressType,  int? deliveryServiceId)?  $default,) {final _that = this;
switch (_that) {
case _CartAddress() when $default != null:
return $default(_that.addressId,_that.addressName,_that.addressType,_that.deliveryServiceId);case _:
  return null;

}
}

}

/// @nodoc


class _CartAddress implements CartAddress {
  const _CartAddress({required this.addressId, this.addressName, this.addressType, this.deliveryServiceId});
  

@override final  int addressId;
@override final  String? addressName;
@override final  String? addressType;
@override final  int? deliveryServiceId;

/// Create a copy of CartAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartAddressCopyWith<_CartAddress> get copyWith => __$CartAddressCopyWithImpl<_CartAddress>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartAddress&&(identical(other.addressId, addressId) || other.addressId == addressId)&&(identical(other.addressName, addressName) || other.addressName == addressName)&&(identical(other.addressType, addressType) || other.addressType == addressType)&&(identical(other.deliveryServiceId, deliveryServiceId) || other.deliveryServiceId == deliveryServiceId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,addressId,addressName,addressType,deliveryServiceId);
}

@override
String toString() {
    return 'CartAddress(addressId: $addressId, addressName: $addressName, addressType: $addressType, deliveryServiceId: $deliveryServiceId)';
}


}

/// @nodoc
abstract mixin class _$CartAddressCopyWith<$Res> implements $CartAddressCopyWith<$Res> {
  factory _$CartAddressCopyWith(_CartAddress value, $Res Function(_CartAddress) _then) = __$CartAddressCopyWithImpl;
@override @useResult
$Res call({
 int addressId, String? addressName, String? addressType, int? deliveryServiceId
});




}
/// @nodoc
class __$CartAddressCopyWithImpl<$Res>
    implements _$CartAddressCopyWith<$Res> {
  __$CartAddressCopyWithImpl(this._self, this._then);

  final _CartAddress _self;
  final $Res Function(_CartAddress) _then;

/// Create a copy of CartAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addressId = null,Object? addressName = freezed,Object? addressType = freezed,Object? deliveryServiceId = freezed,}) {
  return _then(_CartAddress(
addressId: null == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as int,addressName: freezed == addressName ? _self.addressName : addressName // ignore: cast_nullable_to_non_nullable
as String?,addressType: freezed == addressType ? _self.addressType : addressType // ignore: cast_nullable_to_non_nullable
as String?,deliveryServiceId: freezed == deliveryServiceId ? _self.deliveryServiceId : deliveryServiceId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
