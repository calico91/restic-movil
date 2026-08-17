class VersionHelper {
  /// Compara dos versiones semver (formato X.Y.Z) y retorna:
  ///   -1 si [a] es menor que [b]
  ///    0 si [a] es igual a [b]
  ///    1 si [a] es mayor que [b]
  ///
  /// Reglas:
  ///  - Cada segmento se compara como entero.
  ///  - Las versiones con menos segmentos se rellenan con 0 a la izquierda.
  ///  - Segmentos no numericos se tratan como 0 (la version completa es invalida y
  ///    [isLowerThan] devolvera `false` para que el fail-open no bloquee la app).
  static int compare(String a, String b) {
    final List<int> segsA = _parse(a);
    final List<int> segsB = _parse(b);
    final int maxLen =
        segsA.length > segsB.length ? segsA.length : segsB.length;
    for (int i = 0; i < maxLen; i++) {
      final int va = i < segsA.length ? segsA[i] : 0;
      final int vb = i < segsB.length ? segsB[i] : 0;
      if (va < vb) return -1;
      if (va > vb) return 1;
    }
    return 0;
  }

  /// Retorna `true` si la version instalada [appVersion] es estrictamente menor
  /// que la version minima requerida [minRequiredVersion].
  /// Si alguna version es null, vacia o invalida, retorna `false`
  /// (fail-open: no se fuerza la actualizacion).
  static bool isLowerThan(String? appVersion, String? minRequiredVersion) {
    if (appVersion == null ||
        appVersion.isEmpty ||
        minRequiredVersion == null ||
        minRequiredVersion.isEmpty) {
      return false;
    }
    return compare(appVersion, minRequiredVersion) < 0;
  }

  static List<int> _parse(String version) {
    return version
        .trim()
        .split('.')
        .map((s) => int.tryParse(s.trim()) ?? 0)
        .toList();
  }
}
