import 'package:flutter/material.dart';

// --- HELPER FORMAT TANGGAL ---
String _formatTanggal(DateTime date) {
  final hari = date.day.toString().padLeft(2, '0');
  final bulan = date.month.toString().padLeft(2, '0');
  final tahun = date.year;
  final jam = date.hour.toString().padLeft(2, '0');
  final menit = date.minute.toString().padLeft(2, '0');
  return '$hari/$bulan/$tahun $jam:$menit';
}

// --- MODEL DATA (DENGAN TAMBAHAN ID & EMAIL) ---
class Catatan {
  final String id; // Diperlukan untuk mencocokkan data saat Edit
  final String judul;
  final String isi;
  final String kategori;
  final String email; // Field baru untuk Email pengirim
  final DateTime dibuatPada;

  Catatan({
    required this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.email,
    required this.dibuatPada,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/tambah':
          // Menerima arguments opsional. Jika dari tombol edit, arguments berisi objek Catatan.
            final catatanLama = settings.arguments as Catatan?;
            return MaterialPageRoute(
              builder: (_) => TambahCatatanPage(catatanLama: catatanLama),
            );

          case '/detail':
            if (settings.arguments is Catatan) {
              final catatan = settings.arguments as Catatan;
              return MaterialPageRoute(
                builder: (_) => DetailCatatanPage(catatan: catatan),
              );
            }
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                    child: Text('Error: Data Catatan tidak ditemukan atau format salah.')),
              ),
            );
        }
        return null;
      },
      routes: {
        '/': (context) => const HomePage(),
      },
    );
  }
}

// --- HALAMAN FORM (REUSE UNTUK TAMBAH & EDIT) ---
class TambahCatatanPage extends StatefulWidget {
  final Catatan? catatanLama; // Jika tidak null, berarti mode EDIT
  const TambahCatatanPage({super.key, this.catatanLama});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();

  // Menggunakan 'late' agar inisialisasi bisa membaca widget.catatanLama di initState
  late TextEditingController _judulCtrl;
  late TextEditingController _isiCtrl;
  late TextEditingController _emailCtrl; // Controller baru untuk Email
  late String _kategori;

  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    // Jika mode edit, isi field dengan data lama. Jika tambah, kosongkan.
    _judulCtrl = TextEditingController(text: widget.catatanLama?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.catatanLama?.isi ?? '');
    _emailCtrl = TextEditingController(text: widget.catatanLama?.email ?? '');
    _kategori = widget.catatanLama?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatanResult = Catatan(
      // Jika edit, pakai ID lama. Jika tambah, buat ID unik dari timestamp.
      id: widget.catatanLama?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      email: _emailCtrl.text.trim(),
      dibuatPada: widget.catatanLama?.dibuatPada ?? DateTime.now(),
    );

    Navigator.pop(context, catatanResult);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.catatanLama != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                if (v.trim().length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriOpsi
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 16),
            // --- FIELD EMAIL + VALIDASI REGEX ---
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Pengirim',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                // Pattern Regex Email Standar
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(v.trim())) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: Icon(isEdit ? Icons.update : Icons.save),
              label: Text(isEdit ? 'Update Catatan' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN HOME (DENGAN FILTER KATEGORI) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _kategoriTerpilih = 'Semua'; // State penampung filter aktif

  final List<Catatan> _catatan = [
    Catatan(
      id: 'dummy_1',
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation.',
      kategori: 'Kuliah',
      email: 'yafi@unpas.ac.id',
      dibuatPada: DateTime.now(),
    ),
  ];

  // Fungsi Logika Upsert (Update jika ID ada, Insert jika ID baru)
  void _tambahAtauUpdateCatatan(Catatan hasil) {
    setState(() {
      final index = _catatan.indexWhere((c) => c.id == hasil.id);
      if (index != -1) {
        _catatan[index] = hasil; // Mengupdate list (bukan menambah baru)
      } else {
        _catatan.add(hasil); // Menambah baru
      }
    });
  }

  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (hasil is Catatan) {
      _tambahAtauUpdateCatatan(hasil);

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan "${hasil.judul}" ditambahkan')),
      );
    }
  }

  void _hapusCatatan(int index, String idAsli) {
    final judulDihapus = _catatan.firstWhere((c) => c.id == idAsli).judul;

    setState(() {
      _catatan.removeWhere((c) => c.id == idAsli);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Catatan "$judulDihapus" dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA FILTERING ---
    final listTerfilter = _kategoriTerpilih == 'Semua'
        ? _catatan
        : _catatan.where((c) => c.kategori == _kategoriTerpilih).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
        actions: [
          // --- DROPDOWN FILTER DI APPBAR ---
          DropdownButton<String>(
            value: _kategoriTerpilih,
            underline: const SizedBox(), // Menghilangkan garis bawah bawaan dropdown
            items: const ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya']
                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _kategoriTerpilih = v);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: listTerfilter.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _catatan.isEmpty ? 'Belum ada catatan' : 'Tidak ada catatan di kategori $_kategoriTerpilih',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: listTerfilter.length,
        itemBuilder: (context, i) {
          final c = listTerfilter[i];
          return ListTile(
            title: Text(c.judul),
            subtitle: Text('${c.kategori} • ${c.email}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _hapusCatatan(i, c.id),
            ),
            onTap: () async {
              // Menunggu data balik dari halaman detail jika terjadi pengeditan data di sana
              final hasilBalik = await Navigator.pushNamed(context, '/detail', arguments: c);
              if (hasilBalik is Catatan) {
                _tambahAtauUpdateCatatan(hasilBalik);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahCatatan,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- HALAMAN DETAIL (DENGAN RE-ROUTE TOMBOL EDIT) ---
class DetailCatatanPage extends StatefulWidget {
  final Catatan catatan;
  const DetailCatatanPage({super.key, required this.catatan});

  @override
  State<DetailCatatanPage> createState() => _DetailCatatanPageState();
}

class _DetailCatatanPageState extends State<DetailCatatanPage> {
  late Catatan _currentCatatan;

  @override
  void initState() {
    super.initState();
    _currentCatatan = widget.catatan; // Simpan ke state lokal agar UI halaman detail bisa ikut update setelah edit
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        // Mengubah fungsi back tombol bawaan agar membawa objek terbaru kembali ke Home
        leading: BackButton(
          onPressed: () => Navigator.pop(context, _currentCatatan),
        ),
        actions: [
          // --- TOMBOL EDIT DI APPBAR DETAIL ---
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              // Lempar data saat ini ke TambahCatatanPage dengan argument
              final hasilEdit = await Navigator.pushNamed(
                context,
                '/tambah',
                arguments: _currentCatatan,
              );

              // Jika user menekan "Update Catatan", update state halaman detail ini
              if (hasilEdit is Catatan) {
                setState(() => _currentCatatan = hasilEdit);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentCatatan.judul,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(_currentCatatan.kategori)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Oleh: ${_currentCatatan.email}',
                    style: const TextStyle(color: Colors.grey, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatTanggal(_currentCatatan.dibuatPada),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Divider(height: 32),
            Text(_currentCatatan.isi,
                style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 48),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, _currentCatatan),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Daftar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}