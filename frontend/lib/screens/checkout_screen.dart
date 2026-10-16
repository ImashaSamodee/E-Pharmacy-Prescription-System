import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'CARD'; // 'CARD' or 'COD'
  bool _isPlacingOrder = false;

  late String _deliveryAddress;
  late String _customerName;
  late String _customerPhone;

  @override
  void initState() {
    super.initState();
    final user = AppState().currentUser;
    _customerName = user?.name ?? 'Kasun Perera';
    _deliveryAddress = user?.address ?? 'No. 123, Galle Road, Colombo 04, Colombo';
    _customerPhone = user?.phone ?? '+94 77 123 4567';
  }

  void _openAddressDialog() {
    final nameCtrl = TextEditingController(text: _customerName);
    final addrCtrl = TextEditingController(text: _deliveryAddress);
    final phoneCtrl = TextEditingController(text: _customerPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Recipient Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addrCtrl,
              decoration: const InputDecoration(labelText: 'Street Address & City'),
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
            onPressed: () {
              setState(() {
                _customerName = nameCtrl.text.trim();
                _deliveryAddress = addrCtrl.text.trim();
                _customerPhone = phoneCtrl.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save Address', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder() async {
    final appState = AppState();
    final selectedItems = appState.cartItems.where((it) => it.isSelected).toList();
    if (selectedItems.isEmpty) return;

    setState(() => _isPlacingOrder = true);

    try {
      // 1. If card payment, simulate/call Stripe payment intent
      if (_paymentMethod == 'CARD') {
        try {
          await ApiService().createStripePaymentIntent(appState.totalAmount);
        } catch (_) {}
      }

      // 2. Place order on backend
      final order = await ApiService().placeOrder(
        userId: appState.currentUser?.id ?? 1,
        customerName: _customerName,
        customerPhone: _customerPhone,
        deliveryAddress: _deliveryAddress,
        paymentMethod: _paymentMethod,
        subtotal: appState.subtotal,
        deliveryFee: appState.deliveryFee,
        totalAmount: appState.totalAmount,
        items: selectedItems,
      );

      // Clear cart
      appState.clearCart();

      if (mounted) {
        setState(() => _isPlacingOrder = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${order.orderNumber} placed successfully!'),
            backgroundColor: const Color(0xFF0D9488),
          ),
        );

        // Navigate directly to Order Tracking Screen (Screen 6)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (ctx) => OrderTrackingScreen(order: order),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final selectedItems = appState.cartItems.where((it) => it.isSelected).toList();

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
          'Checkout',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Header & Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                TextButton(
                  onPressed: _openAddressDialog,
                  child: const Text('Change', style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_on_rounded, color: Color(0xFF0F766E), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _deliveryAddress,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _customerPhone,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Text(
                  '${selectedItems.length} items',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // Item list
                  ...selectedItems.map((it) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    it.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'x${it.quantity}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'LKR ${it.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      )),

                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  const SizedBox(height: 8),

                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      Text('LKR ${appState.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Delivery Fee
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery Fee', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      Text('LKR ${appState.deliveryFee.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Text(
                        'LKR ${appState.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0D9488)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // Card Option (Stripe)
            GestureDetector(
              onTap: () => setState(() => _paymentMethod = 'CARD'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _paymentMethod == 'CARD' ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                    width: _paymentMethod == 'CARD' ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.credit_card_rounded, color: Color(0xFF0284C7), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Card Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                          SizedBox(height: 2),
                          Text('Visa, Mastercard, Amex (Stripe)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _paymentMethod == 'CARD' ? const Color(0xFF0D9488) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: _paymentMethod == 'CARD'
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D9488),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Cash on Delivery Option
            GestureDetector(
              onTap: () => setState(() => _paymentMethod = 'COD'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _paymentMethod == 'COD' ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                    width: _paymentMethod == 'COD' ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.payments_outlined, color: Color(0xFFD97706), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                          SizedBox(height: 2),
                          Text('Pay when you receive', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _paymentMethod == 'COD' ? const Color(0xFF0D9488) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: _paymentMethod == 'COD'
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D9488),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Confirm Order Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isPlacingOrder ? null : _confirmOrder,
                icon: _isPlacingOrder
                    ? const SizedBox.shrink()
                    : const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                label: _isPlacingOrder
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Confirm Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  elevation: 0,
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
}
