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
    this.taskTitle = 'Perbaikan / Layanan',
    this.providerName = 'Belum dipilih',
    this.category = 'Umum',
    this.initialDescription,
    this.initialPhotos,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const int _platformFee = 15000;
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

  int get _total => _offerPrice + _platformFee;

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan penawaran harga Anda.', style: TextStyle(fontFamily: 'Inter')), backgroundColor: Color(0xFFEF4444)));
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)), onPressed: () => Navigator.pop(context)),
        title: const Text('Konfirmasi Pesanan', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFC6D8FF)],
            stops: [0.3, 1.0],
          ),
        ),
        child: Stack(
          children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Escrow Trust Banner ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.gpp_good_rounded, color: Color(0xFF16A34A), size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pembayaran Anda aman. Dana ditahan di sistem Escrow Pion hingga pekerjaan selesai.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF166534), fontFamily: 'Inter', height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Provider ──────────────────────────────────────────────
                const Text('Penyedia Jasa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))]),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 26, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.providerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                            const SizedBox(height: 2),
                            Text(widget.category, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'Inter')),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: const [
                            Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                            SizedBox(width: 4),
                            Text('4.9', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0525BB), fontFamily: 'Inter')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Service Details ───────────────────────────────────────────
                const Text('Detail Pekerjaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.taskTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF475569), fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Tambahkan catatan khusus untuk pekerja...',
                          hintStyle: const TextStyle(fontFamily: 'Inter', color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Price Offer ───────────────────────────────────────────
                const Text('Penawaran Harga Anda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                const SizedBox(height: 4),
                const Text('Anda dapat bernegosiasi harga dengan penyedia jasa.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'Inter')),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))]),
                  child: Row(
                    children: [
                      const Text('Rp', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0525BB), fontFamily: 'Inter')),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          onChanged: _onPriceChanged,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter'),
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Price Summary ─────────────────────────────────────────
                const Text('Rincian Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))]),
                  child: Column(
                    children: [
                      _priceRow('Penawaran Anda', _fmt(_offerPrice), isNormal: true),
                      const SizedBox(height: 12),
                      _priceRow('Biaya Perlindungan & Platform', _fmt(_platformFee), isNormal: true),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Color(0xFFF1F5F9)),
                      ),
                      _priceRow('Total Estimasi', _fmt(_total), isNormal: false, theme: theme),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Action ─────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, -8))],
              ),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0525BB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Kirim Permintaan Pekerjaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Inter')),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  static Widget _priceRow(String label, String value, {required bool isNormal, ThemeData? theme}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: 14, fontWeight: isNormal ? FontWeight.w500 : FontWeight.w800, color: isNormal ? const Color(0xFF64748B) : const Color(0xFF0F172A), fontFamily: 'Inter')),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isNormal ? const Color(0xFF0F172A) : const Color(0xFF0525BB), fontFamily: 'Inter')),
    ],
  );
}
