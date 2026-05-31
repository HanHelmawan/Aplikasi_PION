import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/config_reader.dart';
import 'screens/home_seeker_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/create_task_screen.dart';
import 'screens/job_board_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/worker_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ AUDIT FIX (I-2): Global error handler untuk uncaught Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Dalam production, kirim ke Firebase Crashlytics:
    // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    FlutterError.presentError(details); // tetap tampilkan di debug mode
  };

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ConfigReader.initialize();
  runApp(const PionApp());
}


class PionApp extends StatelessWidget {
  const PionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pion',
      debugShowCheckedModeBanner: false,
      theme: PionTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final bool isWorkerMode;
  const MainNavigation({super.key, this.isWorkerMode = false});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // ✅ AUDIT FIX: _pages dipindah ke initState() agar tidak dibuat ulang setiap rebuild
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      widget.isWorkerMode
          ? const WorkerHomeScreen()
          : HomeSeekerScreen(isWorkerMode: false),
      widget.isWorkerMode
          ? const JobBoardScreen()
          : const ActivityScreen(),
      const ChatListScreen(),
      ProfileScreen(isWorkerMode: widget.isWorkerMode),
    ];
  }

  // Nav item config: index 0,1 left of FAB; 2,3 right of FAB
  static const _navItems = [
    _NavItem(icon: Icons.home_filled, outlineIcon: Icons.home_outlined, label: 'Beranda'),
    _NavItem(icon: Icons.receipt_long_rounded, outlineIcon: Icons.receipt_long_outlined, label: 'Riwayat'),
    _NavItem(icon: Icons.chat_bubble_rounded, outlineIcon: Icons.chat_bubble_outline_rounded, label: 'Pesan'),
    _NavItem(icon: Icons.person_rounded, outlineIcon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = PionTheme.buildTheme(isWorkerMode: widget.isWorkerMode);
    return Theme(
      data: theme,
      child: Scaffold(
        extendBody: true,
        body: _pages[_currentIndex],
        floatingActionButton: !widget.isWorkerMode
            ? FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const CreateTaskScreen()),
                ),
                backgroundColor: theme.primaryColor,
                elevation: 8,
                shape: const CircleBorder(),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                // ✅ AUDIT FIX (L-1): withOpacity → withValues(alpha:)
                color: theme.primaryColor.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomAppBar(
              color: Colors.white,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    // Left side: Beranda, Riwayat
                    Expanded(child: _buildNavItem(0, theme)),
                    Expanded(child: _buildNavItem(1, theme)),
                    // Center gap for FAB
                    if (!widget.isWorkerMode) const SizedBox(width: 48),
                    // Right side: Pesan, Profil
                    Expanded(child: _buildNavItem(2, theme)),
                    Expanded(child: _buildNavItem(3, theme)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, ThemeData theme) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Column(
            key: ValueKey(isSelected),
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.icon : item.outlineIcon,
                color: isSelected ? theme.primaryColor : const Color(0xFF94A3B8),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 9.5,
                  
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? theme.primaryColor : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData outlineIcon;
  final String label;
  const _NavItem({required this.icon, required this.outlineIcon, required this.label});
}
