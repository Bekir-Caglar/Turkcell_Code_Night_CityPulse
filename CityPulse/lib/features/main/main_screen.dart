import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:citypulse/core/theme/app_theme.dart';
import 'package:citypulse/features/home/home_screen.dart';
import 'package:citypulse/features/add_data/add_data_screen.dart';
import 'package:citypulse/features/notifications/notifications_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final bool isIOS = Platform.isIOS;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AddDataScreen(),
    const NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  isIOS ? CupertinoIcons.house : Icons.home_outlined,
                  size: 26,
                ),
                activeIcon: Icon(
                  isIOS ? CupertinoIcons.house_fill : Icons.home_rounded,
                  size: 26,
                ),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.accentBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isIOS ? CupertinoIcons.add : Icons.add_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                label: 'Veri Ekle',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  isIOS ? CupertinoIcons.bell : Icons.notifications_outlined,
                  size: 26,
                ),
                activeIcon: Icon(
                  isIOS
                      ? CupertinoIcons.bell_fill
                      : Icons.notifications_rounded,
                  size: 26,
                ),
                label: 'Uyarılar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
