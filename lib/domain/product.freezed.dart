// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 int get productId; String get barcode; String get name; String? get brand; String? get packageDescr;/// "Pezzo" | "Sfuso" | "Confezione".
 String? get tipologia; double get price; double? get listPrice; double? get pricePerKg; String? get weightUnit; String? get category; String? get thumbUrl; String? get imageUrl;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Product;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.barcode, _this.barcode) || other.barcode == _this.barcode)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.packageDescr, _this.packageDescr) || other.packageDescr == _this.packageDescr)&&(identical(other.tipologia, _this.tipologia) || other.tipologia == _this.tipologia)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.listPrice, _this.listPrice) || other.listPrice == _this.listPrice)&&(identical(other.pricePerKg, _this.pricePerKg) || other.pricePerKg == _this.pricePerKg)&&(identical(other.weightUnit, _this.weightUnit) || other.weightUnit == _this.weightUnit)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.thumbUrl, _this.thumbUrl) || other.thumbUrl == _this.thumbUrl)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Product;
  return Object.hash(runtimeType,_this.productId,_this.barcode,_this.name,_this.brand,_this.packageDescr,_this.tipologia,_this.price,_this.listPrice,_this.pricePerKg,_this.weightUnit,_this.category,_this.thumbUrl,_this.imageUrl);
}

@override
String toString() {
  final _this = this as Product;
  return 'Product(productId: ${_this.productId}, barcode: ${_this.barcode}, name: ${_this.name}, brand: ${_this.brand}, packageDescr: ${_this.packageDescr}, tipologia: ${_this.tipologia}, price: ${_this.price}, listPrice: ${_this.listPrice}, pricePerKg: ${_this.pricePerKg}, weightUnit: ${_this.weightUnit}, category: ${_this.category}, thumbUrl: ${_this.thumbUrl}, imageUrl: ${_this.imageUrl})';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 int productId, String barcode, String name, String? brand, String? packageDescr, String? tipologia, double price, double? listPrice, double? pricePerKg, String? weightUnit, String? category, String? thumbUrl, String? imageUrl
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? barcode = null,Object? name = null,Object? brand = freezed,Object? packageDescr = freezed,Object? tipologia = freezed,Object? price = null,Object? listPrice = freezed,Object? pricePerKg = freezed,Object? weightUnit = freezed,Object? category = freezed,Object? thumbUrl = freezed,Object? imageUrl = freezed,}) {
  return _then(Product(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,packageDescr: freezed == packageDescr ? _self.packageDescr : packageDescr // ignore: cast_nullable_to_non_nullable
as String?,tipologia: freezed == tipologia ? _self.tipologia : tipologia // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,listPrice: freezed == listPrice ? _self.listPrice : listPrice // ignore: cast_nullable_to_non_nullable
as double?,pricePerKg: freezed == pricePerKg ? _self.pricePerKg : pricePerKg // ignore: cast_nullable_to_non_nullable
as double?,weightUnit: freezed == weightUnit ? _self.weightUnit : weightUnit // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,thumbUrl: freezed == thumbUrl ? _self.thumbUrl : thumbUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String barcode,  String name,  String? brand,  String? packageDescr,  String? tipologia,  double price,  double? listPrice,  double? pricePerKg,  String? weightUnit,  String? category,  String? thumbUrl,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.productId,_that.barcode,_that.name,_that.brand,_that.packageDescr,_that.tipologia,_that.price,_that.listPrice,_that.pricePerKg,_that.weightUnit,_that.category,_that.thumbUrl,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String barcode,  String name,  String? brand,  String? packageDescr,  String? tipologia,  double price,  double? listPrice,  double? pricePerKg,  String? weightUnit,  String? category,  String? thumbUrl,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.productId,_that.barcode,_that.name,_that.brand,_that.packageDescr,_that.tipologia,_that.price,_that.listPrice,_that.pricePerKg,_that.weightUnit,_that.category,_that.thumbUrl,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String barcode,  String name,  String? brand,  String? packageDescr,  String? tipologia,  double price,  double? listPrice,  double? pricePerKg,  String? weightUnit,  String? category,  String? thumbUrl,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.productId,_that.barcode,_that.name,_that.brand,_that.packageDescr,_that.tipologia,_that.price,_that.listPrice,_that.pricePerKg,_that.weightUnit,_that.category,_that.thumbUrl,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product extends Product {
  const _Product({required this.productId, required this.barcode, required this.name, this.brand, this.packageDescr, this.tipologia, required this.price, this.listPrice, this.pricePerKg, this.weightUnit, this.category, this.thumbUrl, this.imageUrl}): super._();
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  int productId;
@override final  String barcode;
@override final  String name;
@override final  String? brand;
@override final  String? packageDescr;
/// "Pezzo" | "Sfuso" | "Confezione".
@override final  String? tipologia;
@override final  double price;
@override final  double? listPrice;
@override final  double? pricePerKg;
@override final  String? weightUnit;
@override final  String? category;
@override final  String? thumbUrl;
@override final  String? imageUrl;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.packageDescr, packageDescr) || other.packageDescr == packageDescr)&&(identical(other.tipologia, tipologia) || other.tipologia == tipologia)&&(identical(other.price, price) || other.price == price)&&(identical(other.listPrice, listPrice) || other.listPrice == listPrice)&&(identical(other.pricePerKg, pricePerKg) || other.pricePerKg == pricePerKg)&&(identical(other.weightUnit, weightUnit) || other.weightUnit == weightUnit)&&(identical(other.category, category) || other.category == category)&&(identical(other.thumbUrl, thumbUrl) || other.thumbUrl == thumbUrl)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,barcode,name,brand,packageDescr,tipologia,price,listPrice,pricePerKg,weightUnit,category,thumbUrl,imageUrl);
}

@override
String toString() {
    return 'Product(productId: $productId, barcode: $barcode, name: $name, brand: $brand, packageDescr: $packageDescr, tipologia: $tipologia, price: $price, listPrice: $listPrice, pricePerKg: $pricePerKg, weightUnit: $weightUnit, category: $category, thumbUrl: $thumbUrl, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 int productId, String barcode, String name, String? brand, String? packageDescr, String? tipologia, double price, double? listPrice, double? pricePerKg, String? weightUnit, String? category, String? thumbUrl, String? imageUrl
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? barcode = null,Object? name = null,Object? brand = freezed,Object? packageDescr = freezed,Object? tipologia = freezed,Object? price = null,Object? listPrice = freezed,Object? pricePerKg = freezed,Object? weightUnit = freezed,Object? category = freezed,Object? thumbUrl = freezed,Object? imageUrl = freezed,}) {
  return _then(_Product(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,packageDescr: freezed == packageDescr ? _self.packageDescr : packageDescr // ignore: cast_nullable_to_non_nullable
as String?,tipologia: freezed == tipologia ? _self.tipologia : tipologia // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,listPrice: freezed == listPrice ? _self.listPrice : listPrice // ignore: cast_nullable_to_non_nullable
as double?,pricePerKg: freezed == pricePerKg ? _self.pricePerKg : pricePerKg // ignore: cast_nullable_to_non_nullable
as double?,weightUnit: freezed == weightUnit ? _self.weightUnit : weightUnit // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,thumbUrl: freezed == thumbUrl ? _self.thumbUrl : thumbUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
