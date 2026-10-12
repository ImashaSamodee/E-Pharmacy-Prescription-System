import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const OrderHistoryScreen({super.key, this.onBack});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedFilter = 'ALL'; // ALL, PROCESSING, DELIVERED, CANCELLED
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final user = AppState().currentUser;
    if (user != null) {
      try {
        final list = await ApiService().getUserOrders(
          user.id,
          status: _selectedFilter == 'ALL' ? null : _selectedFilter,
        );
        setState(() {
          _orders = list;
          _isLoading = false;
        });
      } catch (_) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _onFilterSelected(String filter) {
    setState(() => _selectedFilter = filter);
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['ALL', 'PROCESSING', 'DELIVERED', 'CANCELLED'];
    final dateFormat = DateFormat('dd MMM yyyy');

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
          'Order History',
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
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((f) {
                  final isSelected = _selectedFilter == f;
                  String label = f == 'ALL' ? 'All' : f[0] + f.substring(1).toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0D9488),
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (val) {
                        if (val) _onFilterSelected(f);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
                : _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 54, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No orders found',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchOrders,
                        color: const Color(0xFF0D9488),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final o = _orders[index];
                            final status = o.status.toUpperCase();
                            final itemsCount = o.items.isNotEmpty ? o.items.length : 4;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Material(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.inventory_2_outlined, color: Color(0xFF0D9488), size: 22),
                                  ),
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '#${o.orderNumber}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                                    ),
                                    _buildStatusBadge(status),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$itemsCount items • LKR ${o.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                      ),
                                      Text(
                                        dateFormat.format(o.createdAt),
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => OrderTrackingScreen(order: o),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    switch (status) {
      case 'PROCESSING':
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF0284C7);
        break;
      case 'DELIVERED':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF15803D);
        break;
      case 'CANCELLED':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFB91C1C);
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        break;
    }

    String label = status[0] + status.substring(1).toLowerCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
