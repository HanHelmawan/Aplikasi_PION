import 'package:flutter/material.dart';
import 'rating_screen.dart';
import 'sos_screen.dart';

class ChatScreen extends StatelessWidget {
  final String providerName;
  final String providerAvatar;
  final bool isOnline;

  const ChatScreen({
    super.key,
    this.providerName = 'Budi Setiawan',
    this.providerAvatar = 'https://lh3.googleusercontent.com/aida-public/AB6AXuB4dPKrViWbYCTmG7dpgBiQ5bzNEy7TgrWZ-s3OfT-nnuemsN3ycl-RGMxvzfwAeDRFrB0d7wNSzpEynC2jVopx2H_JSItsK7LNFjIXMkKRSX-ahIQhgT_o2pHwwE9WX7cZWGbrbrGIdYjcsg6sD45EBiboCU4TENcMr4brGJ9XC9v0R6ErGNTJDKC_uva6WNRrOlEmi9mefJMZM0vYEFeYLq6l8P3srg09HVJOjN7bxFGWte8JSEFr4tcn1li42DhDbOk34P1pVD6v',
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF), // background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFBF8FF), // surface
            boxShadow: [
              BoxShadow(
                color: Color(0x0D000000), // shadow-sm roughly
                blurRadius: 4,
                offset: Offset(0, 1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20), // px-margin
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF0525BB)), // primary
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          hoverColor: const Color(0xFFF4F2FE), // surface-container-low
                        ),
                      ),
                      const SizedBox(width: 16), // gap-md
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            providerName,
                            style: const TextStyle(
                              fontSize: 24, // h2
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Hanken Grotesk',
                              color: Color(0xFF0525BB), // primary
                              height: 1.2,
                              letterSpacing: -0.01 * 24,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8, // w-2
                                height: 8, // h-2
                                decoration: BoxDecoration(
                                  color: isOnline ? const Color(0xFF8C5000) : const Color(0xFF757686), // secondary
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4), // gap-xs
                              Text(
                                isOnline ? 'Online' : 'Offline',
                                style: const TextStyle(
                                  fontSize: 12, // label-caps
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF444655), // on-surface-variant
                                  letterSpacing: 0.05 * 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDAD6), // error-container
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.sos, color: Color(0xFFBA1A1A), size: 20), // error
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SosScreen(),
                              ),
                            );
                          },
                          tooltip: 'Panggilan Darurat',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Color(0xFF444655)), // on-surface-variant
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF444655)),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Proximity Map Snippet
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24), // px-margin, pt-4, mb-lg (24px)
            child: Container(
              height: 128, // h-32
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE3E1ED), // surface-variant
                borderRadius: BorderRadius.circular(12), // rounded-xl
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000), // shadow
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuC_Sa03dBIVYolUkGgui8u6nHoZ7ZLy6lDBUSBriHOIdCW9YvCuMIT1dZD82zfGEAAmeY57AlNEcBoB-nu3gJYB-C_o-6h8VLGdSFQSMbEwjXWsS-LEIJdXuGWc92C-jXHOL27uDJu5t_o0q3gKB1Wp-K1OPqyLzfjq-gZr8BEiIPN4AxaUS1dyhsHSOMw2lAn7WH13naxX72HOFXlO5f8EMBqdQf_29Fp2w5iIxSqMU_uWFAu6KX5lEeoXS2U113pcAHNIBkBciulp',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12, // top-sm
                    left: 12, // left-sm
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // px-md, py-xs
                      decoration: BoxDecoration(
                        color: const Color(0xE6FBF8FF), // surface/90
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: const Color(0xFF0525BB).withValues(alpha: 0.3)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.near_me_outlined, color: Color(0xFF0525BB), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${providerName.split(" ")[0]} berjarak 5 menit',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                              letterSpacing: 0.05 * 12,
                              color: Color(0xFF0525BB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Task Action Panel
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F2FE), // surface-container-low
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC5C5D7)), // outline-variant
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Status: Sedang Dikerjakan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1B23),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Verifikasi hasil sebelum menandai tugas selesai',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: Color(0xFF444655),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RatingScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0525BB), // primary
                      foregroundColor: const Color(0xFFFFFFFF), // on-primary
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Terima\nTugas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Chat History
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Timestamp
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEECF8), // surface-container
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Text(
                      'Hari ini',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        letterSpacing: 0.05 * 12,
                        color: Color(0xFF757686), // outline
                      ),
                    ),
                  ),
                ),
                
                // Provider Message 1
                _buildProviderMessage(
                  avatar: providerAvatar,
                  text: "Halo! Saya baru saja sampai di gerbang utama. Apakah saya harus menunggu di sini atau langsung ke gedung B?",
                  time: '10:42 AM',
                ),
                const SizedBox(height: 24), // space-y-lg
                
                // Seeker Message 1
                _buildSeekerMessage(
                  text: "Hai Budi! Silakan langsung ke lantai 3 gedung B. Saya akan menemui Anda di lift.",
                  time: '10:45 AM',
                ),
                const SizedBox(height: 24),
                
                // Provider Image Message
                _buildProviderImageMessage(
                  avatar: providerAvatar,
                  imageAttachment: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBlwFbNi55ehVF9JUMBNcfApmfDINpz_0uuSo23wbWldVn_A75qv_1nQFnVs-3b9PfbDDPVqSGGS9rrgwnxGBghpdIUAdHm9kn-v8yg2Gxt34J9Hmo24StN8-CN6bGdtybFpJoBih-HKcaKjpBn0OcBeskb75lWUIjFSSL1JzM8aL6kwgeeOlCA039urGXXzB3Hvy_dlEfOua0ESsFC_yLmUtj7yviP6UjpwIc3Y9m4YHFwqMuI5peF6oOigCBs47hTgPZEKM08hhse',
                  text: "Saya berada di pintu masuk Gedung B sekarang. Sedang naik!",
                  time: '10:48 AM',
                ),
                const SizedBox(height: 24),
                // The second seeker message is removed to match the mockup
                const SizedBox(height: 12), // extra padding for input area
              ],
            ),
          ),
          
          // Chat Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xFFFBF8FF), Color(0x00FBF8FF)], // from-background to transparent
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E7F3), // surface-container-high
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: const Color(0xFFC5C5D7)), // outline-variant
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4)) // shadow-lg
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attachment, color: Color(0xFF444655)), // on-surface-variant
                    onPressed: () {},
                  ),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: TextStyle(
                          color: Color(0xFF757686), // outline
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Color(0xFF1A1B23), fontSize: 16, fontFamily: 'Inter'), // on-surface
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0525BB), // primary
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))], // shadow-md
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFFFFFFFF), size: 20),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderMessage({required String avatar, required String text, required String time}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFC5C5D7)), // outline-variant
            image: DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFEEECF8), // surface-container
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: Color(0xFF1A1B23), // on-surface
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    letterSpacing: 0.05 * 12,
                    color: Color(0xFF757686), // outline
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40), // Force max width to be ~85% visually
      ],
    );
  }

  Widget _buildProviderImageMessage({
    required String avatar,
    required String imageAttachment,
    required String text,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFC5C5D7)),
            image: DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4), // p-xs
                decoration: BoxDecoration(
                  color: const Color(0xFFEEECF8), // surface-container
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  border: Border.all(color: const Color(0xFFC5C5D7)), // outline-variant
                  boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageAttachment,
                        width: double.infinity,
                        height: 192, // h-48
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12), // p-sm
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          color: Color(0xFF1A1B23), // on-surface
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    letterSpacing: 0.05 * 12,
                    color: Color(0xFF757686),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildSeekerMessage({required String text, required String time, bool isRead = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0525BB), // primary
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2))], // shadow-md
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: Color(0xFFFFFFFF), // on-primary
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      letterSpacing: 0.05 * 12,
                      color: Color(0xFF757686), // outline
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 16,
                    color: isRead ? const Color(0xFF0525BB) : const Color(0xFF757686),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

}
