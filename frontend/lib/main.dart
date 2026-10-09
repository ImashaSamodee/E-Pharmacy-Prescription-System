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
        primaryColor: const Color(0xFF2A8B8B),
        scaffoldBackgroundColor: const Color(0xFFF5F8FA),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigation(),
    );
  }
}

// Bottom Navigation bar ekka screens maru karanna
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2A8B8B),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'My Prescriptions',
          ),
        ],
      ),
    );
  }
}

// 1. Scan Screen (Hidanapu Upload screen eka)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String? _extractedText;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
        _extractedText = null;
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
          });
        } else {
          setState(() {
            _extractedText = "Error: Couldn't extract text. Status: ${response.statusCode}";
          });
        }
      } catch (e) {
         setState(() {
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Your health,", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text("in one place", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2A8B8B))),
                      SizedBox(height: 8),
                      Text("Good morning, Nimal", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const CircleAvatar(radius: 25, backgroundColor: Color(0xFFE2E8F0), child: Icon(Icons.person, color: Color(0xFF64748B)))
                ],
              ),
              const SizedBox(height: 40),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, spreadRadius: 5, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFE6F2F2), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.document_scanner_rounded, size: 40, color: Color(0xFF2A8B8B)),
                    ),
                    const SizedBox(height: 20),
                    const Text("Upload Prescription", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 10),
                    const Text("Take a photo of your medical prescription and let our AI extract the details instantly.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _pickAndUploadImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A8B8B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Scan Document", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              if (_extractedText != null) ...[
                const Text("Extracted Details:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    _extractedText!,
                    style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF334155)),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// 2. History Screen (Database eken kalin dapu prescriptions fetch karala pennana screen eka)
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _prescriptions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  Future<void> _fetchPrescriptions() async {
    try {
      String baseUrl = (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) 
          ? 'http://localhost:8080' 
          : 'http://10.0.2.2:8080';
      var response = await http.get(Uri.parse('$baseUrl/api/prescriptions/user/1'));

      if (response.statusCode == 200) {
        setState(() {
          _prescriptions = jsonDecode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Prescriptions", style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2A8B8B)))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _prescriptions.isEmpty
                  ? const Center(child: Text("No prescriptions found!", style: TextStyle(color: Colors.grey, fontSize: 16)))
                  : RefreshIndicator(
                      onRefresh: _fetchPrescriptions,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _prescriptions.length,
                        itemBuilder: (context, index) {
                          var item = _prescriptions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Prescription #${item['id']}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2A8B8B)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item['status'] ?? 'PROCESSED',
                                          style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item['extractedText'] ?? 'No text extracted',
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}