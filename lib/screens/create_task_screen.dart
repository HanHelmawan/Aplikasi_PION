import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../models/task_request.dart';
import 'map_location_picker_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _issueController = TextEditingController();
  final _priceController  = TextEditingController();
  final _picker = ImagePicker();

  bool _isProcessing = false;
  bool _isSubmitting = false;
  final List<_TagItem> _tags = [];
  String _whenLabel = 'Sesegera mungkin';
  String _whereLabel = 'Lokasi Saat Ini';

  // Menyimpan file lokal yang dipilih
  final List<File> _localFiles = [];
  // Menyimpan URL setelah upload berhasil
  final List<String> _photoUrls = [];
  // Melacak status upload per gambar
  final List<_UploadState> _uploadStates = [];

  static const int _maxPhotos = 5;

  // ⚠️ MASUKKAN API KEY IMGBB ANDA DI SINI
  // Anda bisa mendapatkannya secara GRATIS di https://api.imgbb.com/
  static const String _imgBbApiKey = '6ef785bec70c2d3c35db2b13174916ec';

  @override
  void dispose() {
    _issueController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onIssueChanged(String value) {
    if (_isProcessing) return;
    if (value.trim().length > 20) {
      setState(() => _isProcessing = true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _tags
            ..clear()
            ..add(_TagItem(label: '#Perbaikan', color: Theme.of(context).colorScheme.primary))
            ..add(_TagItem(label: '#Darurat', color: const Color(0xFFD97706)));
        });
      });
    }
  }

  Future<void> _pickWhen() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (!mounted) return;

    final dateStr = '${date.day}/${date.month}/${date.year}';
    setState(() {
      if (time == null) {
        _whenLabel = dateStr;
      } else {
        final hh = time.hour.toString().padLeft(2, '0');
        final mm = time.minute.toString().padLeft(2, '0');
        _whenLabel = '$dateStr · $hh:$mm WIB';
      }
    });
  }

  Future<void> _pickWhere() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const MapLocationPickerScreen(
          title: 'Pilih Lokasi Pekerjaan',
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _whereLabel = result['address'] as String);
    }
  }

  /// Tampilkan bottom sheet pilih sumber gambar (kamera / galeri)
  Future<void> _showImageSourceSheet() async {
    if (_localFiles.length >= _maxPhotos) return;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Foto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih sumber gambar untuk dilampirkan',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Pilih gambar lalu langsung upload ke ImgBB
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Kompresi untuk menghemat kuota dan mempermudah upload
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (xFile == null || !mounted) return;

      final file = File(xFile.path);
      final index = _localFiles.length;

      setState(() {
        _localFiles.add(file);
        _photoUrls.add(''); // placeholder kosong
        _uploadStates.add(_UploadState.uploading);
      });

      await _uploadToImgBB(file, index);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Upload file ke ImgBB secara gratis
  Future<void> _uploadToImgBB(File file, int index) async {
    if (_imgBbApiKey == 'YOUR_IMGBB_API_KEY') {
      if (mounted) {
        setState(() {
          _uploadStates[index] = _UploadState.error;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API Key ImgBB belum dikonfigurasi di create_task_screen.dart'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBbApiKey'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data['data']['url'] as String;

        if (mounted) {
          setState(() {
            _photoUrls[index] = url;
            _uploadStates[index] = _UploadState.done;
          });
        }
      } else {
        throw Exception('Server merespon dengan status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadStates[index] = _UploadState.error;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupload foto ${index + 1}: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Coba upload ulang gambar yang error
  Future<void> _retryUpload(int index) async {
    if (index >= _localFiles.length) return;
    setState(() => _uploadStates[index] = _UploadState.uploading);
    await _uploadToImgBB(_localFiles[index], index);
  }

  /// Hapus gambar dari list
  void _removePhoto(int index) {
    setState(() {
      _localFiles.removeAt(index);
      _photoUrls.removeAt(index);
      _uploadStates.removeAt(index);
    });
  }

  bool get _hasUploadInProgress =>
      _uploadStates.any((s) => s == _UploadState.uploading);

  Future<void> _submit() async {
    if (_issueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Mohon deskripsikan masalah Anda.'),
        backgroundColor: Color(0xFFDC2626),
      ));
      return;
    }

    if (_hasUploadInProgress) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Mohon tunggu, foto sedang diupload...'),
        backgroundColor: Color(0xFFD97706),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // Saring hanya URL yang berhasil diupload
    final uploadedUrls = _photoUrls.where((url) => url.isNotEmpty).toList();

    final rawPrice = double.tryParse(
      _priceController.text.replaceAll('.', '').replaceAll(',', ''),
    ) ?? 0;

    setState(() => _isSubmitting = true);

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final request = TaskRequest(
      id: FirebaseFirestore.instance.collection('task_requests').doc().id,
      userId: uid,
      title: _issueController.text.trim(),
      category: _tags.isNotEmpty ? _tags.first.label : 'Umum',
      location: _whereLabel,
      scheduledAt: _whenLabel,
      estimatedPrice: rawPrice,
      photoUrls: uploadedUrls,
      createdAt: DateTime.now(),
    );

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await TaskRequestStore.instance.add(request);

      setState(() => _isSubmitting = false);

      navigator.popUntil((route) => route.isFirst);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Permintaan berhasil dikirim! Cek riwayat di Profil.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim permintaan: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Buat Permintaan'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: theme.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Issue Description ───────────────────────────────────────────
            _sectionTitle('Apa masalahnya?'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _issueController,
                onChanged: _onIssueChanged,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Pipa di kamar mandi bocor dan air menetes ke lantai...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── AI Tags ────────────────────────────────────────────────────
            if (_isProcessing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Menganalisis masalah...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              )
            else if (_tags.isNotEmpty) ...[
              const Text(
                'Kategori Terdeteksi',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: t.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t.color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    t.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: t.color,
                    ),
                  ),
                )).toList(),
              ),
            ],
            const SizedBox(height: 32),

            // ── When & Where ───────────────────────────────────────────────
            _sectionTitle('Kapan & Di mana?'),
            const SizedBox(height: 12),
            _optionRow(
              icon: Icons.calendar_today_rounded,
              label: 'Kapan',
              value: _whenLabel,
              onTap: _pickWhen,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _optionRow(
              icon: Icons.location_on_rounded,
              label: 'Lokasi',
              value: _whereLabel,
              onTap: _pickWhere,
              theme: theme,
            ),
            const SizedBox(height: 32),

            // ── Estimated Price ─────────────────────────────────────────────
            _sectionTitle('Harga Estimasi Anda'),
            const SizedBox(height: 6),
            const Text(
              'Masukkan perkiraan harga yang bersedia Anda bayarkan.',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Rp',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Photos ─────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('Foto Tambahan'),
                Text(
                  '${_localFiles.length}/$_maxPhotos',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Tambahkan foto dari kamera atau galeri untuk memperjelas masalah.',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Tombol tambah foto
                  if (_localFiles.length < _maxPhotos)
                    GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: Container(
                        width: 100, height: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              color: theme.colorScheme.primary,
                              size: 30,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tambah',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Daftar gambar yang dipilih
                  ..._localFiles.asMap().entries.map((entry) {
                    final i = entry.key;
                    final file = entry.value;
                    final state = _uploadStates[i];

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _PhotoThumbnail(
                        file: file,
                        uploadState: state,
                        onRemove: () => _removePhoto(i),
                        onRetry: () => _retryUpload(i),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // ── Submit ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: (_isSubmitting || _hasUploadInProgress) ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _hasUploadInProgress
                            ? 'Mengupload foto...'
                            : 'Lanjutkan',
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: Color(0xFF0F172A),
    ),
  );

  static Widget _optionRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required ThemeData theme,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 24),
            ],
          ),
        ),
      );
}

// ─── Upload state enum ──────────────────────────────────────────────────────
enum _UploadState { uploading, done, error }

// ─── Photo thumbnail widget ─────────────────────────────────────────────────
class _PhotoThumbnail extends StatelessWidget {
  final File file;
  final _UploadState uploadState;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  const _PhotoThumbnail({
    required this.file,
    required this.uploadState,
    required this.onRemove,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, height: 100,
      child: Stack(
        children: [
          // Gambar
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              file,
              width: 100, height: 100,
              fit: BoxFit.cover,
            ),
          ),

          // Overlay status upload
          if (uploadState == _UploadState.uploading)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.black45,
                  child: const Center(
                    child: SizedBox(
                      width: 28, height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Error overlay – tap untuk retry
          if (uploadState == _UploadState.error)
            Positioned.fill(
              child: GestureDetector(
                onTap: onRetry,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.red.withValues(alpha: 0.75),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                        SizedBox(height: 2),
                        Text(
                          'Coba lagi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Badge sukses
          if (uploadState == _UploadState.done)
            Positioned(
              bottom: 6, left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 10),
                    SizedBox(width: 2),
                    Text(
                      'Uploaded',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),

          // Tombol hapus
          Positioned(
            top: 4, right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22, height: 22,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Image source option widget ─────────────────────────────────────────────
class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primary, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagItem {
  final String label;
  final Color color;
  _TagItem({required this.label, required this.color});
}
