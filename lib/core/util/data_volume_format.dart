/// Formats a data volume given in GB for display.
///
/// - 1 GB and above: GB, up to 2 decimals, trailing zeros dropped
///   (21.0 → "21 GB", 21.5 → "21.5 GB", 21.3456 → "21.35 GB").
/// - Below 1 GB: whole MB (0.5 → "512 MB"), 1 GB = 1024 MB, matching the
///   conversion used when parsing usage from the API.
///
/// Rounding also hides float noise from subtraction (20.999999… → "21 GB").
String formatDataVolume(double gb) {
  if (gb.isNaN || gb <= 0) return '0 MB';
  if (gb < 1) {
    final mb = (gb * 1024).round();
    // 0.9999 GB rounds to 1024 MB; show it as 1 GB instead.
    return mb >= 1024 ? '1 GB' : '$mb MB';
  }
  return '${_trimZeros(gb.toStringAsFixed(2))} GB';
}

String _trimZeros(String fixed) =>
    fixed.contains('.')
        ? fixed
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '')
        : fixed;
