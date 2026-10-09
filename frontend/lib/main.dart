import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(const EPharmacyApp());
}

class EPharmacyApp extends StatelessWidget {
  const EPharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Pharmacy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF0D9488),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner_rounded),
              activeIcon: Icon(Icons.document_scanner_rounded),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              activeIcon: Icon(Icons.history_rounded),
              label: 'My Prescriptions',
            ),
          ],
        ),
      ),
    );
  }
}

// Model for structured prescription items
class MedicineItem {
  final String name;
  final String? dosage;
  final String? duration;
  final String? instruction;

  MedicineItem({
    required this.name,
    this.dosage,
    this.duration,
    this.instruction,
  });
}

// Parser function to convert raw Gemini text into structured medicines
List<MedicineItem> parsePrescriptionText(String rawText) {
  final List<MedicineItem> medicines = [];
  final lines = rawText.split('\n');

  String? currentName;
  String? currentDosage;
  String? currentDuration;
  String? currentInstruction;

  void commitMedicine() {
    if (currentName != null && currentName!.trim().isNotEmpty) {
      medicines.add(MedicineItem(
        name: currentName!.trim(),
        dosage: currentDosage?.trim(),
        duration: currentDuration?.trim(),
        instruction: currentInstruction?.trim(),
      ));
    }
    currentName = null;
    currentDosage = null;
    currentDuration = null;
    currentInstruction = null;
  }

  for (var line in lines) {
    String trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    String lower = trimmed.toLowerCase();
    if (lower.contains("prescription details") || 
        lower.contains("extracted medicines and instructions") ||
        lower.contains("here are the extracted") ||
        lower.contains("from the prescription")) {
      continue;
    }

    String clean = trimmed.replaceAll('*', '').trim();

    final dosageMatch = RegExp(r'^(dosage|dose)\s*:\s*(.*)', caseSensitive: false).firstMatch(clean);
    final durationMatch = RegExp(r'^(duration)\s*:\s*(.*)', caseSensitive: false).firstMatch(clean);
    final instructionMatch = RegExp(r'^(instruction|instructions|adv|advice)\s*:\s*(.*)', caseSensitive: false).firstMatch(clean);

    if (dosageMatch != null) {
      currentDosage = dosageMatch.group(2);
    } else if (durationMatch != null) {
      currentDuration = durationMatch.group(2);
    } else if (instructionMatch != null) {
      currentInstruction = instructionMatch.group(2);
    } else {
      bool isHeader = trimmed.startsWith('* **') || 
                      trimmed.startsWith('- **') || 
                      RegExp(r'^\d+[\.\)]\s*\*\*').hasMatch(trimmed) ||
                      RegExp(r'^\d+[\.\)]\s+[A-Za-z]').hasMatch(trimmed) ||
                      (trimmed.startsWith('*') && !clean.contains(':'));

      if (isHeader) {
        commitMedicine();
        String name = clean
            .replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '')
            .replaceFirst(RegExp(r'^[•\-\*]\s*'), '')
            .replaceFirst(RegExp(r'^adv\s*:\s*', caseSensitive: false), '')
            .trim();
        if (name.isNotEmpty) {
          currentName = name;
        }
      }
    }
  }
  commitMedicine();
  return medicines;
}

// Check whether text is an error response
bool isErrorText(String? text, String? status) {
  if (status == 'REJECTED' || status == 'FAILED') return true;
  if (text == null || text.trim().isEmpty) return true;
  final lower = text.toLowerCase();
  return lower.contains('error extracting text:') || 
         lower.contains('503 service unavailable') ||
         lower.contains('404 not found') ||
         lower.contains('400 bad request') ||
         lower.contains('raw binary data') ||
         lower.contains('could not read prescription') ||
         lower.contains('unable to extract') ||
         lower.contains('failed to load');
}

// Reusable widget to display structured medicines or friendly error
class PrescriptionDetailsWidget extends StatelessWidget {
  final String rawText;
  final String status;

  const PrescriptionDetailsWidget({
    super.key,
    required this.rawText,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (isErrorText(rawText, status)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Extraction Unclear",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "The prescription could not be read clearly. Please make sure the photo is sharp, properly lit, and try uploading again.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF7F1D1D), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final medicines = parsePrescriptionText(rawText);

    if (medicines.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: medicines.map((med) => _buildMedicineCard(med)).toList(),
      );
    }

    // Fallback formatted text view
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rawText
            .split('\n')
            .map((line) => line.replaceAll('*', '').trim())
            .where((line) => line.isNotEmpty)
            .map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          line,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMedicineCard(MedicineItem med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  med.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (med.dosage != null && med.dosage!.isNotEmpty)
                _buildTag(
                  icon: Icons.access_time_rounded,
                  label: "Dosage: ${med.dosage}",
                  bgColor: const Color(0xFFE0F2FE),
                  textColor: const Color(0xFF0369A1),
                  iconColor: const Color(0xFF0284C7),
                ),
              if (med.duration != null && med.duration!.isNotEmpty)
                _buildTag(
                  icon: Icons.calendar_today_rounded,
                  label: "Duration: ${med.duration}",
                  bgColor: const Color(0xFFF3E8FF),
                  textColor: const Color(0xFF7E22CE),
                  iconColor: const Color(0xFF9333EA),
                ),
              if (med.instruction != null && med.instruction!.isNotEmpty)
                _buildTag(
                  icon: Icons.info_outline_rounded,
                  label: med.instruction!,
                  bgColor: const Color(0xFFFEF3C7),
                  textColor: const Color(0xFFB45309),
                  iconColor: const Color(0xFFD97706),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 1. Scan Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String? _extractedText;
  String? _status;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
        _extractedText = null;
        _status = null;
      });
      try {
        String baseUrl = (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) 
            ? 'http://localhost:8080' 
            : 'http://10.0.2.2:8080';
        var uri = Uri.parse('$baseUrl/api/prescriptions/upload');
        
        var request = http.MultipartRequest('POST', uri);
        request.fields['userId'] = '1';

        var fileBytes = await pickedFile.readAsBytes();
        var multipartFile = http.MultipartFile.fromBytes(
          'file', 
          fileBytes,
          filename: pickedFile.name.isNotEmpty ? pickedFile.name : 'prescription.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);

        var response = await request.send();
        var responseData = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          var data = jsonDecode(responseData.body);
          setState(() {
            _extractedText = data['extractedText'];
            _status = data['status'] ?? 'PROCESSED';
          });
        } else {
          setState(() {
            _status = 'REJECTED';
            _extractedText = "Error: Couldn't extract text. Status: ${response.statusCode}";
          });
        }
      } catch (e) {
         setState(() {
            _status = 'REJECTED';
            _extractedText = "Error connecting to server: $e";
          });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Your health,", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text("in one place", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                      SizedBox(height: 6),
                      Text("Good day, Nimal", style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 24, 
                    backgroundColor: Color(0xFFE2E8F0), 
                    child: Icon(Icons.person_rounded, color: Color(0xFF64748B), size: 28),
                  )
                ],
              ),
              const SizedBox(height: 28),
              
              // Upload Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04), 
                      blurRadius: 16, 
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1), 
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.document_scanner_rounded, size: 36, color: Color(0xFF0F766E)),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Upload Prescription", 
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Upload or capture a photo of your medical prescription to extract medicine details instantly.", 
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
                    ),
                    const SizedBox(height: 22),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _pickAndUploadImage,
                        icon: _isLoading 
                            ? const SizedBox.shrink() 
                            : const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 20),
                        label: _isLoading 
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text("Scan Document", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              if (_extractedText != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Extracted Prescription Details", 
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _extractedText = null;
                          _status = null;
                        });
                      },
                      icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                      label: const Text("Clear", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                PrescriptionDetailsWidget(
                  rawText: _extractedText!,
                  status: _status ?? 'PROCESSED',
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// 2. History Screen
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _prescriptions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'ALL'; // 'ALL', 'PROCESSED', 'REJECTED'

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  String _getBaseUrl() {
    return (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) 
        ? 'http://localhost:8080' 
        : 'http://10.0.2.2:8080';
  }

  Future<void> _fetchPrescriptions() async {
    try {
      setState(() => _isLoading = true);
      var response = await http.get(Uri.parse('${_getBaseUrl()}/api/prescriptions/user/1'));

      if (response.statusCode == 200) {
        setState(() {
          _prescriptions = jsonDecode(response.body);
          _errorMessage = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load history. Status: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error connecting to server: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePrescription(dynamic item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Prescription?"),
        content: Text("Are you sure you want to delete Prescription #${item['id']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        var response = await http.delete(
          Uri.parse('${_getBaseUrl()}/api/prescriptions/${item['id']}'),
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          setState(() {
            _prescriptions.removeWhere((p) => p['id'] == item['id']);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Prescription #${item['id']} deleted successfully."),
                backgroundColor: const Color(0xFF0D9488),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  List<dynamic> get _filteredPrescriptions {
    if (_selectedFilter == 'ALL') {
      return _prescriptions;
    }
    return _prescriptions.where((item) {
      String status = (item['status'] ?? 'PROCESSED').toString().toUpperCase();
      bool hasError = isErrorText(item['extractedText']?.toString(), status);
      if (_selectedFilter == 'PROCESSED') {
        return !hasError && status == 'PROCESSED';
      } else {
        return hasError || status == 'REJECTED';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPrescriptions;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Prescriptions", 
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0D9488)),
            onPressed: _fetchPrescriptions,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip("ALL", "All (${_prescriptions.length})"),
                const SizedBox(width: 8),
                _buildFilterChip("PROCESSED", "Processed"),
                const SizedBox(width: 8),
                _buildFilterChip("REJECTED", "Unclear / Failed"),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _fetchPrescriptions,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
                                child: const Text("Retry", style: TextStyle(color: Colors.white)),
                              )
                            ],
                          ),
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_rounded, size: 54, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  _selectedFilter == 'ALL' 
                                      ? "No prescriptions found!" 
                                      : "No ${_selectedFilter.toLowerCase()} prescriptions.",
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchPrescriptions,
                            color: const Color(0xFF0D9488),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                var item = filtered[index];
                                String status = (item['status'] ?? 'PROCESSED').toString().toUpperCase();
                                bool hasError = isErrorText(item['extractedText']?.toString(), status);
                                if (hasError) status = 'REJECTED';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header Row with ID, Status Badge, and Delete Button
                                        Row(
                                          children: [
                                            Text(
                                              "Prescription #${item['id']}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildStatusBadge(status),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFF94A3B8)),
                                              hoverColor: const Color(0xFFFEE2E2),
                                              onPressed: () => _deletePrescription(item),
                                              tooltip: "Delete prescription",
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Structured content
                                        PrescriptionDetailsWidget(
                                          rawText: item['extractedText'] ?? 'No text extracted',
                                          status: status,
                                        ),
                                      ],
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

  Widget _buildFilterChip(String key, String label) {
    bool isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF0D9488),
      backgroundColor: const Color(0xFFF1F5F9),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedFilter = key;
          });
        }
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    IconData icon;
    String displayStatus;

    if (status == 'PROCESSED') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF15803D);
      icon = Icons.check_circle_rounded;
      displayStatus = 'PROCESSED';
    } else if (status == 'REJECTED' || status == 'FAILED') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFB91C1C);
      icon = Icons.cancel_rounded;
      displayStatus = 'FAILED';
    } else {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
      icon = Icons.hourglass_top_rounded;
      displayStatus = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            displayStatus,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}