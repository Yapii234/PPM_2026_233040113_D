import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Profil',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ProfilePage(),
    );
  }
}

// model untuk menyimpan data pengalaman
class ExperienceItem {
  File? image;
  Uint8List? imageBytes; // khusus web
  String title;
  String description;

  ExperienceItem({
    this.image,
    this.imageBytes,
    required this.title,
    required this.description,
  });
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  Uint8List? _profileImageBytes;
  String _name = 'Muhammad Yafi Nasrulloh';
  String _bio = 'Dev Code';
  String _pendidikan = 'Universitas Pasundan\nTeknik Informatika';
  String _lokasi = 'Bandung, Jawa Barat';
  String _kontak = 'yapi@email.com\n088-999-999-999';
  final List<ExperienceItem> _experiences = [];

  // buka halaman edit profil dan ambil hasilnya
  Future<void> _bukaEditProfil() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          currentName: _name,
          currentBio: _bio,
          currentPendidikan: _pendidikan,
          currentLokasi: _lokasi,
          currentKontak: _kontak,
          currentImage: _profileImage,
          currentImageBytes: _profileImageBytes,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _name = result['name'] ?? _name;
        _bio = result['bio'] ?? _bio;
        _pendidikan = result['pendidikan'] ?? _pendidikan;
        _lokasi = result['lokasi'] ?? _lokasi;
        _kontak = result['kontak'] ?? _kontak;
        if (result['imageBytes'] != null) {
          _profileImageBytes = result['imageBytes'] as Uint8List;
        } else if (result['image'] != null) {
          _profileImage = result['image'] as File;
        }
      });
    }
  }

  Future<void> _bukaUploadPengalaman() async {
    final result = await Navigator.push<ExperienceItem>(
      context,
      MaterialPageRoute(builder: (_) => const EditPengalamanPage()),
    );
    if (result != null) {
      setState(() {
        _experiences.add(result);
      });
    }
  }

  ImageProvider _getProfileImage() {
    if (_profileImageBytes != null) return MemoryImage(_profileImageBytes!);
    if (_profileImage != null && !kIsWeb) return FileImage(_profileImage!);
    return const NetworkImage(
        'https://avatars.githubusercontent.com/u/147522409?v=4&size=64');
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: color.primary,
        foregroundColor: Colors.white,
        title: const Text('Profil Saya'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: color.primary),
              child: const Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            const ListTile(leading: Icon(Icons.home), title: Text('Beranda')),
            const ListTile(leading: Icon(Icons.person), title: Text('Profil')),
            // Tugas Mandiri 5: menu pengaturan pakai AlertDialog
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Pengaturan'),
                    content: const Text(
                        'Menu pengaturan saat ini sedang dalam pengembangan.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.widgets),
              title: const Text('Widget Gallery'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const GalleryHome()));
              },
            ),
            // menu tambah pengalaman (bonus tugas 2)
            ListTile(
              leading: const Icon(Icons.collections_bookmark),
              title: const Text('Upload Pengalaman'),
              onTap: () {
                Navigator.pop(context);
                _bukaUploadPengalaman();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tugas Mandiri 1: foto profil dengan NetworkImage, bisa diganti
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    backgroundImage: _getProfileImage(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mahasiswa Teknik Informatika',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // stats
            Row(
              children: const [
                Expanded(child: StatBox(label: 'Post', value: '12')),
                Expanded(child: StatBox(label: 'Teman', value: '109')),
                Expanded(child: StatBox(label: 'Like', value: '1.5K')),
              ],
            ),
            const SizedBox(height: 24),
            // section informasi profil
            SectionCard(icon: Icons.info_outline, title: 'Tentang Saya', content: _bio),
            SectionCard(icon: Icons.school, title: 'Pendidikan', content: _pendidikan),
            SectionCard(icon: Icons.location_on, title: 'Lokasi', content: _lokasi),
            SectionCard(icon: Icons.email, title: 'Kontak', content: _kontak),
            // Tugas Mandiri 3: section ke-5 (skills)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.star, color: color.primary, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Skills',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Wrap(
                            spacing: 8,
                            runSpacing: -4,
                            children: [
                              Chip(label: Text('Flutter')),
                              Chip(label: Text('Java')),
                              Chip(label: Text('PHP')),
                              Chip(label: Text('Cybersecurity')),
                              Chip(label: Text('Laravel')),
                              Chip(label: Text('React js')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // bonus: section pengalaman
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.work, color: color.primary, size: 28),
                        const SizedBox(width: 12),
                        const Text('Pengalaman',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_experiences.length}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    if (_experiences.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Belum ada pengalaman. Tambahkan melalui menu Drawer.',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ..._experiences.map((exp) => Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildExpThumbnail(exp, color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(exp.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text(
                                      exp.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      // Tugas Mandiri 4: FAB untuk edit profil
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaEditProfil,
        icon: const Icon(Icons.edit),
        label: const Text('Edit Profil'),
        backgroundColor: color.primary,
        foregroundColor: Colors.white,
      ),
      // Tugas Mandiri 6 (Bonus): NavigationBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {},
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil'),
          NavigationDestination(
              icon: Icon(Icons.message_outlined),
              selectedIcon: Icon(Icons.message),
              label: 'Pesan'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Setting'),
        ],
      ),
    );
  }

  Widget _buildExpThumbnail(ExperienceItem exp, ColorScheme color) {
    if (exp.imageBytes != null) {
      return Image.memory(exp.imageBytes!,
          width: 60, height: 60, fit: BoxFit.cover);
    } else if (exp.image != null && !kIsWeb) {
      return Image.file(exp.image!,
          width: 60, height: 60, fit: BoxFit.cover);
    }
    return Container(
      width: 60,
      height: 60,
      color: color.primaryContainer,
      child: Icon(Icons.work, color: color.primary),
    );
  }
}

// halaman edit profil (Tugas 1)
class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentBio;
  final String currentPendidikan;
  final String currentLokasi;
  final String currentKontak;
  final File? currentImage;
  final Uint8List? currentImageBytes;

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentBio,
    required this.currentPendidikan,
    required this.currentLokasi,
    required this.currentKontak,
    this.currentImage,
    this.currentImageBytes,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _pendidikanCtrl;
  late TextEditingController _lokasiCtrl;
  late TextEditingController _kontakCtrl;
  File? _foto;
  Uint8List? _fotoBytes;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
    _bioCtrl = TextEditingController(text: widget.currentBio);
    _pendidikanCtrl = TextEditingController(text: widget.currentPendidikan);
    _lokasiCtrl = TextEditingController(text: widget.currentLokasi);
    _kontakCtrl = TextEditingController(text: widget.currentKontak);
    _foto = widget.currentImage;
    _fotoBytes = widget.currentImageBytes;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _pendidikanCtrl.dispose();
    _lokasiCtrl.dispose();
    _kontakCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihGambar() async {
    final picker = ImagePicker();
    final hasil = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (hasil == null) return;

    if (kIsWeb) {
      final bytes = await hasil.readAsBytes();
      setState(() {
        _fotoBytes = bytes;
        _foto = null;
      });
    } else {
      setState(() {
        _foto = File(hasil.path);
        _fotoBytes = null;
      });
    }
  }

  ImageProvider _getAvatar() {
    if (_fotoBytes != null) return MemoryImage(_fotoBytes!);
    if (_foto != null && !kIsWeb) return FileImage(_foto!);
    return const NetworkImage(
        'https://avatars.githubusercontent.com/u/147522409?v=4&size=64');
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameCtrl.text,
        'bio': _bioCtrl.text,
        'pendidikan': _pendidikanCtrl.text,
        'lokasi': _lokasiCtrl.text,
        'kontak': _kontakCtrl.text,
        'image': _foto,
        'imageBytes': _fotoBytes,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: color.primary,
        foregroundColor: Colors.white,
        title: const Text('Edit Profil'),
        actions: [
          TextButton(
            onPressed: _simpan,
            child: const Text('✓ Simpan',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Foto Profil',
                  style: TextStyle(
                      color: color.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _pilihGambar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _getAvatar(),
                      ),
                      // ikon kamera di pojok foto
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _pilihGambar,
                  icon: Icon(Icons.photo_library, color: color.primary, size: 18),
                  label: Text('Ganti Foto dari Galeri',
                      style: TextStyle(color: color.primary)),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text('Informasi Profil',
                  style: TextStyle(
                      color: color.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const SizedBox(height: 16),
              _inputField(
                controller: _nameCtrl,
                label: 'Nama Lengkap *',
                icon: Icons.person,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              _inputField(
                  controller: _bioCtrl,
                  label: 'Bio / Tentang',
                  icon: Icons.info_outline,
                  maxLines: 3),
              const SizedBox(height: 12),
              _inputField(
                  controller: _pendidikanCtrl,
                  label: 'Pendidikan',
                  icon: Icons.school,
                  maxLines: 2),
              const SizedBox(height: 12),
              _inputField(
                  controller: _lokasiCtrl,
                  label: 'Lokasi',
                  icon: Icons.location_on),
              const SizedBox(height: 12),
              _inputField(
                  controller: _kontakCtrl,
                  label: 'Kontak',
                  icon: Icons.email,
                  maxLines: 2),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final color = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color.primary, width: 2),
        ),
      ),
    );
  }
}

// halaman upload pengalaman (bonus tugas 2)
class EditPengalamanPage extends StatefulWidget {
  const EditPengalamanPage({super.key});

  @override
  State<EditPengalamanPage> createState() => _EditPengalamanPageState();
}

class _EditPengalamanPageState extends State<EditPengalamanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _deskCtrl = TextEditingController();
  File? _gambar;
  Uint8List? _gambarBytes;

  @override
  void dispose() {
    _judulCtrl.dispose();
    _deskCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihGambar() async {
    final picker = ImagePicker();
    final hasil = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (hasil == null) return;

    if (kIsWeb) {
      final bytes = await hasil.readAsBytes();
      setState(() {
        _gambarBytes = bytes;
        _gambar = null;
      });
    } else {
      setState(() {
        _gambar = File(hasil.path);
        _gambarBytes = null;
      });
    }
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        ExperienceItem(
          image: _gambar,
          imageBytes: _gambarBytes,
          title: _judulCtrl.text,
          description: _deskCtrl.text,
        ),
      );
    }
  }

  Widget _previewGambar(ColorScheme color) {
    if (_gambarBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(_gambarBytes!,
            fit: BoxFit.cover, width: double.infinity),
      );
    } else if (_gambar != null && !kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_gambar!,
            fit: BoxFit.cover, width: double.infinity),
      );
    }
    // placeholder sebelum ada gambar
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 48, color: color.primary),
        const SizedBox(height: 8),
        Text('Ketuk untuk pilih gambar',
            style: TextStyle(color: color.primary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('dari galeri perangkat kamu',
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: color.primary,
        foregroundColor: Colors.white,
        title: const Text('Upload Pengalaman'),
        actions: [
          TextButton(
            onPressed: _simpan,
            child: const Text('💾 Simpan',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pilihGambar,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: color.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: color.primary.withOpacity(0.5), width: 1.5),
                  ),
                  child: _previewGambar(color),
                ),
              ),
              const SizedBox(height: 24),
              Text('Informasi Pengalaman',
                  style: TextStyle(
                      color: color.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _judulCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Judul tidak boleh kosong' : null,
                decoration: InputDecoration(
                  labelText: 'Judul *',
                  prefixIcon: const Icon(Icons.work),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Pengalaman'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// --- widget helper ---

class StatBox extends StatelessWidget {
  final String label;
  final String value;
  const StatBox({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}

class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const SectionCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(content, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- widget gallery (dari pertemuan sebelumnya) ---

class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Display', Icons.image, Colors.blue),
      ('Input', Icons.edit, Colors.green),
      ('Button', Icons.smart_button, Colors.orange),
      ('Feedback', Icons.notifications, Colors.purple),
      ('Layout', Icons.dashboard, Colors.teal),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Widget Gallery')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                  backgroundColor: cat.$3,
                  child: Icon(cat.$2, color: Colors.white)),
              title: Text(cat.$1),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CategoryPage(name: cat.$1)));
              },
            ),
          );
        },
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final String name;
  const CategoryPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
          child: Text(
              'Konten kategori $name ada di modul (silakan tambahkan class demonya jika diperlukan).')),
    );
  }
}