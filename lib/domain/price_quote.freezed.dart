// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_quote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PriceQuote {

/// Prezzo di vendita (a pezzo / confezione).
 double get price;/// Prezzo pieno, se il prodotto è in promozione.
 double? get listPrice;/// Prezzo al kg / l.
 double? get pricePerKg; PriceSource get source; DateTime get readAt;/// Catena a cui si riferisce il prezzo.
 Chain get chain;/// Punto vendita a cui si riferisce il prezzo (null = online/offline).
 int? get storeId;
/// Create a copy of PriceQuote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceQuoteCopyWith<PriceQuote> get copyWith => _$PriceQuoteCopyWithImpl<PriceQuote>(this as PriceQuote, _$identity);

  /// Serializes this PriceQuote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PriceQuote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceQuote&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.listPrice, _this.listPrice) || other.listPrice == _this.listPrice)&&(identical(other.pricePerKg, _this.pricePerKg) || other.pricePerKg == _this.pricePerKg)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.readAt, _this.readAt) || other.readAt == _this.readAt)&&(identical(other.chain, _this.chain) || other.chain == _this.chain)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PriceQuote;
  return Object.hash(runtimeType,_this.price,_this.listPrice,_this.pricePerKg,_this.source,_this.readAt,_this.chain,_this.storeId);
}

@override
String toString() {
  final _this = this as PriceQuote;
  return 'PriceQuote(price: ${_this.price}, listPrice: ${_this.listPrice}, pricePerKg: ${_this.pricePerKg}, source: ${_this.source}, readAt: ${_this.readAt}, chain: ${_this.chain}, storeId: ${_this.storeId})';
}


}

/// @nodoc
abstract mixin class $PriceQuoteCopyWith<$Res>  {
  factory $PriceQuoteCopyWith(PriceQuote value, $Res Function(PriceQuote) _then) = _$PriceQuoteCopyWithImpl;
@useResult
$Res call({
 double price, double? listPrice, double? pricePerKg, PriceSource source, DateTime readAt, Chain chain, int? storeId
});




}
/// @nodoc
class _$PriceQuoteCopyWithImpl<$Res>
    implements $PriceQuoteCopyWith<$Res> {
  _$PriceQuoteCopyWithImpl(this._self, this._then);

  final PriceQuote _self;
  final $Res Function(PriceQuote) _then;

/// Create a copy of PriceQuote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? price = null,Object? listPrice = freezed,Object? pricePerKg = freezed,Object? source = null,Object? readAt = null,Object? chain = null,Object? storeId = freezed,}) {
  return _then(PriceQuote(
price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,listPrice: freezed == listPrice ? _self.listPrice : listPrice // ignore: cast_nullable_to_non_nullable
as double?,pricePerKg: freezed == pricePerKg ? _self.pricePerKg : pricePerKg // ignore: cast_nullable_to_non_nullable
as double?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PriceSource,readAt: null == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime,chain: null == chain ? _self.chain : chain // ignore: cast_nullable_to_non_nullable
as Chain,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceQuote].
extension PriceQuotePatterns on PriceQuote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceQuote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceQuote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceQuote value)  $default,){
final _that = this;
switch (_that) {
case _PriceQuote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceQuote value)?  $default,){
final _that = this;
switch (_that) {
case _PriceQuote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double price,  double? listPrice,  double? pricePerKg,  PriceSource source,  DateTime readAt,  Chain chain,  int? storeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceQuote() when $default != null:
return $default(_that.price,_that.listPrice,_that.pricePerKg,_that.source,_that.readAt,_that.chain,_that.storeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double price,  double? listPrice,  double? pricePerKg,  PriceSource source,  DateTime readAt,  Chain chain,  int? storeId)  $default,) {final _that = this;
switch (_that) {
case _PriceQuote():
return $default(_that.price,_that.listPrice,_that.pricePerKg,_that.source,_that.readAt,_that.chain,_that.storeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double price,  double? listPrice,  double? pricePerKg,  PriceSource source,  DateTime readAt,  Chain chain,  int? storeId)?  $default,) {final _that = this;
switch (_that) {
case _PriceQuote() when $default != null:
return $default(_that.price,_that.listPrice,_that.pricePerKg,_that.source,_that.readAt,_that.chain,_that.storeId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceQuote extends PriceQuote {
  const _PriceQuote({required this.price, this.listPrice, this.pricePerKg, required this.source, required this.readAt, this.chain = Chain.poli, this.storeId}): super._();
  factory _PriceQuote.fromJson(Map<String, dynamic> json) => _$PriceQuoteFromJson(json);

/// Prezzo di vendita (a pezzo / confezione).
@override final  double price;
/// Prezzo pieno, se il prodotto è in promozione.
@override final  double? listPrice;
/// Prezzo al kg / l.
@override final  double? pricePerKg;
@override final  PriceSource source;
@override final  DateTime readAt;
/// Catena a cui si riferisce il prezzo.
@override@JsonKey() final  Chain chain;
/// Punto vendita a cui si riferisce il prezzo (null = online/offline).
@override final  int? storeId;

/// Create a copy of PriceQuote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceQuoteCopyWith<_PriceQuote> get copyWith => __$PriceQuoteCopyWithImpl<_PriceQuote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceQuoteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceQuote&&(identical(other.price, price) || other.price == price)&&(identical(other.listPrice, listPrice) || other.listPrice == listPrice)&&(identical(other.pricePerKg, pricePerKg) || other.pricePerKg == pricePerKg)&&(identical(other.source, source) || other.source == source)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.chain, chain) || other.chain == chain)&&(identical(other.storeId, storeId) || other.storeId == storeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,price,listPrice,pricePerKg,source,readAt,chain,storeId);
}

@override
String toString() {
    return 'PriceQuote(price: $price, listPrice: $listPrice, pricePerKg: $pricePerKg, source: $source, readAt: $readAt, chain: $chain, storeId: $storeId)';
}


}

/// @nodoc
abstract mixin class _$PriceQuoteCopyWith<$Res> implements $PriceQuoteCopyWith<$Res> {
  factory _$PriceQuoteCopyWith(_PriceQuote value, $Res Function(_PriceQuote) _then) = __$PriceQuoteCopyWithImpl;
@override @useResult
$Res call({
 double price, double? listPrice, double? pricePerKg, PriceSource source, DateTime readAt, Chain chain, int? storeId
});




}
/// @nodoc
class __$PriceQuoteCopyWithImpl<$Res>
    implements _$PriceQuoteCopyWith<$Res> {
  __$PriceQuoteCopyWithImpl(this._self, this._then);

  final _PriceQuote _self;
  final $Res Function(_PriceQuote) _then;

/// Create a copy of PriceQuote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? price = null,Object? listPrice = freezed,Object? pricePerKg = freezed,Object? source = null,Object? readAt = null,Object? chain = null,Object? storeId = freezed,}) {
  return _then(_PriceQuote(
price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,listPrice: freezed == listPrice ? _self.listPrice : listPrice // ignore: cast_nullable_to_non_nullable
as double?,pricePerKg: freezed == pricePerKg ? _self.pricePerKg : pricePerKg // ignore: cast_nullable_to_non_nullable
as double?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PriceSource,readAt: null == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime,chain: null == chain ? _self.chain : chain // ignore: cast_nullable_to_non_nullable
as Chain,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
