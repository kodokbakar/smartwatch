/// MinidenticonGenerator
/// --------------------
/// Generator identicon SVG yang ringan untuk avatar default.
///
/// Catatan implementasi:
/// - Pola berupa grid 5x5 dengan simetri vertikal (hanya 3 kolom dihitung, lalu di-mirror).
/// - Pola diambil dari 15 bit terakhir hash (3 * 5 = 15). :contentReference[oaicite:1]{index=1}
/// - Warna memakai HSL, dan hue dipetakan ke 18 variasi agar konsisten. :contentReference[oaicite:2]{index=2}
/// - Output SVG sengaja dibuat dengan padding agar tetap bagus saat dipotong (circle avatar).
///
/// Kenapa ada cache?
/// - Avatar biasanya dihitung berulang pada rebuild.
/// - Cache sederhana mengurangi alokasi string SVG yang sama.
///
/// Tidak ada dependency eksternal (selain render SVG di layer UI via flutter_svg).
library minidenticon_generator;

class MinidenticonGenerator {
  // Ukuran grid final.
  static const int _gridSize = 5;

  // Kolom yang dihitung (3), sisanya hasil mirror -> 5 kolom total.
  static const int _halfCols = 3;

  // Total bit pola yang dipakai: 3 kolom * 5 baris = 15 bit.
  static const int _patternBits = 15;

  // Cache kecil agar tidak generate string SVG berulang untuk seed yang sama.
  static final Map<String, String> _svgCache = <String, String>{};

  /// Generate SVG identicon dari [seed] (biasanya username).
  ///
  /// [saturation] dan [lightness] dalam persen (0..100).
  /// Default mengikuti rekomendasi umum minidenticons.
  static String svg(
    String seed, {
    int saturation = 95,
    int lightness = 45,
  }) {
    final normalized = seed.trim().isEmpty ? 'user' : seed.trim();

    final cacheKey = '$normalized|$saturation|$lightness';
    final cached = _svgCache[cacheKey];
    if (cached != null) return cached;

    final hash = _fnv1a32(normalized);

    // Hue dibuat “diskrit” agar variasi tidak terlalu liar, tapi tetap beda-beda.
    // 18 variasi hue untuk tema yang sama. :contentReference[oaicite:3]{index=3}
    final hueIndex = _positiveMod(hash, 18);
    final hue = (hueIndex * 360 ~/ 18);

    // Ambil 15 bit terakhir untuk pola. :contentReference[oaicite:4]{index=4}
    final bits = hash & ((1 << _patternBits) - 1);

    final grid = _buildPattern(bits);

    // SVG coordinate system:
    // - viewBox 0..100 supaya gampang diskalakan.
    // - grid 5x5 ditempatkan di tengah dengan padding agar siap untuk circle crop.
    const int view = 100;
    const int padding = 20;
    const int cell = 12; // 5*12 = 60, padding 20 kiri/kanan -> total 100

    final color = 'hsl($hue, $saturation%, $lightness%)';
    final sb = StringBuffer()
      ..write(
        '<svg xmlns="http://www.w3.org/2000/svg" '
        'viewBox="0 0 $view $view" shape-rendering="crispEdges">',
      );

    // Render hanya sel yang aktif untuk menghemat ukuran SVG.
    for (var r = 0; r < _gridSize; r++) {
      for (var c = 0; c < _gridSize; c++) {
        if (!grid[r][c]) continue;
        final x = padding + (c * cell);
        final y = padding + (r * cell);
        sb.write(
          '<rect x="$x" y="$y" width="$cell" height="$cell" fill="$color" />',
        );
      }
    }

    sb.write('</svg>');

    final result = sb.toString();
    _svgCache[cacheKey] = result;
    return result;
  }

  /// Membangun pola 5x5 yang simetris vertikal.
  ///
  /// Supaya tampak lebih “terpusat”, sel dekat tengah diberi peluang deterministik
  /// untuk aktif lebih tinggi (tanpa random).
  static List<List<bool>> _buildPattern(int bits) {
    final grid = List.generate(
      _gridSize,
      (_) => List<bool>.filled(_gridSize, false),
    );

    // Kita hitung 3 kolom pertama, lalu mirror ke kolom kanan.
    for (var r = 0; r < _gridSize; r++) {
      for (var c = 0; c < _halfCols; c++) {
        final idx = (r * _halfCols) + c; // 0..14
        final base = (bits >> idx) & 1;

        // Heuristik deterministik agar pusat lebih sering aktif:
        // - Ambil bit pembanding dari posisi lain (di-offset).
        // - Terapkan aturan berbeda berdasarkan jarak ke pusat.
        final extra = (bits >> ((idx + 7) % _patternBits)) & 1;

        final dist = (r - 2).abs() + (c - 1).abs(); // pusat ~ (2,1)
        final filled = switch (dist) {
          0 => (base | extra) == 1,     // pusat: lebih sering menyala
          1 => base == 1,               // sekitar pusat: normal
          _ => (base & extra) == 1,     // pinggir: lebih jarang
        };

        // Set kiri (c) dan kanan (mirror).
        grid[r][c] = filled;
        grid[r][_gridSize - 1 - c] = filled;
      }
    }

    return grid;
  }

  /// Hash FNV-1a 32-bit (cepat, hasil stabil lintas platform).
  static int _fnv1a32(String input) {
    const int fnvOffset = 0x811C9DC5;
    const int fnvPrime = 0x01000193;

    var hash = fnvOffset;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash;
  }

  static int _positiveMod(int value, int mod) {
    final r = value % mod;
    return r < 0 ? r + mod : r;
  }
}
