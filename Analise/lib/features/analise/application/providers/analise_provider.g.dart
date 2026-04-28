// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analise_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analiseLocalDatasourceHash() =>
    r'dce5bc89e8c294e2b5f1e1e83da5d3075bf4e6ee';

/// See also [analiseLocalDatasource].
@ProviderFor(analiseLocalDatasource)
final analiseLocalDatasourceProvider =
    AutoDisposeProvider<AnaliseLocalDatasource>.internal(
  analiseLocalDatasource,
  name: r'analiseLocalDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analiseLocalDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnaliseLocalDatasourceRef
    = AutoDisposeProviderRef<AnaliseLocalDatasource>;
String _$analiseRepositoryHash() => r'7ff7f6609e64b8fa480e7bc4c3e8d32a521fbc54';

/// See also [analiseRepository].
@ProviderFor(analiseRepository)
final analiseRepositoryProvider =
    AutoDisposeProvider<AnaliseRepository>.internal(
  analiseRepository,
  name: r'analiseRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analiseRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnaliseRepositoryRef = AutoDisposeProviderRef<AnaliseRepository>;
String _$getAnalisesUsecaseHash() =>
    r'0ca9b26f3d4cc3094f658629527563e59cf97ba1';

/// See also [getAnalisesUsecase].
@ProviderFor(getAnalisesUsecase)
final getAnalisesUsecaseProvider =
    AutoDisposeProvider<GetAnalisesUsecase>.internal(
  getAnalisesUsecase,
  name: r'getAnalisesUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getAnalisesUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetAnalisesUsecaseRef = AutoDisposeProviderRef<GetAnalisesUsecase>;
String _$saveAnaliseUsecaseHash() =>
    r'aa695685b8615f396536c4d6c5587b7648b3d7cc';

/// See also [saveAnaliseUsecase].
@ProviderFor(saveAnaliseUsecase)
final saveAnaliseUsecaseProvider =
    AutoDisposeProvider<SaveAnaliseUsecase>.internal(
  saveAnaliseUsecase,
  name: r'saveAnaliseUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$saveAnaliseUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SaveAnaliseUsecaseRef = AutoDisposeProviderRef<SaveAnaliseUsecase>;
String _$deleteAnaliseUsecaseHash() =>
    r'a9936307008428f76dc75579c9d0405f1f53c1d8';

/// See also [deleteAnaliseUsecase].
@ProviderFor(deleteAnaliseUsecase)
final deleteAnaliseUsecaseProvider =
    AutoDisposeProvider<DeleteAnaliseUsecase>.internal(
  deleteAnaliseUsecase,
  name: r'deleteAnaliseUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteAnaliseUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteAnaliseUsecaseRef = AutoDisposeProviderRef<DeleteAnaliseUsecase>;
String _$authStateHash() => r'd8eb17123e8971f9b8086bb415a4b2bde52779e2';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;
String _$analisesFiltradasHash() => r'ff1b69529bd3ec2e6324edbd259d729e37ca37af';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [analisesFiltradas].
@ProviderFor(analisesFiltradas)
const analisesFiltradasProvider = AnalisesFiltradasFamily();

/// See also [analisesFiltradas].
class AnalisesFiltradasFamily extends Family<List<AnaliseSolo>> {
  /// See also [analisesFiltradas].
  const AnalisesFiltradasFamily();

  /// See also [analisesFiltradas].
  AnalisesFiltradasProvider call({
    Cultura? cultura,
    String? produtorId,
    String? safra,
    String? busca,
  }) {
    return AnalisesFiltradasProvider(
      cultura: cultura,
      produtorId: produtorId,
      safra: safra,
      busca: busca,
    );
  }

  @override
  AnalisesFiltradasProvider getProviderOverride(
    covariant AnalisesFiltradasProvider provider,
  ) {
    return call(
      cultura: provider.cultura,
      produtorId: provider.produtorId,
      safra: provider.safra,
      busca: provider.busca,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'analisesFiltradasProvider';
}

/// See also [analisesFiltradas].
class AnalisesFiltradasProvider extends AutoDisposeProvider<List<AnaliseSolo>> {
  /// See also [analisesFiltradas].
  AnalisesFiltradasProvider({
    Cultura? cultura,
    String? produtorId,
    String? safra,
    String? busca,
  }) : this._internal(
          (ref) => analisesFiltradas(
            ref as AnalisesFiltradasRef,
            cultura: cultura,
            produtorId: produtorId,
            safra: safra,
            busca: busca,
          ),
          from: analisesFiltradasProvider,
          name: r'analisesFiltradasProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$analisesFiltradasHash,
          dependencies: AnalisesFiltradasFamily._dependencies,
          allTransitiveDependencies:
              AnalisesFiltradasFamily._allTransitiveDependencies,
          cultura: cultura,
          produtorId: produtorId,
          safra: safra,
          busca: busca,
        );

  AnalisesFiltradasProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cultura,
    required this.produtorId,
    required this.safra,
    required this.busca,
  }) : super.internal();

  final Cultura? cultura;
  final String? produtorId;
  final String? safra;
  final String? busca;

  @override
  Override overrideWith(
    List<AnaliseSolo> Function(AnalisesFiltradasRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnalisesFiltradasProvider._internal(
        (ref) => create(ref as AnalisesFiltradasRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cultura: cultura,
        produtorId: produtorId,
        safra: safra,
        busca: busca,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<AnaliseSolo>> createElement() {
    return _AnalisesFiltradasProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnalisesFiltradasProvider &&
        other.cultura == cultura &&
        other.produtorId == produtorId &&
        other.safra == safra &&
        other.busca == busca;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cultura.hashCode);
    hash = _SystemHash.combine(hash, produtorId.hashCode);
    hash = _SystemHash.combine(hash, safra.hashCode);
    hash = _SystemHash.combine(hash, busca.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnalisesFiltradasRef on AutoDisposeProviderRef<List<AnaliseSolo>> {
  /// The parameter `cultura` of this provider.
  Cultura? get cultura;

  /// The parameter `produtorId` of this provider.
  String? get produtorId;

  /// The parameter `safra` of this provider.
  String? get safra;

  /// The parameter `busca` of this provider.
  String? get busca;
}

class _AnalisesFiltradasProviderElement
    extends AutoDisposeProviderElement<List<AnaliseSolo>>
    with AnalisesFiltradasRef {
  _AnalisesFiltradasProviderElement(super.provider);

  @override
  Cultura? get cultura => (origin as AnalisesFiltradasProvider).cultura;
  @override
  String? get produtorId => (origin as AnalisesFiltradasProvider).produtorId;
  @override
  String? get safra => (origin as AnalisesFiltradasProvider).safra;
  @override
  String? get busca => (origin as AnalisesFiltradasProvider).busca;
}

String _$analiseNotifierHash() => r'86736c9aeb553f4a276792bbbf0e72f035c5a669';

/// See also [AnaliseNotifier].
@ProviderFor(AnaliseNotifier)
final analiseNotifierProvider =
    StreamNotifierProvider<AnaliseNotifier, List<AnaliseSolo>>.internal(
  AnaliseNotifier.new,
  name: r'analiseNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analiseNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AnaliseNotifier = StreamNotifier<List<AnaliseSolo>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
