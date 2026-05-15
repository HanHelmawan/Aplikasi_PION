import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/config_reader.dart';
import 'screens/home_seeker_screen.dart';
import 'screens/select_provider_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
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
      home: const OnboardingScreen(),
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

  List<Widget> get _pages => [
    HomeSeekerScreen(isWorkerMode: widget.isWorkerMode),
    const SelectProviderScreen(),
    const ChatListScreen(),
    ProfileScreen(isWorkerMode: widget.isWorkerMode),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: const Color(0x0A000000), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home)),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.assignment_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.assignment)),
              label: 'Tugas',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.chat_bubble_outline)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.chat_bubble)),
              label: 'Pesan',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person)),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
