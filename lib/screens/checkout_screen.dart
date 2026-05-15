import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'active_task_screen.dart';

/// Checkout screen – shown after selecting a provider or posting a task.
///
/// Now serves as an interactive form where users can describe their issue,
/// attach photos, and offer a custom price.
class CheckoutScreen extends StatefulWidget {
  final String taskTitle;
  final String providerName;
  final String category;
  
  // Optional initial data passed from CreateTaskScreen
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

  String _formatRupiah(int amount) {
    if (amount == 0) return 'Rp 0';
    final s = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[s.length - 1 - i]);
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  void _onPriceChanged(String value) {
    // Remove non-numeric characters
    final numericString = value.replaceAll(RegExp(r'[^0-9]'), '');
    int newPrice = 0;
    if (numericString.isNotEmpty) {
      newPrice = int.parse(numericString);
    }

    setState(() {
      _offerPrice = newPrice;
    });

    // Format and maintain cursor position
    if (numericString.isNotEmpty) {
      final formatted = _formatRupiah(newPrice).replaceAll('Rp ', '');
      _priceController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _bookService() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tolong jelaskan masalah Anda.')),
      );
      return;
    }

    if (_offerPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan estimasi harga penawaran Anda.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isProcessing = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ActiveTaskScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F2FE),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0525BB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail & Penawaran',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
            color: Color(0xFF0525BB),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Task Summary Card ────────────────────────────────
                  _buildCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.taskTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF1A1B23),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Oleh: ${widget.providerName}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF757686),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFE0FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                              color: Color(0xFF0525BB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Deskripsi Kerusakan ──────────────────────────────
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi Kerusakan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1B23),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1B23),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Mis., Pipa wastafel bocor dan lantai menggenang...',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Inter',
                              color: Color(0xFFA0A0B0),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF0EEFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Foto Masalah (Opsional)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1B23),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_photos.isEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _photos.add('https://picsum.photos/200')),
                            child: Container(
                              width: double.infinity,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFC5C5D7),
                                  width: 1.5,
                                ),
                                color: const Color(0xFFF4F2FE),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, color: Color(0xFF444655), size: 24),
                                  SizedBox(height: 8),
                                  Text(
                                    'Unggah Foto',
                                    style: TextStyle(fontSize: 12, fontFamily: 'Inter', color: Color(0xFF444655)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final url in _photos)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(url, width: 70, height: 70, fit: BoxFit.cover),
                                ),
                              GestureDetector(
                                onTap: () => setState(() => _photos.add('https://picsum.photos/200')),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9E7F3),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFC5C5D7)),
                                  ),
                                  child: const Icon(Icons.add, color: Color(0xFF444655)),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Penawaran Harga ──────────────────────────────────
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Harga Estimasi Anda',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1B23),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Masukkan harga penawaran awal untuk jasa ini.',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: Color(0xFF757686),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: _onPriceChanged,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Color(0xFF0525BB),
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 14, right: 8, top: 14),
                              child: Text(
                                'Rp',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF1A1B23),
                                ),
                              ),
                            ),
                            hintText: '0',
                            filled: true,
                            fillColor: const Color(0xFFF0EEFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Payment Breakdown Card ───────────────────────────
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rincian Biaya',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1B23),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeeRow('Harga Penawaran Anda', _formatRupiah(_offerPrice)),
                        const SizedBox(height: 10),
                        _buildFeeRow('Biaya Transport / Platform', _formatRupiah(_transportFee)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(color: Color(0xFFE3E1ED), height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Tagihan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                color: Color(0xFF1A1B23),
                              ),
                            ),
                            Text(
                              _formatRupiah(_total),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                color: Color(0xFF0525BB),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // space above bottom bar
                ],
              ),
            ),
          ),

          // ── Bottom CTA ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F2FE),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: ),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _bookService,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isProcessing ? 'Memproses...' : 'Kirim Penawaran',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0525BB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF757686),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0x330525BB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFeeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontFamily: 'Inter', color: Color(0xFF757686))),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: Color(0xFF1A1B23))),
      ],
    );
  }
}
