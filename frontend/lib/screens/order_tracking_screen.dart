import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late OrderModel _order;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _refreshOrder() async {
    setState(() => _isRefreshing = true);
    try {
      final updated = await ApiService().trackOrder(_order.orderNumber);
      setState(() {
        _order = updated;
        _isRefreshing = false;
      });
    } catch (_) {
      setState(() => _isRefreshing = false);
    }
  }

  int _getStatusStepIndex(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 0;
      case 'PROCESSING':
        return 1;
      case 'SHIPPED':
        return 2;
      case 'DELIVERED':
        return 3;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepIndex = _getStatusStepIndex(_order.status);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final dateStr = dateFormat.format(_order.createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Tracking',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Color(0xFF0D9488), strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, color: Color(0xFF0D9488)),
            onPressed: _refreshOrder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.inventory_2_outlined, color: Color(0xFF0284C7), size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${_order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Placed on $dateStr',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stepper Timeline Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildTimelineStep(
                    title: 'Pending',
                    subtitle: dateStr,
                    isCompleted: stepIndex >= 0,
                    isActive: stepIndex == 0,
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    title: 'Processing',
                    subtitle: stepIndex >= 1 ? 'Your order is being prepared' : 'Awaiting confirmation',
                    isCompleted: stepIndex >= 1,
                    isActive: stepIndex == 1,
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    title: 'Shipped',
                    subtitle: stepIndex >= 2 ? 'Out for delivery' : 'Yet to ship',
                    isCompleted: stepIndex >= 2,
                    isActive: stepIndex == 2,
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    title: 'Delivered',
                    subtitle: stepIndex >= 3
                        ? 'Delivered safely'
                        : 'Estimated: 13 Oct 2026 (9:00 AM - 5:00 PM)',
                    isCompleted: stepIndex >= 3,
                    isActive: stepIndex == 3,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Estimated Delivery Card (Green banner)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Estimated Delivery',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tomorrow, 13 Oct 2026',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF14532D)),
                      ),
                      Text(
                        '9:00 AM - 5:00 PM',
                        style: TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Details Section
            const Text(
              'Order Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // Order Item Cards
            ..._order.items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.medication_rounded, color: Color(0xFF0D9488), size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.medicineName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Qty: ${item.quantity}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'LKR ${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                  Text(
                    'LKR ${_order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0D9488)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    Widget icon;

    if (isActive) {
      icon = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF0D9488),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCCFBF1), width: 3),
        ),
      );
    } else if (isCompleted) {
      icon = Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFF0D9488),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    } else {
      icon = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator & vertical line
          Column(
            children: [
              icon,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isCompleted || isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
