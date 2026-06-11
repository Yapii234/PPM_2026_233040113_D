// Widget test untuk Pertemuan 6 — Catatan Mahasiswa (REST API)
//
// Smoke test sederhana: pastikan app bisa di-render tanpa crash.

import 'package:flutter_test/flutter_test.dart';

import 'package:pertemuan_6/main.dart';

void main() {
  testWidgets('App smoke test — halaman Home dapat di-render',
      (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());

    // Verifikasi AppBar "Catatan Mahasiswa" muncul
    expect(find.text('Catatan Mahasiswa'), findsOneWidget);
  });
}
