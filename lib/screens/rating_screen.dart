import 'package:flutter/material.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedRating = 4;
  final List<String> _tags = ['Sopan', 'Cepat', 'Sesuai Deskripsi', 'Ramah', 'Ahli'];
  final List<String> _selectedTags = ['Sesuai Deskripsi'];

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

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
                color: Color(0x0D000000), // shadow-sm
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
                        icon: const Icon(Icons.close, color: Color(0xFF0525BB)), // primary
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          hoverColor: const Color(0xFFF4F2FE), // surface-container-low
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Beri Rating',
                        style: TextStyle(
                          fontSize: 24, // h2
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Hanken Grotesk',
                          color: Color(0xFF0525BB), // primary
                          height: 1.2,
                          letterSpacing: -0.01 * 24,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Color(0xFF444655)), // on-surface-variant
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20), // py-lg, px-margin
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
              child: IntrinsicHeight(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Provider Summary Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 32), // mb-xl
                    padding: const EdgeInsets.all(16), // p-md
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F2FE), // surface-container-low
                      borderRadius: BorderRadius.circular(12), // rounded-xl
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000), // shadow
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64, // w-16
                          height: 64, // h-16
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFDFE0FF), // primary-fixed
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBSXTKHOiUFaVM1b2eylIZpu_BPQ1PwMlAc3JKlxGNnC2T4FcxBIjDDjM_t-WZPkyC6QUHR1xCgLA2W4PPu8ulqwJUV7nKVbDxRaNRJouDnGRbrKS7NkUMB4PMKiG4adCjYu8ljSB86gsegRPZwKaCack0KMgZoy15y_M9l9iQa_ux4zizKgWk5LH4V8_Cz2O-GYryCBmOlDBMmhcTBZJ2xfauO0llK7fKEuc9KXVbgKjkbUSl1Ym2sUx6tevCX9YBVXzM7CYH-LQf7',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16), // gap-4
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Budi Santoso',
                                style: TextStyle(
                                  fontSize: 20, // h3
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Hanken Grotesk',
                                  color: Color(0xFF1A1B23), // on-surface
                                ),
                              ),
                              Text(
                                'Layanan Perbaikan Keran',
                                style: TextStyle(
                                  fontSize: 14, // body-sm
                                  fontFamily: 'Inter',
                                  color: Color(0xFF444655), // on-surface-variant
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // px-3 py-1
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E44D1), // primary-container
                            borderRadius: BorderRadius.circular(9999), // rounded-full
                          ),
                          child: const Text(
                            'SELESAI',
                            style: TextStyle(
                              fontSize: 12, // label-caps
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                              letterSpacing: 0.05 * 12,
                              color: Color(0xFFC2C8FF), // on-primary-container
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rating Section
                  Column(
                    children: [
                      const Text(
                        'Bagaimana layanannya?',
                        style: TextStyle(
                          fontSize: 24, // h2
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Hanken Grotesk',
                          color: Color(0xFF1A1B23), // on-background
                          letterSpacing: -0.01 * 24,
                        ),
                      ),
                      const SizedBox(height: 12), // mb-sm
                      const Text(
                        'Ketuk bintang untuk memberi penilaian',
                        style: TextStyle(
                          fontSize: 16, // body-md
                          fontFamily: 'Inter',
                          color: Color(0xFF444655), // on-surface-variant
                        ),
                      ),
                      const SizedBox(height: 24), // mb-lg
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          bool isActive = index < _selectedRating;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedRating == index + 1) {
                                  _selectedRating = index;
                                } else {
                                  _selectedRating = index + 1;
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4), // gap-2
                              child: Icon(
                                isActive ? Icons.star : Icons.star_border,
                                size: 48,
                                color: isActive
                                    ? const Color(0xFFFE9400) // secondary-container
                                    : const Color(0xFF444655).withValues(alpha: 0.2), // on-surface-variant opacity-20
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32), // mb-xl
                    ],
                  ),

                  // Tags Section
                  Column(
                    children: [
                      const Text(
                        'APA YANG KAMU SUKAI?',
                        style: TextStyle(
                          fontSize: 12, // label-caps
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          letterSpacing: 0.05 * 12,
                          color: Color(0xFF444655), // on-surface-variant
                        ),
                      ),
                      const SizedBox(height: 16), // mb-md
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12, // gap-3
                        runSpacing: 12,
                        children: _tags.map((tag) {
                          bool isSelected = _selectedTags.contains(tag);
                          return GestureDetector(
                            onTap: () => _toggleTag(tag),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), // px-lg py-2
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF2E44D1) : Colors.transparent, // primary-container
                                borderRadius: BorderRadius.circular(9999), // rounded-full
                                border: isSelected
                                    ? null
                                    : Border.all(color: const Color(0xFF0525BB)), // border-primary
                                boxShadow: isSelected
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x0D000000), // shadow-sm
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                       )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 14, // label-large
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF0525BB), // on-primary-container or primary
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32), // mb-xl
                    ],
                  ),

                  // Written Review Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ULASAN TERTULIS (OPSIONAL)',
                        style: TextStyle(
                          fontSize: 12, // label-caps
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          letterSpacing: 0.05 * 12,
                          color: Color(0xFF444655), // on-surface-variant
                        ),
                      ),
                      const SizedBox(height: 4), // mb-xs
                      TextField(
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Ceritakan pengalamanmu lebih detail...',
                          hintStyle: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF757686), // outline
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFBF8FF), // surface
                          contentPadding: const EdgeInsets.all(16), // p-md
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), // rounded-xl
                            borderSide: const BorderSide(color: Color(0xFFC5C5D7)), // outline-variant
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFC5C5D7)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF0525BB)), // primary
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16, // body-md
                          fontFamily: 'Inter',
                          color: Color(0xFF1A1B23), // on-surface
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  const SizedBox(height: 24), // pt-lg
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0525BB), // primary
                        foregroundColor: const Color(0xFFFFFFFF), // on-primary
                        padding: const EdgeInsets.symmetric(vertical: 16), // py-md
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // rounded-xl
                        ),
                        elevation: 10, // shadow-lg
                        shadowColor: const Color(0x1A000000),
                      ),
                      child: const Text(
                        'Kirim Ulasan',
                        style: TextStyle(
                          fontSize: 16, // button
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Hanken Grotesk',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        },
      ),
    );
  }
}
