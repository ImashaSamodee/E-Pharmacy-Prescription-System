import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/prescription_scan_screen.dart';
import 'screens/extracted_medicines_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'state/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EPharmacyApp());
}

class EPharmacyApp extends StatelessWidget {
  const EPharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCare LK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
      ),
      home: const RootNavigation(),
    );
  }
}

class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _currentIndex = 0;
  bool _isAuthenticated = false; // Opens Login Screen so user can choose their Role & Account
  bool _pharmacistViewingPatientStore = false;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const ExtractedMedicinesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        if (!_isAuthenticated || appState.currentUser == null) {
          return LoginScreen(
            onLoginSuccess: () {
              setState(() {
                _isAuthenticated = true;
                _currentIndex = 0;
                _pharmacistViewingPatientStore = false;
              });
            },
          );
        }

        final user = appState.currentUser!;
        final isPharmacist = user.role.toUpperCase() == 'PHARMACIST' ||
            user.role.toUpperCase() == 'ADMIN';

        // 1. Direct Pharmacist Dashboard if user has PHARMACIST or ADMIN role
        if (isPharmacist && !_pharmacistViewingPatientStore) {
          return AdminPanelScreen(
            onLogout: () {
              appState.logout();
              setState(() {
                _isAuthenticated = false;
                _pharmacistViewingPatientStore = false;
              });
            },
            onSwitchToPatient: () {
              setState(() {
                _pharmacistViewingPatientStore = true;
                _currentIndex = 0;
              });
            },
          );
        }

        // 2. Patient UI (or Pharmacist previewing customer store)
        final List<Widget> screens = [
          HomeScreen(
            onTabChange: _onTabTapped,
            onOpenCart: _openCart,
          ),
          const ExtractedMedicinesScreen(),
          PrescriptionScanScreen(
            onBack: () => _onTabTapped(0),
          ),
          OrderHistoryScreen(
            onBack: () => _onTabTapped(0),
          ),
          ProfileScreen(
            onBack: () => _onTabTapped(0),
            onLogout: () {
              appState.logout();
              setState(() {
                _isAuthenticated = false;
                _pharmacistViewingPatientStore = false;
              });
            },
          ),
        ];

        return Scaffold(
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: screens,
              ),

              // Pharmacist Quick Return Badge when previewing customer store
              if (isPharmacist && _pharmacistViewingPatientStore)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 6,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF0F172A),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: Color(0xFF2DD4BF), size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Pharmacist: Store Preview',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _pharmacistViewingPatientStore = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D9488),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Return to Panel',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              selectedItemColor: const Color(0xFF0D9488),
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              onTap: _onTabTapped,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.storefront_outlined),
                      if (appState.cartItems.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0D9488),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: const Icon(Icons.storefront_rounded),
                  label: 'Store',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.document_scanner_outlined),
                  activeIcon: Icon(Icons.document_scanner_rounded),
                  label: 'Scan',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Orders',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}