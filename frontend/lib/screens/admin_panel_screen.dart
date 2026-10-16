import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminPanelScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onSwitchToPatient;

  const AdminPanelScreen({
    super.key,
    this.onLogout,
    this.onSwitchToPatient,
  });

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  String _selectedFilter = 'PENDING';
  List<dynamic> _prescriptions = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  Future<void> _fetchPrescriptions() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService().getAllPrescriptions(
        status: _selectedFilter == 'ALL' ? null : _selectedFilter,
      );
      if (mounted) {
        setState(() {
          _prescriptions = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onFilterSelected(String filter) {
    setState(() => _selectedFilter = filter);
    _fetchPrescriptions();
  }

  void _openReviewModal(Map<String, dynamic> item) {
    final priceCtrl = TextEditingController(text: '${item['totalPrice'] ?? 580}');
    final notesCtrl = TextEditingController(text: item['pharmacistNotes'] ?? '');

    final code = item['prescriptionCode'] ?? ('EP${1000 + (item['id'] as int)}');
    final user = item['user'] ?? {'name': 'Kasun Perera', 'phone': '+94 77 123 4567'};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Review Prescription #$code',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(color: Color(0xFFE2E8F0)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFFCCFBF1),
                            child: Icon(Icons.person, color: Color(0xFF0F766E)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['name'] ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(user['phone'] ?? '+94 77 123 4567', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // AI Detected medicines box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCCFBF1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.auto_awesome, color: Color(0xFF0D9488), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'AI Detected Medicines',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F766E)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildAiItem('Panadol 500mg', '1 strip (10 tablets)', '96%'),
                          _buildAiItem('Amoxicillin 500mg', '1 strip (10 capsules)', '95%'),
                          _buildAiItem('Cetirizine 10mg', '1 strip (10 tablets)', '92%'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price input
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Verified Price (LKR)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixText: 'LKR ',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pharmacist notes
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Pharmacist Verification Notes',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        hintText: 'Verified dosage and brand substitution approved...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Modal Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await ApiService().reviewPrescription(
                        item['id'],
                        'REJECTED',
                        double.tryParse(priceCtrl.text) ?? 0,
                        notesCtrl.text,
                      );
                      _fetchPrescriptions();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await ApiService().reviewPrescription(
                        item['id'],
                        'APPROVED',
                        double.tryParse(priceCtrl.text) ?? 580.0,
                        notesCtrl.text,
                      );
                      _fetchPrescriptions();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Prescription #$code Approved!'), backgroundColor: const Color(0xFF0D9488)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiItem(String name, String dosage, String conf) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
              Text(dosage, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              conf,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _prescriptions.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final code = (p['prescriptionCode'] ?? '#${p['id']}').toString().toLowerCase();
      final user = (p['user'] != null ? p['user']['name'] : '').toString().toLowerCase();
      return code.contains(q) || user.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Navigator.canPop(context) ? Icons.arrow_back_rounded : Icons.storefront_outlined,
            color: const Color(0xFF0F172A),
          ),
          tooltip: Navigator.canPop(context) ? 'Back' : 'Patient Store View',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else if (widget.onSwitchToPatient != null) {
              widget.onSwitchToPatient!();
            }
          },
        ),
        title: const Text(
          'Pharmacist Portal',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0D9488)),
            tooltip: 'Refresh',
            onPressed: _fetchPrescriptions,
          ),
          if (widget.onSwitchToPatient != null)
            TextButton.icon(
              onPressed: widget.onSwitchToPatient,
              icon: const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF0D9488)),
              label: const Text(
                'Store',
                style: TextStyle(
                  color: Color(0xFF0D9488),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
              tooltip: 'Logout',
              onPressed: widget.onLogout,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs & Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('PENDING', 'Pending (5)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('APPROVED', 'Approved'),
                      const SizedBox(width: 8),
                      _buildFilterChip('REJECTED', 'Rejected'),
                      const SizedBox(width: 8),
                      _buildFilterChip('ALL', 'All'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Search by user, order ID...',
                      hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Table / Cards
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
                : filtered.isEmpty
                    ? const Center(
                        child: Text('No prescription requests found', style: TextStyle(color: Color(0xFF64748B))),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final code = item['prescriptionCode'] ?? ('#EP${1000 + (item['id'] as int)}');
                          final user = item['user'] ?? {'name': 'Kasun Perera', 'phone': '+94 77 123 4567'};
                          final status = (item['status'] ?? 'PENDING').toString().toUpperCase();
                          final detectedCount = item['aiDetectedCount'] ?? 3;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Thumbnail
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.receipt_long, color: Color(0xFF64748B), size: 24),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // User & Code
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '#$code',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user['name'] ?? 'Kasun Perera',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                      ),
                                      Text(
                                        '$detectedCount medicines detected',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),

                                // Status & Action
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _buildStatusBadge(status),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 32,
                                      child: ElevatedButton(
                                        onPressed: () => _openReviewModal(item),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: status == 'PENDING' ? const Color(0xFF0D9488) : const Color(0xFFF1F5F9),
                                          foregroundColor: status == 'PENDING' ? Colors.white : const Color(0xFF334155),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text(
                                          status == 'PENDING' ? 'Review' : 'View',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    bool isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF0D9488),
      backgroundColor: const Color(0xFFF1F5F9),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : const Color(0xFF475569),
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (val) {
        if (val) _onFilterSelected(key);
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    if (status == 'APPROVED') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF15803D);
    } else if (status == 'REJECTED') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFB91C1C);
    } else {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status[0] + status.substring(1).toLowerCase(),
        style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
