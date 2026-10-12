import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'checkout_screen.dart';

class ExtractedMedicinesScreen extends StatefulWidget {
  const ExtractedMedicinesScreen({super.key});

  @override
  State<ExtractedMedicinesScreen> createState() => _ExtractedMedicinesScreenState();
}

class _ExtractedMedicinesScreenState extends State<ExtractedMedicinesScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final items = appState.cartItems;
        final total = appState.subtotal;
        final selectedCount = appState.selectedItemsCount;

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
              'Extracted Medicines',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Please review the medicines detected by AI and add to cart.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 16),

                      if (items.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 56, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text(
                                  'Your cart is empty',
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...items.map((it) => _buildExtractedItemCard(it)),

                      const SizedBox(height: 14),

                      // Add more medicines from store button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Goes back to home/store
                          },
                          icon: const Icon(Icons.add_rounded, color: Color(0xFF0D9488), size: 20),
                          label: const Text(
                            'Add more medicines from store',
                            style: TextStyle(
                              color: Color(0xFF0D9488),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total ($selectedCount items)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            'LKR ${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: selectedCount > 0
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => const CheckoutScreen(),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExtractedItemCard(CartItemModel item) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: item.isSelected,
              activeColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              onChanged: (_) => AppState().toggleItemSelection(item),
            ),
          ),
          const SizedBox(width: 8),

          // Medicine Icon Box
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Icon(Icons.medication_rounded, size: 24, color: Color(0xFF0D9488)),
            ),
          ),
          const SizedBox(width: 12),

          // Name & Dosage
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.dosage,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                ),
              ],
            ),
          ),

          // Price & Stepper
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'LKR ${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              // Quantity Stepper [- 1 +]
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => AppState().updateQuantity(item, -1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(Icons.remove, size: 14, color: Color(0xFF475569)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ),
                    InkWell(
                      onTap: () => AppState().updateQuantity(item, 1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(Icons.add, size: 14, color: Color(0xFF0D9488)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
