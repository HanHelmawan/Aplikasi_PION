import 'package:flutter/material.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _budgetType = 'Fixed Price';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
        title: const Text('Pion', style: TextStyle(color: Color(0xFF0052CC), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
          )
        ],
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create New Task', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0052CC))),
              const SizedBox(height: 8),
              const Text('Define your requirements and find the perfect provider.', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 24),
              
              // 1. Task Details
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0052CC)),
                    child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  const Text('Task Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel('Task Title'),
              _buildTextField('e.g., UI Design for Mobile App'),
              _buildLabel('Description'),
              _buildTextField('Describe the task requirements in detail...', maxLines: 4),
              _buildLabel('Category'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select a category'),
                    items: const [],
                    onChanged: (val) {},
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Deadline'),
              _buildTextField('mm/dd/yyyy', suffixIcon: Icons.calendar_today),
              const SizedBox(height: 32),

              // 2. Budget & Funding
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE3EDFE)),
                    child: const Text('2', style: TextStyle(color: Color(0xFF0052CC), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  const Text('Budget & Funding', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel('Budget Type'),
              Row(
                children: [
                  Expanded(child: _buildBudgetOption('Fixed Price', Icons.money)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildBudgetOption('Hourly Rate', Icons.access_time)),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel('Total Budget (USD)'),
              _buildTextField('500'),
              const SizedBox(height: 32),

              // Task Summary
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Task Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 32),
                    _buildSummaryRow('Subtotal', '\$500.00'),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Escrow Fee ⓘ', '\$15.00'),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Total Escrow Deposit', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('\$515.00', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0052CC))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FE), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.security, color: Color(0xFF0052CC), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('Funds will be securely held in escrow and only released when the task is marked as complete and approved by you.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF0052CC),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Post Task & Deposit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1, IconData? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.black54) : null,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildBudgetOption(String label, IconData icon) {
    bool isSelected = _budgetType == label;
    return GestureDetector(
      onTap: () => setState(() => _budgetType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3EDFE) : Colors.transparent,
          border: Border.all(color: isSelected ? const Color(0xFF0052CC) : Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF0052CC) : Colors.black54),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF0052CC) : Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
