import 'package:flutter/material.dart';

class SOSScreen extends StatelessWidget {
  const SOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
        ),
        title: const Row(
          children: [
            Text('Pion', style: TextStyle(color: Color(0xFF0052CC), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: const [
                  Text('Emergency\nAssistance', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFC62828), height: 1.1)),
                  SizedBox(height: 12),
                  Text('Press and hold to send an immediate alert to your emergency contacts and local authorities.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            
            // SOS Button
            Container(
              height: 250,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(width: 220, height: 220, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.red.withValues(alpha: 0.1), width: 1))),
                  Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 2))),
                  Container(
                    width: 130, height: 130,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      boxShadow: [BoxShadow(color: Colors.redAccent, blurRadius: 20, spreadRadius: 5)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.emergency, color: Colors.white, size: 40),
                        SizedBox(height: 4),
                        Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Location Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B233A),
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80'), // Placeholder map image
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Color(0xFF0052CC), BlendMode.screen),
                      )
                    ),
                    child: const Center(child: Icon(Icons.location_on, color: Colors.red, size: 40)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Icon(Icons.my_location, size: 16, color: Color(0xFF0052CC)),
                      SizedBox(width: 8),
                      Text('CURRENT LOCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('124 West 42nd Street', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('New York, NY 10036', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE3EDFE), foregroundColor: const Color(0xFF0052CC), elevation: 0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Update'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE3EDFE), foregroundColor: const Color(0xFF0052CC), elevation: 0),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grid buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildServiceBtn('Police', Icons.local_police, const Color(0xFF0052CC)),
                  _buildServiceBtn('Medical', Icons.medical_services, const Color(0xFFE53935)),
                  _buildServiceBtn('Fire', Icons.fire_truck, const Color(0xFF455A64)),
                  _buildServiceBtn('Emergency\nContacts', Icons.contact_phone, const Color(0xFF64B5F6)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceBtn(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE3EDFE))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
