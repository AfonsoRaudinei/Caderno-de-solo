class PerfilAssets {
  final String? logoUrl;
  final String? assinaturaUrl;
  final bool isUploadingLogo;
  final bool isUploadingAssinatura;

  const PerfilAssets({
    this.logoUrl,
    this.assinaturaUrl,
    this.isUploadingLogo = false,
    this.isUploadingAssinatura = false,
  });

  PerfilAssets copyWith({
    String? logoUrl,
    String? assinaturaUrl,
    bool? isUploadingLogo,
    bool? isUploadingAssinatura,
  }) {
    return PerfilAssets(
      logoUrl: logoUrl ?? this.logoUrl,
      assinaturaUrl: assinaturaUrl ?? this.assinaturaUrl,
      isUploadingLogo: isUploadingLogo ?? this.isUploadingLogo,
      isUploadingAssinatura:
          isUploadingAssinatura ?? this.isUploadingAssinatura,
    );
  }
}
