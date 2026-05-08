import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/config_reader.dart';
import 'screens/home_seeker_screen.dart';
import 'screens/create_task_screen.dart';
import 'screens/provider_dashboard_screen.dart';
import 'screens/sos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      // Force light theme mode to match the UI mockup perfectly
      themeMode: ThemeMode.light,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeSeekerScreen(), // Explore
    const ProviderDashboardScreen(), // Tasks / Overview
    const CreateTaskScreen(), // Activity (temporary placing create task here)
    const SOSScreen(), // Profile (temporary placing SOS here)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: PionTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Activity', // using create task placeholder
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile', // using SOS placeholder
          ),
        ],
      ),
    );
  }
}
