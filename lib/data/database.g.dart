// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PriceCacheTable extends PriceCache
    with TableInfo<$PriceCacheTable, PriceCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chainMeta = const VerificationMeta('chain');
  @override
  late final GeneratedColumn<String> chain = GeneratedColumn<String>(
    'chain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeKeyMeta = const VerificationMeta(
    'storeKey',
  );
  @override
  late final GeneratedColumn<String> storeKey = GeneratedColumn<String>(
    'store_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productJsonMeta = const VerificationMeta(
    'productJson',
  );
  @override
  late final GeneratedColumn<String> productJson = GeneratedColumn<String>(
    'product_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chain,
    storeKey,
    barcode,
    productJson,
    readAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chain')) {
      context.handle(
        _chainMeta,
        chain.isAcceptableOrUnknown(data['chain']!, _chainMeta),
      );
    } else if (isInserting) {
      context.missing(_chainMeta);
    }
    if (data.containsKey('store_key')) {
      context.handle(
        _storeKeyMeta,
        storeKey.isAcceptableOrUnknown(data['store_key']!, _storeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_storeKeyMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('product_json')) {
      context.handle(
        _productJsonMeta,
        productJson.isAcceptableOrUnknown(
          data['product_json']!,
          _productJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productJsonMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    } else if (isInserting) {
      context.missing(_readAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chain, storeKey, barcode};
  @override
  PriceCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceCacheData(
      chain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chain'],
      )!,
      storeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_key'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
      productJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_json'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      )!,
    );
  }

  @override
  $PriceCacheTable createAlias(String alias) {
    return $PriceCacheTable(attachedDatabase, alias);
  }
}

class PriceCacheData extends DataClass implements Insertable<PriceCacheData> {
  final String chain;
  final String storeKey;
  final String barcode;
  final String productJson;
  final DateTime readAt;
  const PriceCacheData({
    required this.chain,
    required this.storeKey,
    required this.barcode,
    required this.productJson,
    required this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chain'] = Variable<String>(chain);
    map['store_key'] = Variable<String>(storeKey);
    map['barcode'] = Variable<String>(barcode);
    map['product_json'] = Variable<String>(productJson);
    map['read_at'] = Variable<DateTime>(readAt);
    return map;
  }

  PriceCacheCompanion toCompanion(bool nullToAbsent) {
    return PriceCacheCompanion(
      chain: Value(chain),
      storeKey: Value(storeKey),
      barcode: Value(barcode),
      productJson: Value(productJson),
      readAt: Value(readAt),
    );
  }

  factory PriceCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceCacheData(
      chain: serializer.fromJson<String>(json['chain']),
      storeKey: serializer.fromJson<String>(json['storeKey']),
      barcode: serializer.fromJson<String>(json['barcode']),
      productJson: serializer.fromJson<String>(json['productJson']),
      readAt: serializer.fromJson<DateTime>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chain': serializer.toJson<String>(chain),
      'storeKey': serializer.toJson<String>(storeKey),
      'barcode': serializer.toJson<String>(barcode),
      'productJson': serializer.toJson<String>(productJson),
      'readAt': serializer.toJson<DateTime>(readAt),
    };
  }

  PriceCacheData copyWith({
    String? chain,
    String? storeKey,
    String? barcode,
    String? productJson,
    DateTime? readAt,
  }) => PriceCacheData(
    chain: chain ?? this.chain,
    storeKey: storeKey ?? this.storeKey,
    barcode: barcode ?? this.barcode,
    productJson: productJson ?? this.productJson,
    readAt: readAt ?? this.readAt,
  );
  PriceCacheData copyWithCompanion(PriceCacheCompanion data) {
    return PriceCacheData(
      chain: data.chain.present ? data.chain.value : this.chain,
      storeKey: data.storeKey.present ? data.storeKey.value : this.storeKey,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      productJson: data.productJson.present
          ? data.productJson.value
          : this.productJson,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceCacheData(')
          ..write('chain: $chain, ')
          ..write('storeKey: $storeKey, ')
          ..write('barcode: $barcode, ')
          ..write('productJson: $productJson, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(chain, storeKey, barcode, productJson, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceCacheData &&
          other.chain == this.chain &&
          other.storeKey == this.storeKey &&
          other.barcode == this.barcode &&
          other.productJson == this.productJson &&
          other.readAt == this.readAt);
}

class PriceCacheCompanion extends UpdateCompanion<PriceCacheData> {
  final Value<String> chain;
  final Value<String> storeKey;
  final Value<String> barcode;
  final Value<String> productJson;
  final Value<DateTime> readAt;
  final Value<int> rowid;
  const PriceCacheCompanion({
    this.chain = const Value.absent(),
    this.storeKey = const Value.absent(),
    this.barcode = const Value.absent(),
    this.productJson = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PriceCacheCompanion.insert({
    required String chain,
    required String storeKey,
    required String barcode,
    required String productJson,
    required DateTime readAt,
    this.rowid = const Value.absent(),
  }) : chain = Value(chain),
       storeKey = Value(storeKey),
       barcode = Value(barcode),
       productJson = Value(productJson),
       readAt = Value(readAt);
  static Insertable<PriceCacheData> custom({
    Expression<String>? chain,
    Expression<String>? storeKey,
    Expression<String>? barcode,
    Expression<String>? productJson,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chain != null) 'chain': chain,
      if (storeKey != null) 'store_key': storeKey,
      if (barcode != null) 'barcode': barcode,
      if (productJson != null) 'product_json': productJson,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PriceCacheCompanion copyWith({
    Value<String>? chain,
    Value<String>? storeKey,
    Value<String>? barcode,
    Value<String>? productJson,
    Value<DateTime>? readAt,
    Value<int>? rowid,
  }) {
    return PriceCacheCompanion(
      chain: chain ?? this.chain,
      storeKey: storeKey ?? this.storeKey,
      barcode: barcode ?? this.barcode,
      productJson: productJson ?? this.productJson,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chain.present) {
      map['chain'] = Variable<String>(chain.value);
    }
    if (storeKey.present) {
      map['store_key'] = Variable<String>(storeKey.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (productJson.present) {
      map['product_json'] = Variable<String>(productJson.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceCacheCompanion(')
          ..write('chain: $chain, ')
          ..write('storeKey: $storeKey, ')
          ..write('barcode: $barcode, ')
          ..write('productJson: $productJson, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogTable extends Catalog with TableInfo<$CatalogTable, CatalogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chainMeta = const VerificationMeta('chain');
  @override
  late final GeneratedColumn<String> chain = GeneratedColumn<String>(
    'chain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productJsonMeta = const VerificationMeta(
    'productJson',
  );
  @override
  late final GeneratedColumn<String> productJson = GeneratedColumn<String>(
    'product_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chain,
    productId,
    barcode,
    name,
    brand,
    category,
    productJson,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chain')) {
      context.handle(
        _chainMeta,
        chain.isAcceptableOrUnknown(data['chain']!, _chainMeta),
      );
    } else if (isInserting) {
      context.missing(_chainMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('product_json')) {
      context.handle(
        _productJsonMeta,
        productJson.isAcceptableOrUnknown(
          data['product_json']!,
          _productJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productJsonMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chain, productId};
  @override
  CatalogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogData(
      chain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chain'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      productJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_json'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $CatalogTable createAlias(String alias) {
    return $CatalogTable(attachedDatabase, alias);
  }
}

class CatalogData extends DataClass implements Insertable<CatalogData> {
  final String chain;
  final int productId;
  final String barcode;
  final String name;
  final String? brand;
  final String? category;
  final String productJson;
  final DateTime downloadedAt;
  const CatalogData({
    required this.chain,
    required this.productId,
    required this.barcode,
    required this.name,
    this.brand,
    this.category,
    required this.productJson,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chain'] = Variable<String>(chain);
    map['product_id'] = Variable<int>(productId);
    map['barcode'] = Variable<String>(barcode);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['product_json'] = Variable<String>(productJson);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  CatalogCompanion toCompanion(bool nullToAbsent) {
    return CatalogCompanion(
      chain: Value(chain),
      productId: Value(productId),
      barcode: Value(barcode),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      productJson: Value(productJson),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory CatalogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogData(
      chain: serializer.fromJson<String>(json['chain']),
      productId: serializer.fromJson<int>(json['productId']),
      barcode: serializer.fromJson<String>(json['barcode']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      category: serializer.fromJson<String?>(json['category']),
      productJson: serializer.fromJson<String>(json['productJson']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chain': serializer.toJson<String>(chain),
      'productId': serializer.toJson<int>(productId),
      'barcode': serializer.toJson<String>(barcode),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'category': serializer.toJson<String?>(category),
      'productJson': serializer.toJson<String>(productJson),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  CatalogData copyWith({
    String? chain,
    int? productId,
    String? barcode,
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> category = const Value.absent(),
    String? productJson,
    DateTime? downloadedAt,
  }) => CatalogData(
    chain: chain ?? this.chain,
    productId: productId ?? this.productId,
    barcode: barcode ?? this.barcode,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    category: category.present ? category.value : this.category,
    productJson: productJson ?? this.productJson,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  CatalogData copyWithCompanion(CatalogCompanion data) {
    return CatalogData(
      chain: data.chain.present ? data.chain.value : this.chain,
      productId: data.productId.present ? data.productId.value : this.productId,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      category: data.category.present ? data.category.value : this.category,
      productJson: data.productJson.present
          ? data.productJson.value
          : this.productJson,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogData(')
          ..write('chain: $chain, ')
          ..write('productId: $productId, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('productJson: $productJson, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    chain,
    productId,
    barcode,
    name,
    brand,
    category,
    productJson,
    downloadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogData &&
          other.chain == this.chain &&
          other.productId == this.productId &&
          other.barcode == this.barcode &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.category == this.category &&
          other.productJson == this.productJson &&
          other.downloadedAt == this.downloadedAt);
}

class CatalogCompanion extends UpdateCompanion<CatalogData> {
  final Value<String> chain;
  final Value<int> productId;
  final Value<String> barcode;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> category;
  final Value<String> productJson;
  final Value<DateTime> downloadedAt;
  final Value<int> rowid;
  const CatalogCompanion({
    this.chain = const Value.absent(),
    this.productId = const Value.absent(),
    this.barcode = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.productJson = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogCompanion.insert({
    required String chain,
    required int productId,
    required String barcode,
    required String name,
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    required String productJson,
    required DateTime downloadedAt,
    this.rowid = const Value.absent(),
  }) : chain = Value(chain),
       productId = Value(productId),
       barcode = Value(barcode),
       name = Value(name),
       productJson = Value(productJson),
       downloadedAt = Value(downloadedAt);
  static Insertable<CatalogData> custom({
    Expression<String>? chain,
    Expression<int>? productId,
    Expression<String>? barcode,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? category,
    Expression<String>? productJson,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chain != null) 'chain': chain,
      if (productId != null) 'product_id': productId,
      if (barcode != null) 'barcode': barcode,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (category != null) 'category': category,
      if (productJson != null) 'product_json': productJson,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogCompanion copyWith({
    Value<String>? chain,
    Value<int>? productId,
    Value<String>? barcode,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? category,
    Value<String>? productJson,
    Value<DateTime>? downloadedAt,
    Value<int>? rowid,
  }) {
    return CatalogCompanion(
      chain: chain ?? this.chain,
      productId: productId ?? this.productId,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      productJson: productJson ?? this.productJson,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chain.present) {
      map['chain'] = Variable<String>(chain.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (productJson.present) {
      map['product_json'] = Variable<String>(productJson.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCompanion(')
          ..write('chain: $chain, ')
          ..write('productId: $productId, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('productJson: $productJson, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CartLinesTable extends CartLines
    with TableInfo<$CartLinesTable, CartLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, position, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cart_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<CartLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CartLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CartLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $CartLinesTable createAlias(String alias) {
    return $CartLinesTable(attachedDatabase, alias);
  }
}

class CartLine extends DataClass implements Insertable<CartLine> {
  final String id;
  final int position;
  final String json;
  const CartLine({
    required this.id,
    required this.position,
    required this.json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['position'] = Variable<int>(position);
    map['json'] = Variable<String>(json);
    return map;
  }

  CartLinesCompanion toCompanion(bool nullToAbsent) {
    return CartLinesCompanion(
      id: Value(id),
      position: Value(position),
      json: Value(json),
    );
  }

  factory CartLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CartLine(
      id: serializer.fromJson<String>(json['id']),
      position: serializer.fromJson<int>(json['position']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'position': serializer.toJson<int>(position),
      'json': serializer.toJson<String>(json),
    };
  }

  CartLine copyWith({String? id, int? position, String? json}) => CartLine(
    id: id ?? this.id,
    position: position ?? this.position,
    json: json ?? this.json,
  );
  CartLine copyWithCompanion(CartLinesCompanion data) {
    return CartLine(
      id: data.id.present ? data.id.value : this.id,
      position: data.position.present ? data.position.value : this.position,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CartLine(')
          ..write('id: $id, ')
          ..write('position: $position, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, position, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartLine &&
          other.id == this.id &&
          other.position == this.position &&
          other.json == this.json);
}

class CartLinesCompanion extends UpdateCompanion<CartLine> {
  final Value<String> id;
  final Value<int> position;
  final Value<String> json;
  final Value<int> rowid;
  const CartLinesCompanion({
    this.id = const Value.absent(),
    this.position = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CartLinesCompanion.insert({
    required String id,
    required int position,
    required String json,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       position = Value(position),
       json = Value(json);
  static Insertable<CartLine> custom({
    Expression<String>? id,
    Expression<int>? position,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (position != null) 'position': position,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CartLinesCompanion copyWith({
    Value<String>? id,
    Value<int>? position,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return CartLinesCompanion(
      id: id ?? this.id,
      position: position ?? this.position,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartLinesCompanion(')
          ..write('id: $id, ')
          ..write('position: $position, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KeyValuesTable extends KeyValues
    with TableInfo<$KeyValuesTable, KeyValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KeyValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValue(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KeyValuesTable createAlias(String alias) {
    return $KeyValuesTable(attachedDatabase, alias);
  }
}

class KeyValue extends DataClass implements Insertable<KeyValue> {
  final String key;
  final String value;
  const KeyValue({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KeyValuesCompanion toCompanion(bool nullToAbsent) {
    return KeyValuesCompanion(key: Value(key), value: Value(value));
  }

  factory KeyValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValue(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KeyValue copyWith({String? key, String? value}) =>
      KeyValue(key: key ?? this.key, value: value ?? this.value);
  KeyValue copyWithCompanion(KeyValuesCompanion data) {
    return KeyValue(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValue(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValue && other.key == this.key && other.value == this.value);
}

class KeyValuesCompanion extends UpdateCompanion<KeyValue> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KeyValuesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValuesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KeyValue> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValuesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KeyValuesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValuesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EverliCacheTable extends EverliCache
    with TableInfo<$EverliCacheTable, EverliCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EverliCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, json, readAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'everli_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<EverliCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    } else if (isInserting) {
      context.missing(_readAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  EverliCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EverliCacheData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      )!,
    );
  }

  @override
  $EverliCacheTable createAlias(String alias) {
    return $EverliCacheTable(attachedDatabase, alias);
  }
}

class EverliCacheData extends DataClass implements Insertable<EverliCacheData> {
  final String key;
  final String json;
  final DateTime readAt;
  const EverliCacheData({
    required this.key,
    required this.json,
    required this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['json'] = Variable<String>(json);
    map['read_at'] = Variable<DateTime>(readAt);
    return map;
  }

  EverliCacheCompanion toCompanion(bool nullToAbsent) {
    return EverliCacheCompanion(
      key: Value(key),
      json: Value(json),
      readAt: Value(readAt),
    );
  }

  factory EverliCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EverliCacheData(
      key: serializer.fromJson<String>(json['key']),
      json: serializer.fromJson<String>(json['json']),
      readAt: serializer.fromJson<DateTime>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'json': serializer.toJson<String>(json),
      'readAt': serializer.toJson<DateTime>(readAt),
    };
  }

  EverliCacheData copyWith({String? key, String? json, DateTime? readAt}) =>
      EverliCacheData(
        key: key ?? this.key,
        json: json ?? this.json,
        readAt: readAt ?? this.readAt,
      );
  EverliCacheData copyWithCompanion(EverliCacheCompanion data) {
    return EverliCacheData(
      key: data.key.present ? data.key.value : this.key,
      json: data.json.present ? data.json.value : this.json,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EverliCacheData(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, json, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EverliCacheData &&
          other.key == this.key &&
          other.json == this.json &&
          other.readAt == this.readAt);
}

class EverliCacheCompanion extends UpdateCompanion<EverliCacheData> {
  final Value<String> key;
  final Value<String> json;
  final Value<DateTime> readAt;
  final Value<int> rowid;
  const EverliCacheCompanion({
    this.key = const Value.absent(),
    this.json = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EverliCacheCompanion.insert({
    required String key,
    required String json,
    required DateTime readAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       json = Value(json),
       readAt = Value(readAt);
  static Insertable<EverliCacheData> custom({
    Expression<String>? key,
    Expression<String>? json,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (json != null) 'json': json,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EverliCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? json,
    Value<DateTime>? readAt,
    Value<int>? rowid,
  }) {
    return EverliCacheCompanion(
      key: key ?? this.key,
      json: json ?? this.json,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EverliCacheCompanion(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EverliMatchesTable extends EverliMatches
    with TableInfo<$EverliMatchesTable, EverliMatche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EverliMatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<int> storeId = GeneratedColumn<int>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confirmedAtMeta = const VerificationMeta(
    'confirmedAt',
  );
  @override
  late final GeneratedColumn<DateTime> confirmedAt = GeneratedColumn<DateTime>(
    'confirmed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [code, storeId, productId, confirmedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'everli_matches';
  @override
  VerificationContext validateIntegrity(
    Insertable<EverliMatche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
        _confirmedAtMeta,
        confirmedAt.isAcceptableOrUnknown(
          data['confirmed_at']!,
          _confirmedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confirmedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code, storeId};
  @override
  EverliMatche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EverliMatche(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}store_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      confirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}confirmed_at'],
      )!,
    );
  }

  @override
  $EverliMatchesTable createAlias(String alias) {
    return $EverliMatchesTable(attachedDatabase, alias);
  }
}

class EverliMatche extends DataClass implements Insertable<EverliMatche> {
  final String code;
  final int storeId;
  final int productId;
  final DateTime confirmedAt;
  const EverliMatche({
    required this.code,
    required this.storeId,
    required this.productId,
    required this.confirmedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['store_id'] = Variable<int>(storeId);
    map['product_id'] = Variable<int>(productId);
    map['confirmed_at'] = Variable<DateTime>(confirmedAt);
    return map;
  }

  EverliMatchesCompanion toCompanion(bool nullToAbsent) {
    return EverliMatchesCompanion(
      code: Value(code),
      storeId: Value(storeId),
      productId: Value(productId),
      confirmedAt: Value(confirmedAt),
    );
  }

  factory EverliMatche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EverliMatche(
      code: serializer.fromJson<String>(json['code']),
      storeId: serializer.fromJson<int>(json['storeId']),
      productId: serializer.fromJson<int>(json['productId']),
      confirmedAt: serializer.fromJson<DateTime>(json['confirmedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'storeId': serializer.toJson<int>(storeId),
      'productId': serializer.toJson<int>(productId),
      'confirmedAt': serializer.toJson<DateTime>(confirmedAt),
    };
  }

  EverliMatche copyWith({
    String? code,
    int? storeId,
    int? productId,
    DateTime? confirmedAt,
  }) => EverliMatche(
    code: code ?? this.code,
    storeId: storeId ?? this.storeId,
    productId: productId ?? this.productId,
    confirmedAt: confirmedAt ?? this.confirmedAt,
  );
  EverliMatche copyWithCompanion(EverliMatchesCompanion data) {
    return EverliMatche(
      code: data.code.present ? data.code.value : this.code,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      productId: data.productId.present ? data.productId.value : this.productId,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EverliMatche(')
          ..write('code: $code, ')
          ..write('storeId: $storeId, ')
          ..write('productId: $productId, ')
          ..write('confirmedAt: $confirmedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, storeId, productId, confirmedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EverliMatche &&
          other.code == this.code &&
          other.storeId == this.storeId &&
          other.productId == this.productId &&
          other.confirmedAt == this.confirmedAt);
}

class EverliMatchesCompanion extends UpdateCompanion<EverliMatche> {
  final Value<String> code;
  final Value<int> storeId;
  final Value<int> productId;
  final Value<DateTime> confirmedAt;
  final Value<int> rowid;
  const EverliMatchesCompanion({
    this.code = const Value.absent(),
    this.storeId = const Value.absent(),
    this.productId = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EverliMatchesCompanion.insert({
    required String code,
    required int storeId,
    required int productId,
    required DateTime confirmedAt,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       storeId = Value(storeId),
       productId = Value(productId),
       confirmedAt = Value(confirmedAt);
  static Insertable<EverliMatche> custom({
    Expression<String>? code,
    Expression<int>? storeId,
    Expression<int>? productId,
    Expression<DateTime>? confirmedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (storeId != null) 'store_id': storeId,
      if (productId != null) 'product_id': productId,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EverliMatchesCompanion copyWith({
    Value<String>? code,
    Value<int>? storeId,
    Value<int>? productId,
    Value<DateTime>? confirmedAt,
    Value<int>? rowid,
  }) {
    return EverliMatchesCompanion(
      code: code ?? this.code,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<int>(storeId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EverliMatchesCompanion(')
          ..write('code: $code, ')
          ..write('storeId: $storeId, ')
          ..write('productId: $productId, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PriceCacheTable priceCache = $PriceCacheTable(this);
  late final $CatalogTable catalog = $CatalogTable(this);
  late final $CartLinesTable cartLines = $CartLinesTable(this);
  late final $KeyValuesTable keyValues = $KeyValuesTable(this);
  late final $EverliCacheTable everliCache = $EverliCacheTable(this);
  late final $EverliMatchesTable everliMatches = $EverliMatchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    priceCache,
    catalog,
    cartLines,
    keyValues,
    everliCache,
    everliMatches,
  ];
}

typedef $$PriceCacheTableCreateCompanionBuilder = PriceCacheCompanion Function({
  required String chain,
  required String storeKey,
  required String barcode,
  required String productJson,
  required DateTime readAt,
  Value<int> rowid,
});
typedef $$PriceCacheTableUpdateCompanionBuilder = PriceCacheCompanion Function({
  Value<String> chain,
  Value<String> storeKey,
  Value<String> barcode,
  Value<String> productJson,
  Value<DateTime> readAt,
  Value<int> rowid,
});

class $$PriceCacheTableFilterComposer
    extends Composer<_$AppDatabase, $PriceCacheTable> {
  $$PriceCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chain => $composableBuilder(
    column: $table.chain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeKey => $composableBuilder(
    column: $table.storeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productJson => $composableBuilder(
    column: $table.productJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PriceCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceCacheTable> {
  $$PriceCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chain => $composableBuilder(
    column: $table.chain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeKey => $composableBuilder(
    column: $table.storeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productJson => $composableBuilder(
    column: $table.productJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PriceCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceCacheTable> {
  $$PriceCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chain =>
      $composableBuilder(column: $table.chain, builder: (column) => column);

  GeneratedColumn<String> get storeKey =>
      $composableBuilder(column: $table.storeKey, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get productJson => $composableBuilder(
    column: $table.productJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$PriceCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceCacheTable,
          PriceCacheData,
          $$PriceCacheTableFilterComposer,
          $$PriceCacheTableOrderingComposer,
          $$PriceCacheTableAnnotationComposer,
          $$PriceCacheTableCreateCompanionBuilder,
          $$PriceCacheTableUpdateCompanionBuilder,
          (
            PriceCacheData,
            BaseReferences<_$AppDatabase, $PriceCacheTable, PriceCacheData>,
          ),
          PriceCacheData,
          PrefetchHooks Function()
        > {
  $$PriceCacheTableTableManager(_$AppDatabase db, $PriceCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chain = const Value.absent(),
                Value<String> storeKey = const Value.absent(),
                Value<String> barcode = const Value.absent(),
                Value<String> productJson = const Value.absent(),
                Value<DateTime> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PriceCacheCompanion(
                chain: chain,
                storeKey: storeKey,
                barcode: barcode,
                productJson: productJson,
                readAt: readAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chain,
                required String storeKey,
                required String barcode,
                required String productJson,
                required DateTime readAt,
                Value<int> rowid = const Value.absent(),
              }) => PriceCacheCompanion.insert(
                chain: chain,
                storeKey: storeKey,
                barcode: barcode,
                productJson: productJson,
                readAt: readAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PriceCacheTable, PriceCacheData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PriceCacheTable,
                    PriceCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PriceCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceCacheTable,
      PriceCacheData,
      $$PriceCacheTableFilterComposer,
      $$PriceCacheTableOrderingComposer,
      $$PriceCacheTableAnnotationComposer,
      $$PriceCacheTableCreateCompanionBuilder,
      $$PriceCacheTableUpdateCompanionBuilder,
      (
        PriceCacheData,
        BaseReferences<_$AppDatabase, $PriceCacheTable, PriceCacheData>,
      ),
      PriceCacheData,
      PrefetchHooks Function()
    >;
typedef $$CatalogTableCreateCompanionBuilder = CatalogCompanion Function({
  required String chain,
  required int productId,
  required String barcode,
  required String name,
  Value<String?> brand,
  Value<String?> category,
  required String productJson,
  required DateTime downloadedAt,
  Value<int> rowid,
});
typedef $$CatalogTableUpdateCompanionBuilder = CatalogCompanion Function({
  Value<String> chain,
  Value<int> productId,
  Value<String> barcode,
  Value<String> name,
  Value<String?> brand,
  Value<String?> category,
  Value<String> productJson,
  Value<DateTime> downloadedAt,
  Value<int> rowid,
});

class $$CatalogTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogTable> {
  $$CatalogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chain => $composableBuilder(
    column: $table.chain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productJson => $composableBuilder(
    column: $table.productJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogTable> {
  $$CatalogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chain => $composableBuilder(
    column: $table.chain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productJson => $composableBuilder(
    column: $table.productJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogTable> {
  $$CatalogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chain =>
      $composableBuilder(column: $table.chain, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get productJson => $composableBuilder(
    column: $table.productJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$CatalogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogTable,
          CatalogData,
          $$CatalogTableFilterComposer,
          $$CatalogTableOrderingComposer,
          $$CatalogTableAnnotationComposer,
          $$CatalogTableCreateCompanionBuilder,
          $$CatalogTableUpdateCompanionBuilder,
          (
            CatalogData,
            BaseReferences<_$AppDatabase, $CatalogTable, CatalogData>,
          ),
          CatalogData,
          PrefetchHooks Function()
        > {
  $$CatalogTableTableManager(_$AppDatabase db, $CatalogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chain = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<String> barcode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> productJson = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogCompanion(
                chain: chain,
                productId: productId,
                barcode: barcode,
                name: name,
                brand: brand,
                category: category,
                productJson: productJson,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chain,
                required int productId,
                required String barcode,
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> category = const Value.absent(),
                required String productJson,
                required DateTime downloadedAt,
                Value<int> rowid = const Value.absent(),
              }) => CatalogCompanion.insert(
                chain: chain,
                productId: productId,
                barcode: barcode,
                name: name,
                brand: brand,
                category: category,
                productJson: productJson,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogTable, CatalogData>(table),
                  BaseReferences<_$AppDatabase, $CatalogTable, CatalogData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogTable,
      CatalogData,
      $$CatalogTableFilterComposer,
      $$CatalogTableOrderingComposer,
      $$CatalogTableAnnotationComposer,
      $$CatalogTableCreateCompanionBuilder,
      $$CatalogTableUpdateCompanionBuilder,
      (CatalogData, BaseReferences<_$AppDatabase, $CatalogTable, CatalogData>),
      CatalogData,
      PrefetchHooks Function()
    >;
typedef $$CartLinesTableCreateCompanionBuilder = CartLinesCompanion Function({
  required String id,
  required int position,
  required String json,
  Value<int> rowid,
});
typedef $$CartLinesTableUpdateCompanionBuilder = CartLinesCompanion Function({
  Value<String> id,
  Value<int> position,
  Value<String> json,
  Value<int> rowid,
});

class $$CartLinesTableFilterComposer
    extends Composer<_$AppDatabase, $CartLinesTable> {
  $$CartLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CartLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $CartLinesTable> {
  $$CartLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CartLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CartLinesTable> {
  $$CartLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$CartLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CartLinesTable,
          CartLine,
          $$CartLinesTableFilterComposer,
          $$CartLinesTableOrderingComposer,
          $$CartLinesTableAnnotationComposer,
          $$CartLinesTableCreateCompanionBuilder,
          $$CartLinesTableUpdateCompanionBuilder,
          (CartLine, BaseReferences<_$AppDatabase, $CartLinesTable, CartLine>),
          CartLine,
          PrefetchHooks Function()
        > {
  $$CartLinesTableTableManager(_$AppDatabase db, $CartLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CartLinesCompanion(
                id: id,
                position: position,
                json: json,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int position,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => CartLinesCompanion.insert(
                id: id,
                position: position,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CartLinesTable, CartLine>(table),
                  BaseReferences<_$AppDatabase, $CartLinesTable, CartLine>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CartLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CartLinesTable,
      CartLine,
      $$CartLinesTableFilterComposer,
      $$CartLinesTableOrderingComposer,
      $$CartLinesTableAnnotationComposer,
      $$CartLinesTableCreateCompanionBuilder,
      $$CartLinesTableUpdateCompanionBuilder,
      (CartLine, BaseReferences<_$AppDatabase, $CartLinesTable, CartLine>),
      CartLine,
      PrefetchHooks Function()
    >;
typedef $$KeyValuesTableCreateCompanionBuilder = KeyValuesCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$KeyValuesTableUpdateCompanionBuilder = KeyValuesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$KeyValuesTableFilterComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeyValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeyValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KeyValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeyValuesTable,
          KeyValue,
          $$KeyValuesTableFilterComposer,
          $$KeyValuesTableOrderingComposer,
          $$KeyValuesTableAnnotationComposer,
          $$KeyValuesTableCreateCompanionBuilder,
          $$KeyValuesTableUpdateCompanionBuilder,
          (KeyValue, BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValue>),
          KeyValue,
          PrefetchHooks Function()
        > {
  $$KeyValuesTableTableManager(_$AppDatabase db, $KeyValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => KeyValuesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => KeyValuesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KeyValuesTable, KeyValue>(table),
                  BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValue>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeyValuesTable,
      KeyValue,
      $$KeyValuesTableFilterComposer,
      $$KeyValuesTableOrderingComposer,
      $$KeyValuesTableAnnotationComposer,
      $$KeyValuesTableCreateCompanionBuilder,
      $$KeyValuesTableUpdateCompanionBuilder,
      (KeyValue, BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValue>),
      KeyValue,
      PrefetchHooks Function()
    >;
typedef $$EverliCacheTableCreateCompanionBuilder =
    EverliCacheCompanion Function({
      required String key,
      required String json,
      required DateTime readAt,
      Value<int> rowid,
    });
typedef $$EverliCacheTableUpdateCompanionBuilder =
    EverliCacheCompanion Function({
      Value<String> key,
      Value<String> json,
      Value<DateTime> readAt,
      Value<int> rowid,
    });

class $$EverliCacheTableFilterComposer
    extends Composer<_$AppDatabase, $EverliCacheTable> {
  $$EverliCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EverliCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $EverliCacheTable> {
  $$EverliCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EverliCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $EverliCacheTable> {
  $$EverliCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$EverliCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EverliCacheTable,
          EverliCacheData,
          $$EverliCacheTableFilterComposer,
          $$EverliCacheTableOrderingComposer,
          $$EverliCacheTableAnnotationComposer,
          $$EverliCacheTableCreateCompanionBuilder,
          $$EverliCacheTableUpdateCompanionBuilder,
          (
            EverliCacheData,
            BaseReferences<_$AppDatabase, $EverliCacheTable, EverliCacheData>,
          ),
          EverliCacheData,
          PrefetchHooks Function()
        > {
  $$EverliCacheTableTableManager(_$AppDatabase db, $EverliCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EverliCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EverliCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EverliCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EverliCacheCompanion(
                key: key,
                json: json,
                readAt: readAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String json,
                required DateTime readAt,
                Value<int> rowid = const Value.absent(),
              }) => EverliCacheCompanion.insert(
                key: key,
                json: json,
                readAt: readAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EverliCacheTable, EverliCacheData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EverliCacheTable,
                    EverliCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EverliCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EverliCacheTable,
      EverliCacheData,
      $$EverliCacheTableFilterComposer,
      $$EverliCacheTableOrderingComposer,
      $$EverliCacheTableAnnotationComposer,
      $$EverliCacheTableCreateCompanionBuilder,
      $$EverliCacheTableUpdateCompanionBuilder,
      (
        EverliCacheData,
        BaseReferences<_$AppDatabase, $EverliCacheTable, EverliCacheData>,
      ),
      EverliCacheData,
      PrefetchHooks Function()
    >;
typedef $$EverliMatchesTableCreateCompanionBuilder =
    EverliMatchesCompanion Function({
      required String code,
      required int storeId,
      required int productId,
      required DateTime confirmedAt,
      Value<int> rowid,
    });
typedef $$EverliMatchesTableUpdateCompanionBuilder =
    EverliMatchesCompanion Function({
      Value<String> code,
      Value<int> storeId,
      Value<int> productId,
      Value<DateTime> confirmedAt,
      Value<int> rowid,
    });

class $$EverliMatchesTableFilterComposer
    extends Composer<_$AppDatabase, $EverliMatchesTable> {
  $$EverliMatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EverliMatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $EverliMatchesTable> {
  $$EverliMatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EverliMatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EverliMatchesTable> {
  $$EverliMatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => column,
  );
}

class $$EverliMatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EverliMatchesTable,
          EverliMatche,
          $$EverliMatchesTableFilterComposer,
          $$EverliMatchesTableOrderingComposer,
          $$EverliMatchesTableAnnotationComposer,
          $$EverliMatchesTableCreateCompanionBuilder,
          $$EverliMatchesTableUpdateCompanionBuilder,
          (
            EverliMatche,
            BaseReferences<_$AppDatabase, $EverliMatchesTable, EverliMatche>,
          ),
          EverliMatche,
          PrefetchHooks Function()
        > {
  $$EverliMatchesTableTableManager(_$AppDatabase db, $EverliMatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EverliMatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EverliMatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EverliMatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<int> storeId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<DateTime> confirmedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EverliMatchesCompanion(
                code: code,
                storeId: storeId,
                productId: productId,
                confirmedAt: confirmedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required int storeId,
                required int productId,
                required DateTime confirmedAt,
                Value<int> rowid = const Value.absent(),
              }) => EverliMatchesCompanion.insert(
                code: code,
                storeId: storeId,
                productId: productId,
                confirmedAt: confirmedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EverliMatchesTable, EverliMatche>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EverliMatchesTable,
                    EverliMatche
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EverliMatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EverliMatchesTable,
      EverliMatche,
      $$EverliMatchesTableFilterComposer,
      $$EverliMatchesTableOrderingComposer,
      $$EverliMatchesTableAnnotationComposer,
      $$EverliMatchesTableCreateCompanionBuilder,
      $$EverliMatchesTableUpdateCompanionBuilder,
      (
        EverliMatche,
        BaseReferences<_$AppDatabase, $EverliMatchesTable, EverliMatche>,
      ),
      EverliMatche,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PriceCacheTableTableManager get priceCache =>
      $$PriceCacheTableTableManager(_db, _db.priceCache);
  $$CatalogTableTableManager get catalog =>
      $$CatalogTableTableManager(_db, _db.catalog);
  $$CartLinesTableTableManager get cartLines =>
      $$CartLinesTableTableManager(_db, _db.cartLines);
  $$KeyValuesTableTableManager get keyValues =>
      $$KeyValuesTableTableManager(_db, _db.keyValues);
  $$EverliCacheTableTableManager get everliCache =>
      $$EverliCacheTableTableManager(_db, _db.everliCache);
  $$EverliMatchesTableTableManager get everliMatches =>
      $$EverliMatchesTableTableManager(_db, _db.everliMatches);
}
