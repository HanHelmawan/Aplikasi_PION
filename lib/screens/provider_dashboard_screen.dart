import 'package:flutter/material.dart';
import 'active_task_screen.dart';
class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B233A))),
            const SizedBox(height: 24),
            
            // Earnings Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE3EDFE))),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('EARNINGS (THIS WEEK)', style: TextStyle(color: Color(0xFF0052CC), fontSize: 12, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFE3EDFE), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.account_balance_wallet, color: Color(0xFF0052CC), size: 20),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('\$485.50', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1B233A))),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.trending_up, color: Color(0xFF0052CC), size: 16),
                        SizedBox(width: 4),
                        Text('+12% from last week', style: TextStyle(color: Color(0xFF0052CC), fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rating Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE3EDFE))),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CURRENT RATING', style: TextStyle(color: Color(0xFF0052CC), fontSize: 12, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.star_outline, color: Colors.orange, size: 20),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('4.9', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1B233A))),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(5, (index) => Icon(
                                index < 4 ? Icons.star : Icons.star_half, 
                                color: Colors.orange, size: 16,
                              )),
                            ),
                            const SizedBox(height: 4),
                            const Text('Based on 124 reviews', style: TextStyle(color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Task Radar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.radar, color: Color(0xFF0052CC)),
                    SizedBox(width: 8),
                    Text('Task Radar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B233A))),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Text('View Map'),
                  label: const Icon(Icons.map_outlined, size: 16),
                )
              ],
            ),
            const Text('Active requests near you', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),

            SizedBox(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildTaskCard(context),
                  _buildTaskCard(context, title: 'IKEA Furniture Assembly', urgent: false, price: '85'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, {String title = 'Emergency Plumbing Repair', bool urgent = true, String price = '120'}) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3EDFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              urgent ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: const [
                    Icon(Icons.circle, color: Colors.red, size: 8),
                    SizedBox(width: 4),
                    Text('Urgent', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ) : const SizedBox(),
              Text('\$$price', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Pipe burst in main bathroom. Need immediate assistance to stop floodin...', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF0052CC)),
              SizedBox(width: 4),
              Text('1.2 mi', style: TextStyle(color: Color(0xFF0052CC), fontSize: 12, fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Color(0xFF0052CC)),
              SizedBox(width: 4),
              Text('ASAP', style: TextStyle(color: Color(0xFF0052CC), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveTaskScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0052CC)),
              child: const Text('Take Task'),
            ),
          )
        ],
      ),
    );
  }
}
