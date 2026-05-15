import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'select_provider_screen.dart';
import 'checkout_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _issueController = TextEditingController();

  // Simulated AI-generated tags
  bool _isProcessing = false;
  final List<_TagItem> _tags = [];

  // When / Where state
  String _whenLabel = 'Sesegera mungkin';
  String _whereLabel = 'Lokasi Saat Ini';

  // Uploaded photos (dummy)
  final List<String> _photoUrls = [];

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  void _onIssueChanged(String value) {
    if (_isProcessing) return;
    if (value.trim().length > 20) {
      setState(() {
        _isProcessing = true;
      });
      // Simulate AI processing delay
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _tags
            ..clear()
            ..add(_TagItem(label: '#Perbaikan', color: const Color(0xFF0525BB)))
            ..add(_TagItem(label: '#Darurat', color: const Color(0xFF8C5000)));
        });
      });
    }
  }

  Future<void> _pickWhen() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal',
    );
    if (date == null) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _whenLabel = DateFormat('dd MMM yyyy, HH:mm').format(dt);
    });
  }

  void _pickWhere() {
    // Placeholder: would open a map picker
    setState(() {
      _whereLabel = 'Lokasi Saat Ini';
    });
  }

  void _submit() {
    if (_issueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tuliskan masalah Anda terlebih dahulu')),
      );
      return;
    }
    // Go to checkout so user deposits escrow before task is posted
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          taskTitle: _issueController.text.trim(),
          providerName: 'Belum dipilih',
          category: _tags.isNotEmpty ? _tags.first.label : 'Umum',
          serviceFeeCents: 150000,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FE), // soft lavender background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F2FE),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1B23)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Permintaan Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
            color: Color(0xFF1A1B23),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF444655)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Card 1: What's the issue? ──────────────────────────
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Apa masalahnya?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                color: Color(0xFF1A1B23),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDFE0FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome,
                                      size: 12, color: Color(0xFF0525BB)),
                                  SizedBox(width: 4),
                                  Text(
                                    'AI ASSISTED',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                      color: Color(0xFF0525BB),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _issueController,
                          maxLines: 5,
                          onChanged: _onIssueChanged,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1B23),
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Mis., Pipa di bawah wastafel dapur bocor dan menggenangi lantai...',
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
                        const SizedBox(height: 12),
                        // AI Processing / Tags row
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (_isProcessing)
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome,
                                      size: 14, color: Color(0xFFA0A0B0)),
                                  SizedBox(width: 4),
                                  Text('Memproses...',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                          color: Color(0xFFA0A0B0))),
                                ],
                              ),
                            for (final tag in _tags) _buildTagChip(tag),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Card 2: Photo of the problem ───────────────────────
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Foto masalah',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1B23),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Visual membantu penyedia membawa alat yang tepat.',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            color: Color(0xFF757686),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // If photos exist, show grid; otherwise show upload area
                        if (_photoUrls.isEmpty)
                          GestureDetector(
                            onTap: () => setState(() =>
                                _photoUrls.add('https://picsum.photos/200')),
                            child: Container(
                              width: double.infinity,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFC5C5D7),
                                  width: 1.5,
                                  strokeAlign: BorderSide.strokeAlignInside,
                                ),
                                color: const Color(0xFFF4F2FE),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE9E7F3),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: const Icon(
                                      Icons.add_a_photo_outlined,
                                      color: Color(0xFF444655),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Tap untuk unggah foto',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      color: Color(0xFF444655),
                                    ),
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
                              for (final url in _photoUrls)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(url,
                                      width: 80, height: 80, fit: BoxFit.cover),
                                ),
                              GestureDetector(
                                onTap: () => setState(() =>
                                    _photoUrls.add('https://picsum.photos/200')),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9E7F3),
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: const Color(0xFFC5C5D7)),
                                  ),
                                  child: const Icon(Icons.add,
                                      color: Color(0xFF444655)),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Card 3: WHEN ───────────────────────────────────────
                  _buildTapCard(
                    onTap: _pickWhen,
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 22, color: Color(0xFF0525BB)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'KAPAN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF757686),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _whenLabel,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF1A1B23),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFF757686)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Card 4: WHERE ──────────────────────────────────────
                  _buildTapCard(
                    onTap: _pickWhere,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 22, color: Color(0xFF0525BB)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DI MANA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF757686),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _whereLabel,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF1A1B23),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFF757686)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom: Post Request Button ────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F2FE),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Kirim Permintaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0525BB),
                  foregroundColor: Colors.white,
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

  // ── Helpers ────────────────────────────────────────────────────────────────

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

  Widget _buildTapCard({required Widget child, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      ),
    );
  }

  Widget _buildTagChip(_TagItem tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tag.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sell_outlined, size: 13, color: tag.color),
          const SizedBox(width: 4),
          Text(
            tag.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: tag.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagItem {
  final String label;
  final Color color;
  _TagItem({required this.label, required this.color});
}
