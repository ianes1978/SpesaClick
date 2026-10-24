// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartItem {

/// Chiave della riga: EAN del prodotto, o codice completo dell'etichetta.
 String get id; Product get product; PriceQuote get quote; int get quantity;/// Peso in kg per i prodotti a peso variabile.
 double? get weightKg;/// Totale stampato sull'etichetta (o inserito a mano).
 double? get labelTotal;/// Prezzo al kg corretto a mano dall'utente.
 double? get pricePerKgOverride;/// Bollino scadenza: 0, 30 o 50.
 int get discountPercent;/// Spuntato: già messo nel carrello in negozio.
 bool get taken; DateTime get addedAt;
/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemCopyWith<CartItem> get copyWith => _$CartItemCopyWithImpl<CartItem>(this as CartItem, _$identity);

  /// Serializes this CartItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CartItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.quote, _this.quote) || other.quote == _this.quote)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg)&&(identical(other.labelTotal, _this.labelTotal) || other.labelTotal == _this.labelTotal)&&(identical(other.pricePerKgOverride, _this.pricePerKgOverride) || other.pricePerKgOverride == _this.pricePerKgOverride)&&(identical(other.discountPercent, _this.discountPercent) || other.discountPercent == _this.discountPercent)&&(identical(other.taken, _this.taken) || other.taken == _this.taken)&&(identical(other.addedAt, _this.addedAt) || other.addedAt == _this.addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CartItem;
  return Object.hash(runtimeType,_this.id,_this.product,_this.quote,_this.quantity,_this.weightKg,_this.labelTotal,_this.pricePerKgOverride,_this.discountPercent,_this.taken,_this.addedAt);
}

@override
String toString() {
  final _this = this as CartItem;
  return 'CartItem(id: ${_this.id}, product: ${_this.product}, quote: ${_this.quote}, quantity: ${_this.quantity}, weightKg: ${_this.weightKg}, labelTotal: ${_this.labelTotal}, pricePerKgOverride: ${_this.pricePerKgOverride}, discountPercent: ${_this.discountPercent}, taken: ${_this.taken}, addedAt: ${_this.addedAt})';
}


}

/// @nodoc
abstract mixin class $CartItemCopyWith<$Res>  {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) _then) = _$CartItemCopyWithImpl;
@useResult
$Res call({
 String id, Product product, PriceQuote quote, int quantity, double? weightKg, double? labelTotal, double? pricePerKgOverride, int discountPercent, bool taken, DateTime addedAt
});


$ProductCopyWith<$Res> get product;$PriceQuoteCopyWith<$Res> get quote;

}
/// @nodoc
class _$CartItemCopyWithImpl<$Res>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._self, this._then);

  final CartItem _self;
  final $Res Function(CartItem) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? product = null,Object? quote = null,Object? quantity = null,Object? weightKg = freezed,Object? labelTotal = freezed,Object? pricePerKgOverride = freezed,Object? discountPercent = null,Object? taken = null,Object? addedAt = null,}) {
  return _then(CartItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as PriceQuote,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,labelTotal: freezed == labelTotal ? _self.labelTotal : labelTotal // ignore: cast_nullable_to_non_nullable
as double?,pricePerKgOverride: freezed == pricePerKgOverride ? _self.pricePerKgOverride : pricePerKgOverride // ignore: cast_nullable_to_non_nullable
as double?,discountPercent: null == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as int,taken: null == taken ? _self.taken : taken // ignore: cast_nullable_to_non_nullable
as bool,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceQuoteCopyWith<$Res> get quote {
  
  return $PriceQuoteCopyWith<$Res>(_self.quote, (value) {
    return _then(_self.copyWith(quote: value));
  });
}
}


/// Adds pattern-matching-related methods to [CartItem].
extension CartItemPatterns on CartItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartItem value)  $default,){
final _that = this;
switch (_that) {
case _CartItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartItem value)?  $default,){
final _that = this;
switch (_that) {
case _CartItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Product product,  PriceQuote quote,  int quantity,  double? weightKg,  double? labelTotal,  double? pricePerKgOverride,  int discountPercent,  bool taken,  DateTime addedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.product,_that.quote,_that.quantity,_that.weightKg,_that.labelTotal,_that.pricePerKgOverride,_that.discountPercent,_that.taken,_that.addedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Product product,  PriceQuote quote,  int quantity,  double? weightKg,  double? labelTotal,  double? pricePerKgOverride,  int discountPercent,  bool taken,  DateTime addedAt)  $default,) {final _that = this;
switch (_that) {
case _CartItem():
return $default(_that.id,_that.product,_that.quote,_that.quantity,_that.weightKg,_that.labelTotal,_that.pricePerKgOverride,_that.discountPercent,_that.taken,_that.addedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Product product,  PriceQuote quote,  int quantity,  double? weightKg,  double? labelTotal,  double? pricePerKgOverride,  int discountPercent,  bool taken,  DateTime addedAt)?  $default,) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.product,_that.quote,_that.quantity,_that.weightKg,_that.labelTotal,_that.pricePerKgOverride,_that.discountPercent,_that.taken,_that.addedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItem extends CartItem {
  const _CartItem({required this.id, required this.product, required this.quote, this.quantity = 1, this.weightKg, this.labelTotal, this.pricePerKgOverride, this.discountPercent = 0, this.taken = false, required this.addedAt}): super._();
  factory _CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);

/// Chiave della riga: EAN del prodotto, o codice completo dell'etichetta.
@override final  String id;
@override final  Product product;
@override final  PriceQuote quote;
@override@JsonKey() final  int quantity;
/// Peso in kg per i prodotti a peso variabile.
@override final  double? weightKg;
/// Totale stampato sull'etichetta (o inserito a mano).
@override final  double? labelTotal;
/// Prezzo al kg corretto a mano dall'utente.
@override final  double? pricePerKgOverride;
/// Bollino scadenza: 0, 30 o 50.
@override@JsonKey() final  int discountPercent;
/// Spuntato: già messo nel carrello in negozio.
@override@JsonKey() final  bool taken;
@override final  DateTime addedAt;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemCopyWith<_CartItem> get copyWith => __$CartItemCopyWithImpl<_CartItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItem&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.quote, quote) || other.quote == quote)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.labelTotal, labelTotal) || other.labelTotal == labelTotal)&&(identical(other.pricePerKgOverride, pricePerKgOverride) || other.pricePerKgOverride == pricePerKgOverride)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.taken, taken) || other.taken == taken)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,product,quote,quantity,weightKg,labelTotal,pricePerKgOverride,discountPercent,taken,addedAt);
}

@override
String toString() {
    return 'CartItem(id: $id, product: $product, quote: $quote, quantity: $quantity, weightKg: $weightKg, labelTotal: $labelTotal, pricePerKgOverride: $pricePerKgOverride, discountPercent: $discountPercent, taken: $taken, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class _$CartItemCopyWith<$Res> implements $CartItemCopyWith<$Res> {
  factory _$CartItemCopyWith(_CartItem value, $Res Function(_CartItem) _then) = __$CartItemCopyWithImpl;
@override @useResult
$Res call({
 String id, Product product, PriceQuote quote, int quantity, double? weightKg, double? labelTotal, double? pricePerKgOverride, int discountPercent, bool taken, DateTime addedAt
});


@override $ProductCopyWith<$Res> get product;@override $PriceQuoteCopyWith<$Res> get quote;

}
/// @nodoc
class __$CartItemCopyWithImpl<$Res>
    implements _$CartItemCopyWith<$Res> {
  __$CartItemCopyWithImpl(this._self, this._then);

  final _CartItem _self;
  final $Res Function(_CartItem) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? product = null,Object? quote = null,Object? quantity = null,Object? weightKg = freezed,Object? labelTotal = freezed,Object? pricePerKgOverride = freezed,Object? discountPercent = null,Object? taken = null,Object? addedAt = null,}) {
  return _then(_CartItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as PriceQuote,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,labelTotal: freezed == labelTotal ? _self.labelTotal : labelTotal // ignore: cast_nullable_to_non_nullable
as double?,pricePerKgOverride: freezed == pricePerKgOverride ? _self.pricePerKgOverride : pricePerKgOverride // ignore: cast_nullable_to_non_nullable
as double?,discountPercent: null == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as int,taken: null == taken ? _self.taken : taken // ignore: cast_nullable_to_non_nullable
as bool,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceQuoteCopyWith<$Res> get quote {
  
  return $PriceQuoteCopyWith<$Res>(_self.quote, (value) {
    return _then(_self.copyWith(quote: value));
  });
}
}

// dart format on
