import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;
  final VoidCallback onOpenCart;

  const HomeScreen({
    super.key,
    required this.onTabChange,
    required this.onOpenCart,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MedicineModel> _medicines = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Pain relief',
    'Cold & Flu',
    'First Aid',
    'Supplements',
    'Digestive',
  ];

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMedicines() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService().getMedicines(
        category: AppState().selectedCategory,
        search: _searchQuery,
      );
      setState(() {
        _medicines = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onCategorySelected(String category) {
    AppState().setCategory(category);
    _fetchMedicines();
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
    _fetchMedicines();
  }

  void _openNotificationsModal() async {
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
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
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
                Row(
                  children: const [
                    Icon(Icons.notifications_active_rounded, color: Color(0xFF0D9488), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(color: Color(0xFFE2E8F0)),
            Expanded(
              child: notifs.isEmpty
                  ? const Center(
                      child: Text('No new notifications', style: TextStyle(color: Color(0xFF64748B))),
                    )
                  : ListView.builder(
                      itemCount: notifs.length,
                      itemBuilder: (ctx, i) {
                        final n = notifs[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCCFBF1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.info_outline_rounded, color: Color(0xFF0F766E), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n.message,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchMedicines,
          color: const Color(0xFF0D9488),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'MediCare LK',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Cart Icon with count
                        Stack(
                          children: [
                            IconButton(
                              onPressed: widget.onOpenCart,
                              icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF334155), size: 26),
                            ),
                            if (appState.cartItems.isNotEmpty)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0D9488),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${appState.cartItems.length}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Notification Bell with badge
                        Stack(
                          children: [
                            IconButton(
                              onPressed: _openNotificationsModal,
                              icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF334155), size: 26),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search medicines, health products...',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Category Chips (Horizontal Scroll)
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = appState.selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => _onCategorySelected(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0D9488) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Promo Banner (Stay Healthy Stay Protected Upto 20% OFF)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Stay Healthy',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const Text(
                              'Stay Protected',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Upto 20% OFF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Popular Medicines Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Medicines',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _onCategorySelected('All'),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: Color(0xFF0D9488),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Medicine Cards Grid
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                    ),
                  )
                else if (_medicines.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('No medicines found matching your search.', style: TextStyle(color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.76,
                    ),
                    itemCount: _medicines.length,
                    itemBuilder: (context, index) {
                      final med = _medicines[index];
                      return _buildMedicineCard(med);
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineCard(MedicineModel med) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine Image Box
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: med.imageUrl != null && med.imageUrl!.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          med.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.medication_rounded,
                            size: 40,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.medication_rounded,
                        size: 40,
                        color: Color(0xFF0D9488),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Name
          Text(
            med.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),

          // Generic / Category
          Text(
            med.genericName ?? med.category ?? 'Medicine',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),

          // Price & Add to Cart button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LKR ${med.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () {
                  AppState().addToCart(med);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${med.name} added to cart!'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: const Color(0xFF0D9488),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
