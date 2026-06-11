import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'main.dart' show Catatan;

// ============================================================
// Exception kustom agar UI bisa tampilkan pesan yang tepat
// ============================================================
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ============================================================
// ApiClient — Singleton, menggantikan DbHelper dari Pertemuan 4/5
// Signature method sengaja disamakan agar perubahan UI minimal.
// ============================================================
class ApiClient {
  ApiClient._(); // private constructor
  static final ApiClient instance = ApiClient._(); // singleton

  // === Konfigurasi API (lihat kontrak API di modul) ===
  static const String _baseUrl =
      'https://besab-production.up.railway.app/api';
  static const String _apiKey =
      '8f38b5fbf0bc437285f2c62ed6e447eab56f78c8f95239a7';
  // =====================================================

  static const _timeout = Duration(seconds: 10);

  /// Header yang selalu disertakan di setiap request.
  Map<String, String> get _headers => {
        'X-API-Key': _apiKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ===== CRUD =====

  /// GET /catatan — ambil semua catatan
  Future<List<Catatan>> getAll() async {
    final res = await _send(
      () => http.get(Uri.parse('$_baseUrl/catatan'), headers: _headers),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['data'] as List).cast<Map<String, dynamic>>();
    return list.map(Catatan.fromJson).toList();
  }

  /// GET /catatan/{id} — ambil satu catatan
  Future<Catatan> getById(int id) async {
    final res = await _send(
      () => http.get(Uri.parse('$_baseUrl/catatan/$id'), headers: _headers),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Catatan.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// POST /catatan — buat catatan baru, kembalikan objek hasil server
  Future<Catatan> insert(Catatan c) async {
    final res = await _send(
      () => http.post(
        Uri.parse('$_baseUrl/catatan'),
        headers: _headers,
        body: jsonEncode(c.toJson()),
      ),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Catatan.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// PUT /catatan/{id} — perbarui catatan, kembalikan objek terbaru
  Future<Catatan> update(Catatan c) async {
    assert(c.id != null, 'id harus ada untuk update');
    final res = await _send(
      () => http.put(
        Uri.parse('$_baseUrl/catatan/${c.id}'),
        headers: _headers,
        body: jsonEncode(c.toJson()),
      ),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Catatan.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// DELETE /catatan/{id} — hapus catatan
  Future<void> delete(int id) async {
    await _send(
      () => http.delete(Uri.parse('$_baseUrl/catatan/$id'), headers: _headers),
    );
  }

  // ===== Helper: kirim request + tangani 3 kelas error =====

  /// Kirim request, periksa status code.
  /// - 2xx → kembalikan response
  /// - 4xx / 5xx → throw ApiException dengan pesan dari body JSON
  /// - SocketException → tidak ada koneksi internet
  /// - TimeoutException → server tidak merespons dalam [_timeout]
  Future<http.Response> _send(Future<http.Response> Function() req) async {
    try {
      final res = await req().timeout(_timeout);
      if (res.statusCode >= 200 && res.statusCode < 300) return res;
      throw ApiException(res.statusCode, _extractMessage(res));
    } on SocketException {
      throw ApiException(0, 'Tidak ada koneksi internet.');
    } on TimeoutException {
      throw ApiException(0, 'Server tidak merespons (timeout).');
    }
  }

  /// Coba baca field "message" dari body JSON, fallback ke "HTTP <code>".
  String _extractMessage(http.Response res) {
    try {
      final m = jsonDecode(res.body) as Map<String, dynamic>;
      return (m['message'] as String?) ?? 'HTTP ${res.statusCode}';
    } catch (_) {
      return 'HTTP ${res.statusCode}';
    }
  }
}
