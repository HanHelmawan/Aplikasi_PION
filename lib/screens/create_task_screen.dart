import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_request.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _issueController = TextEditingController();
  final _priceController  = TextEditingController();

  bool _isProcessing = false;
  final List<_TagItem> _tags = [];
  String _whenLabel = 'Sesegera mungkin';
  String _whereLabel = 'Lokasi Saat Ini';
  final List<String> _photoUrls = [];

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
    setState(() => _whereLabel = 'Jl. Sudirman No. 12, Jakarta');
  }

  void _addPhoto() {
    setState(() => _photoUrls.add('https://picsum.photos/seed/${_photoUrls.length + 1}/200/200'));
  }

  void _submit() {
    if (_issueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon deskripsikan masalah Anda.'), backgroundColor: Color(0xFFDC2626)));
      return;
    }
    final rawPrice = double.tryParse(_priceController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;

    final request = TaskRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
      title: _issueController.text.trim(),
      category: _tags.isNotEmpty ? _tags.first.label : 'Umum',
      location: _whereLabel,
      scheduledAt: _whenLabel,
      estimatedPrice: rawPrice,
      photoUrls: List.from(_photoUrls),
      createdAt: DateTime.now(),
    );
    TaskRequestStore.instance.add(request);

    // Return to home and show confirmation
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permintaan berhasil dikirim! Cek riwayat di Profil.', style: TextStyle(fontFamily: 'Inter')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Buat Permintaan'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: theme.dividerColor)),
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
                decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2.5, color: theme.colorScheme.primary)),
                    const SizedBox(width: 12),
                    Text('Menganalisis masalah...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                  ],
                ),
              )
            else if (_tags.isNotEmpty) ...[
              const Text('Kategori Terdeteksi', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
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
                  child: Text(t.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.color)),
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
                      color: const Color(0xFFEEF0FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Rp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0525BB), fontFamily: 'Inter')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
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
                Text('${_photoUrls.length}/5', style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_photoUrls.length < 5)
                    GestureDetector(
                      onTap: _addPhoto,
                      child: Container(
                        width: 100, height: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Icon(Icons.add_photo_alternate_rounded, color: theme.colorScheme.primary, size: 32),
                      ),
                    ),
                  ..._photoUrls.map((url) => Container(
                    width: 100, height: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // ── Submit ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Lanjutkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
  );

  static Widget _optionRow({required IconData icon, required String label, required String value, required VoidCallback onTap, required ThemeData theme}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 24),
            ],
          ),
        ),
      );
}

class _TagItem {
  final String label;
  final Color color;
  _TagItem({required this.label, required this.color});
}
