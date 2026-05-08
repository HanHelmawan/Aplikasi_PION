import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ActiveTaskScreen extends StatelessWidget {
  const ActiveTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Active Task', style: TextStyle(color: Color(0xFF0052CC), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Map (Placeholder)
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Color(0xFFE3EDFE), BlendMode.multiply),
              )
            ),
            child: Stack(
              children: [
                // Mock Provider Location marker
                Positioned(
                  top: 150,
                  left: 100,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFF0052CC), shape: BoxShape.circle),
                    child: const Icon(Icons.person_pin_circle, color: Colors.white),
                  ),
                ),
                // Mock Destination Location marker
                Positioned(
                  top: 80,
                  right: 120,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
                    child: const Icon(Icons.home, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Info Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFFE3EDFE), borderRadius: BorderRadius.circular(24)),
                      child: const Text('🟢 ON THE WAY', style: TextStyle(color: Color(0xFF0052CC), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // ETA & Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Emergency Plumbing Repair', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B233A))),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('ETA', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text('10 Mins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0052CC))),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Provider Profile
                  Row(
                    children: [
                      const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Budi Santoso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Row(
                              children: const [
                                Icon(Icons.star, color: Colors.orange, size: 14),
                                SizedBox(width: 4),
                                Text('4.9', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                SizedBox(width: 8),
                                Icon(Icons.verified, color: Color(0xFF0052CC), size: 14),
                              ],
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF0052CC)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_outlined, color: Color(0xFF0052CC)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF0052CC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark as Completed (Release Escrow)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
                      child: const Text('Report an Issue'),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
