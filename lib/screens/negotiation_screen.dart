import 'package:flutter/material.dart';
import '../models/task_request.dart';
import 'job_tracking_screen.dart';

class NegotiationScreen extends StatefulWidget {
  final TaskRequest request;
  const NegotiationScreen({super.key, required this.request});

  @override
  State<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends State<NegotiationScreen> {
  final _offerController = TextEditingController();
  bool _accepted = false;

  final _workerName   = 'Budi Santoso';
  final _workerAvatar = 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop';
  final _workerPhone  = '+62 812-3456-7890';

  String get _fmt => 'Rp ${widget.request.estimatedPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  String _fmtNum(double v) => 'Rp ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  void _acceptUserPrice() {
    widget.request.status           = RequestStatus.dikerjakan;
    widget.request.finalPrice       = widget.request.estimatedPrice;
    widget.request.assignedWorkerName   = _workerName;
    widget.request.assignedWorkerAvatar = _workerAvatar;
    widget.request.assignedWorkerPhone  = _workerPhone;
    setState(() => _accepted = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => JobTrackingScreen(request: widget.request),
      ));
    });
  }

  void _submitOffer() {
    final raw = double.tryParse(_offerController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    if (raw <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Masukkan harga penawaran Anda.', style: TextStyle(fontFamily: 'Inter')),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    widget.request.workerOffer = raw;
    widget.request.status = RequestStatus.ditawar;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Penawaran ${_fmtNum(raw)} dikirim ke pengguna.', style: const TextStyle(fontFamily: 'Inter')),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF0525BB),
    ));

    // Simulate user accepting after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      widget.request.status           = RequestStatus.dikerjakan;
      widget.request.finalPrice       = raw;
      widget.request.assignedWorkerName   = _workerName;
      widget.request.assignedWorkerAvatar = _workerAvatar;
      widget.request.assignedWorkerPhone  = _workerPhone;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => JobTrackingScreen(request: widget.request),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail & Negosiasi',
            style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Inter', fontSize: 18, color: Color(0xFF0F172A))),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // ── Job Info Card ───────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(12)),
                        child: Text(req.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0525BB), fontFamily: 'Inter')),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12)),
                        child: const Text('Menunggu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFD97706), fontFamily: 'Inter')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(req.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                  const SizedBox(height: 10),
                  _metaRow(Icons.access_time_rounded, req.scheduledAt),
                  const SizedBox(height: 6),
                  _metaRow(Icons.location_on_rounded, req.location),
                  if (req.photoUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: req.photoUrls.length,
                        itemBuilder: (_, i) => Container(
                          width: 90, height: 90,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(image: NetworkImage(req.photoUrls[i]), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Price Summary ──────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Harga Estimasi Pengguna', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontFamily: 'Inter')),
                  const SizedBox(height: 4),
                  Text(req.estimatedPrice > 0 ? _fmt : 'Belum ditentukan',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0525BB), fontFamily: 'Inter')),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _acceptUserPrice,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: const Text('Terima Harga Ini', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Counter Offer ──────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Atau Ajukan Penawaran Harga', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                  const SizedBox(height: 4),
                  const Text('Masukkan harga yang Anda tawarkan. Pengguna akan dikonfirmasi.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'Inter')),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(10)),
                          child: const Text('Rp', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0525BB), fontFamily: 'Inter')),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _offerController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                            decoration: const InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _submitOffer,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Kirim Penawaran', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0525BB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
    ),
    child: child,
  );

  Widget _metaRow(IconData icon, String text) => Row(children: [
    Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
    const SizedBox(width: 6),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'Inter'), overflow: TextOverflow.ellipsis)),
  ]);
}
