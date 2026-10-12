import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'admin_panel_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onBack;

  const ProfileScreen({super.key, required this.onLogout, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _editPersonalInformation() {
    final user = AppState().currentUser;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Personal Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final updated = await ApiService().updateProfile(user.id, {
                  'name': nameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                });
                AppState().setUser(updated);
                if (mounted) {
                  nav.pop();
                  setState(() {});
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                  );
                }
              } catch (_) {
                nav.pop();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editDeliveryAddresses() {
    final user = AppState().currentUser;
    if (user == null) return;

    final addrCtrl = TextEditingController(text: user.address);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: TextField(
          controller: addrCtrl,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Street, City & Postal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final updated = await ApiService().updateProfile(user.id, {
                  'address': addrCtrl.text.trim(),
                });
                AppState().setUser(updated);
                if (mounted) {
                  nav.pop();
                  setState(() {});
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Address updated!')),
                  );
                }
              } catch (_) {
                nav.pop();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethods() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Methods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.credit_card_rounded, color: Color(0xFF0284C7)),
              title: const Text('Visa Card •••• 4242'),
              subtitle: const Text('Expires 12/28 • Default'),
              trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF0D9488)),
            ),
            ListTile(
              leading: const Icon(Icons.payments_outlined, color: Color(0xFFD97706)),
              title: const Text('Cash on Delivery (COD)'),
              subtitle: const Text('Pay upon arrival'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() async {
    final user = AppState().currentUser;
    if (user == null) return;
    List<NotificationModel> notifs = [];
    try {
      notifs = await ApiService().getUserNotifications(user.id);
    } catch (_) {}

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications & Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: notifs.isEmpty
                  ? const Center(child: Text('No notifications'))
                  : ListView.builder(
                      itemCount: notifs.length,
                      itemBuilder: (ctx, i) => ListTile(
                        leading: const Icon(Icons.notifications_active_rounded, color: Color(0xFF0D9488)),
                        title: Text(notifs[i].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(notifs[i].message),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState().currentUser ??
        UserModel(
          id: 2,
          name: 'Kasun Perera',
          email: 'kasun@email.com',
          role: 'PATIENT',
          phone: '+94 77 123 4567',
          address: 'No. 123, Galle Road, Colombo 04',
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          children: [
            // Profile Card Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.person_rounded, size: 48, color: Color(0xFF0F766E)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.phone,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Profile Options Menu
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    onTap: _editPersonalInformation,
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Delivery Addresses',
                    onTap: _editDeliveryAddresses,
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.credit_card_outlined,
                    title: 'Payment Methods',
                    onTap: _showPaymentMethods,
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: _showNotifications,
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Health Records',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Prescriptions synced with doctor notes.')),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Pharmacist Admin Panel Mode',
                    subtitle: 'Switch to Pharmacist Dashboard',
                    highlight: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const AdminPanelScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('App version 1.0.0 (MediCare LK)')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  AppState().logout();
                  widget.onLogout();
                },
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
                label: const Text(
                  'Log Out',
                  style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  backgroundColor: const Color(0xFFFEF2F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool highlight = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: highlight ? const Color(0xFFCCFBF1) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: highlight ? const Color(0xFF0F766E) : const Color(0xFF64748B),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
            color: highlight ? const Color(0xFF0D9488) : const Color(0xFF0F172A),
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))
            : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));
  }
}
