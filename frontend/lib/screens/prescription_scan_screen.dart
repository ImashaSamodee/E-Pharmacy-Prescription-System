import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'extracted_medicines_screen.dart';

class PrescriptionScanScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const PrescriptionScanScreen({super.key, this.onBack});

  @override
  State<PrescriptionScanScreen> createState() => _PrescriptionScanScreenState();
}

class _PrescriptionScanScreenState extends State<PrescriptionScanScreen> {
  bool _isLoading = false;
  List<PrescriptionScanModel> _recentScans = [];
  List<Map<String, dynamic>> _detectedMedicines = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentScans();
  }

  Future<void> _fetchRecentScans() async {
    final user = AppState().currentUser;
    if (user != null) {
      try {
        final list = await ApiService().getUserPrescriptions(user.id);
        if (mounted) {
          setState(() {
            _recentScans = list;
            // Load detected medicines from the latest scan if available
            if (_detectedMedicines.isEmpty && list.isNotEmpty) {
              final latest = list.first;
              if (latest.extractedMedicinesJson != null && latest.extractedMedicinesJson!.isNotEmpty) {
                try {
                  final decoded = jsonDecode(latest.extractedMedicinesJson!);
                  if (decoded is List) {
                    _detectedMedicines = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
                  }
                } catch (_) {}
              }
            }
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final user = AppState().currentUser;
      final userId = user?.id ?? 1;
      final bytes = await pickedFile.readAsBytes();

      final res = await ApiService().uploadPrescription(
        bytes,
        pickedFile.name.isNotEmpty ? pickedFile.name : 'prescription.jpg',
        userId,
      );

      // Parse extracted medicines from real response
      List<CartItemModel> extractedCart = [];
      List<Map<String, dynamic>> newDetected = [];

      if (res['extractedMedicinesJson'] != null && res['extractedMedicinesJson'].toString().isNotEmpty) {
        try {
          final decoded = jsonDecode(res['extractedMedicinesJson'].toString());
          if (decoded is List) {
            for (var item in decoded) {
              final map = Map<String, dynamic>.from(item);
              newDetected.add(map);
              extractedCart.add(CartItemModel(
                name: map['name']?.toString() ?? 'Prescribed Medicine',
                dosage: map['dosage']?.toString() ?? '1 strip (10 tablets)',
                price: (map['price'] is num) ? (map['price'] as num).toDouble() : 150.0,
                quantity: 1,
                isSelected: true,
                confidence: map['confidence']?.toString() ?? '95%',
              ));
            }
          }
        } catch (_) {}
      }

      if (extractedCart.isNotEmpty) {
        AppState().setExtractedCartItems(extractedCart);
      }

      setState(() {
        _detectedMedicines = newDetected;
        _isLoading = false;
      });

      _fetchRecentScans();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prescription processed! AI detected ${newDetected.length} medicines.'),
            backgroundColor: const Color(0xFF0D9488),
          ),
        );

        if (extractedCart.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => const ExtractedMedicinesScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload or AI error: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  void _openExtractedScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const ExtractedMedicinesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'AI Prescription Scan',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Scan Your Prescription',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Upload or take a photo of your prescription and let our AI extract the medicines.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Prescription Graphic Illustration
                  Container(
                    width: 90,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCCFBF1), width: 1.5),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: const [
                        Icon(Icons.description_outlined, size: 54, color: Color(0xFF0D9488)),
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Icon(Icons.auto_awesome, size: 18, color: Color(0xFF0D9488)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_isLoading)
                    Column(
                      children: const [
                        CircularProgressIndicator(color: Color(0xFF0D9488)),
                        SizedBox(height: 12),
                        Text(
                          'Analyzing with Gemini Vision AI...',
                          style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    )
                  else ...[
                    // Take Photo Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickAndUploadImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                        label: const Text(
                          'Take Photo',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Upload from Gallery Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickAndUploadImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, color: Color(0xFF0D9488), size: 20),
                        label: const Text(
                          'Upload from Gallery',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0D9488)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0D9488)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // Privacy Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shield_outlined, color: Color(0xFF059669), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Your data is secure and private',
                        style: TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Scans Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Scans',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: _openExtractedScreen,
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Recent Scans List
            if (_recentScans.isNotEmpty)
              ..._recentScans.take(3).map((scan) => _buildRecentScanCard(
                    title: 'Scan #${scan.prescriptionCode}',
                    subtitle: '${dateFormat.format(scan.createdAt)} • ${scan.aiDetectedCount} medicines',
                    badge: scan.status == 'APPROVED' ? 'Approved' : (scan.status == 'REJECTED' ? 'Rejected' : 'Extracted'),
                    onTap: _openExtractedScreen,
                  ))
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.document_scanner_outlined, color: Color(0xFF94A3B8), size: 36),
                    SizedBox(height: 8),
                    Text(
                      'No recent prescriptions found',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Upload a prescription above to digitize it.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // AI Detected Medicines Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Detected Medicines',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (_detectedMedicines.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0D9488)),
                    onPressed: _openExtractedScreen,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Detected Medicines Items
            if (_detectedMedicines.isNotEmpty)
              ..._detectedMedicines.map((med) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFBF1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.medication_rounded, size: 20, color: Color(0xFF0F766E)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med['name']?.toString() ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  med['dosage']?.toString() ?? '',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                med['confidence']?.toString() ?? '95%',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF0D9488), size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Upload a prescription above to extract and verify medicines with AI.',
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Review & Add to Cart button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _openExtractedScreen,
                icon: const Icon(Icons.checklist_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Review Extracted Medicines',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _buildRecentScanCard({
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: const Center(
            child: Icon(Icons.receipt_long_rounded, color: Color(0xFF64748B), size: 24),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
        onTap: onTap,
      ),
    ),
  );
  }
}
