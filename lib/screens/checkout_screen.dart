import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'active_task_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String taskTitle;
  final String providerName;
  final String category;
  final String? initialDescription;
  final List<String>? initialPhotos;

  const CheckoutScreen({
    super.key,
    this.taskTitle = 'Perbaikan Pipa Bocor',
    this.providerName = 'Belum dipilih',
    this.category = 'Umum',
    this.initialDescription,
    this.initialPhotos,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const int _transportFee = 15000;
  bool _isProcessing = false;

  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final List<String> _photos;
  int _offerPrice = 0;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _priceController = TextEditingController();
    _photos = widget.initialPhotos != null ? List.from(widget.initialPhotos!) : [];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  int get _total => _offerPrice + _transportFee;

  String _fmt(int amount) {
    if (amount == 0) return 'Rp 0';
    final s = amount.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _onPriceChanged(String v) {
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() => _offerPrice = int.tryParse(digits) ?? 0);
  }

  void _addPhoto() => setState(() => _photos.add('https://picsum.photos/seed/${_photos.length + 10}/200/200'));

  void _confirm() async {
    if (_offerPrice == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan penawaran harga Anda.'), backgroundColor: Color(0xFFEF4444)));
      return;
    }
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ActiveTaskScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Konfirmasi Tugas'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: theme.dividerColor)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Task Info ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(16)),
                        child: Icon(Icons.assignment_rounded, color: theme.colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.taskTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            const SizedBox(height: 4),
                            Text(widget.category, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Provider ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 26, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.providerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            const SizedBox(height: 2),
                            const Text('Penyedia Terpilih', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                            const SizedBox(width: 6),
                            Text('4.9', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Description ───────────────────────────────────────────
                _label('Deskripsi Masalah'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Tambahkan detail masalah Anda...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Photos ────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _label('Foto Masalah'),
                    Text('${_photos.length}/5', style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_photos.length < 5)
                        GestureDetector(
                          onTap: _addPhoto,
                          child: Container(
                            width: 90, height: 90,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: Icon(Icons.add_photo_alternate_rounded, color: theme.colorScheme.primary, size: 28),
                          ),
                        ),
                      ..._photos.map((url) => Container(
                        width: 90, height: 90,
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
                const SizedBox(height: 28),

                // ── Price Offer ───────────────────────────────────────────
                _label('Tawarkan Harga'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      Text('Rp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          onChanged: _onPriceChanged,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Price Summary ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(
                    children: [
                      _priceRow('Penawaran Jasa', _fmt(_offerPrice), isNormal: true),
                      const SizedBox(height: 12),
                      _priceRow('Biaya Platform', _fmt(_transportFee), isNormal: true),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      _priceRow('Total', _fmt(_total), isNormal: false, theme: theme),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom CTA ────────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirm,
                  child: _isProcessing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Konfirmasi & Kirim'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
  );

  static Widget _priceRow(String label, String value, {required bool isNormal, ThemeData? theme}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: isNormal ? 14 : 16, fontWeight: isNormal ? FontWeight.w500 : FontWeight.w800, color: isNormal ? const Color(0xFF64748B) : const Color(0xFF0F172A))),
      Text(value, style: TextStyle(fontSize: isNormal ? 15 : 18, fontWeight: FontWeight.w800, color: isNormal ? const Color(0xFF0F172A) : theme?.colorScheme.primary)),
    ],
  );
}
