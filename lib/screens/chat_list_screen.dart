import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF), // background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF8FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Pesan',
          style: TextStyle(
            color: Color(0xFF0525BB),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Hanken Grotesk',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0525BB)),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildChatItem(
            context: context,
            name: 'Budi Setiawan',
            lastMessage: "Saya berada di pintu masuk Gedung B sekarang. Sedang naik!",
            time: '10:48 AM',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB4dPKrViWbYCTmG7dpgBiQ5bzNEy7TgrWZ-s3OfT-nnuemsN3ycl-RGMxvzfwAeDRFrB0d7wNSzpEynC2jVopx2H_JSItsK7LNFjIXMkKRSX-ahIQhgT_o2pHwwE9WX7cZWGbrbrGIdYjcsg6sD45EBiboCU4TENcMr4brGJ9XC9v0R6ErGNTJDKC_uva6WNRrOlEmi9mefJMZM0vYEFeYLq6l8P3srg09HVJOjN7bxFGWte8JSEFr4tcn1li42DhDbOk34P1pVD6v',
            unreadCount: 1,
            isOnline: true,
          ),
          const Divider(color: Color(0xFFE3E1ED), height: 1, indent: 80),
          _buildChatItem(
            context: context,
            name: 'Siti Aminah',
            lastMessage: 'Terima kasih! Tugas sudah saya selesaikan.',
            time: 'Kemarin',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBsGG3QZiqbGXWHdn2njMLBETpASlOqE4tN-9Aq3db5ObZlGcIvwejiqm8tOrad6Vs8FvurttLHQmMA_VJ8abkaE2aPcHqJjUGzDXmKHBWl86V17r_Vyv_oku2Lj8Ucd7eeJ9QtoJSseRNzaW50lR_K_oVjHp6eGmnU7sYPRoYy6-Nbttk1uLeaEfm0Pyv6BaM3FdPcD2JdZQwWpe917BPPPdzu6JPcCpo6X4xmpPXt17a_HlpKoXps9zBjJzaOfSmrMxvY_SW_u3rz',
            unreadCount: 0,
            isOnline: false,
          ),
          const Divider(color: Color(0xFFE3E1ED), height: 1, indent: 80),
          _buildChatItem(
            context: context,
            name: 'Andi Pratama',
            lastMessage: 'Baik, saya akan datang besok jam 10 pagi.',
            time: 'Senin',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtHKokFpO_dEk7PxGBLgrfBeQBPIaro37Ovz2a1b9HnEJNrP7anJZR4jRvv65Z3XnxvgDsX3J0d9GfvZX9VcNIHvdqWQ3zXFBOqQuYZn0oc_jMLBq-FKeQFsASAiJBSs7XeChnORw60RolofIFDjqG6uZn1m_QC9ptV464hL2uIVA4CNjNf99uY45Re4DLNEZl3egBvKwQ0HrO9oXBBt7VRBrBx2Clw4Lh_JITs4ry2PSmLPDU1R8Sm7Dlga9qT-Xo4QjV25v1-eM5',
            unreadCount: 0,
            isOnline: false,
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem({
    required BuildContext context,
    required String name,
    required String lastMessage,
    required String time,
    required String imageUrl,
    required int unreadCount,
    required bool isOnline,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              providerName: name,
              providerAvatar: imageUrl,
              isOnline: isOnline,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC5C5D7), width: 1),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8C5000), // secondary (orange-ish)
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFBF8FF), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                          color: const Color(0xFF1A1B23),
                          fontFamily: 'Hanken Grotesk',
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: unreadCount > 0 ? const Color(0xFF0525BB) : const Color(0xFF757686),
                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: unreadCount > 0 ? const Color(0xFF1A1B23) : const Color(0xFF444655),
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0525BB),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
