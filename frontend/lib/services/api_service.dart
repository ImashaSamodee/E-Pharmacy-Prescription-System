import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://localhost:8080';
    } else {
      return 'http://10.0.2.2:8080';
    }
  }

  String? _token;
  void setToken(String? token) => _token = token;

  Map<String, String> get _headers {
    final map = {'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) {
      map['Authorization'] = 'Bearer $_token';
    }
    return map;
  }

  // Auth: Login
  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      return UserModel.fromJson(data, token: _token);
    } else {
      throw Exception(response.body.isNotEmpty ? response.body : 'Invalid login credentials');
    }
  }

  // Auth: Register
  Future<UserModel> register(String name, String email, String password, String phone, String address, {String role = 'PATIENT'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      return UserModel.fromJson(data, token: _token);
    } else {
      throw Exception(response.body.isNotEmpty ? response.body : 'Registration failed');
    }
  }

  // Medicines: Browse & Search
  Future<List<MedicineModel>> getMedicines({String? category, String? search}) async {
    String url = '$baseUrl/api/medicines';
    List<String> params = [];
    if (search != null && search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search.trim())}');
    }
    if (category != null && category.trim().isNotEmpty && category != 'All') {
      params.add('category=${Uri.encodeComponent(category.trim())}');
    }
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => MedicineModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch medicines');
    }
  }

  // Prescription: Upload & AI Extract
  Future<Map<String, dynamic>> uploadPrescription(List<int> fileBytes, String filename, int userId) async {
    var uri = Uri.parse('$baseUrl/api/prescriptions/upload');
    var request = http.MultipartRequest('POST', uri);
    request.fields['userId'] = userId.toString();

    String ext = filename.split('.').last.toLowerCase();
    String mimeSubtype = (ext == 'png') ? 'png' : 'jpeg';

    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: filename,
      contentType: MediaType('image', mimeSubtype),
    );
    request.files.add(multipartFile);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Upload failed: ${response.statusCode}');
    }
  }

  // Prescription: User Scans
  Future<List<PrescriptionScanModel>> getUserPrescriptions(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/prescriptions/user/$userId'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => PrescriptionScanModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load prescription history');
    }
  }

  // Prescription: All (Pharmacist Admin)
  Future<List<dynamic>> getAllPrescriptions({String? status}) async {
    String url = '$baseUrl/api/prescriptions/all';
    if (status != null && status != 'ALL') {
      url += '?status=$status';
    }
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load prescriptions');
    }
  }

  // Prescription: Review / Approve / Reject
  Future<void> reviewPrescription(int id, String status, double totalPrice, String notes) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/prescriptions/$id/review'),
      headers: _headers,
      body: jsonEncode({
        'status': status,
        'totalPrice': totalPrice,
        'pharmacistNotes': notes,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to review prescription');
    }
  }

  // Orders: Place Order
  Future<OrderModel> placeOrder({
    required int userId,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    required String paymentMethod,
    required double subtotal,
    required double deliveryFee,
    required double totalAmount,
    required List<CartItemModel> items,
  }) async {
    final payload = {
      'userId': userId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'items': items.map((it) => {
        'medicineId': it.medicineId,
        'medicineName': it.name,
        'dosage': it.dosage,
        'quantity': it.quantity,
        'unitPrice': it.price,
        'totalPrice': it.totalPrice,
      }).toList(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: _headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return OrderModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to place order: ${response.body}');
    }
  }

  // Orders: Get User Orders
  Future<List<OrderModel>> getUserOrders(int userId, {String? status}) async {
    String url = '$baseUrl/api/orders/user/$userId';
    if (status != null && status != 'ALL') {
      url += '?status=$status';
    }
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Orders: Track by order number
  Future<OrderModel> trackOrder(String orderNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/api/orders/track/$orderNumber'), headers: _headers);
    if (response.statusCode == 200) {
      return OrderModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Order not found');
    }
  }

  // Orders: Update status (Admin)
  Future<void> updateOrderStatus(int orderId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/orders/$orderId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }

  // Payment: Stripe Intent
  Future<Map<String, dynamic>> createStripePaymentIntent(double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/payment/stripe-intent'),
      headers: _headers,
      body: jsonEncode({'amount': amount}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to initialize Stripe payment');
    }
  }

  // Notifications
  Future<List<NotificationModel>> getUserNotifications(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/notifications/user/$userId'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  Future<void> markNotificationRead(int notificationId) async {
    await http.put(Uri.parse('$baseUrl/api/notifications/$notificationId/read'), headers: _headers);
  }

  // User Profile Update
  Future<UserModel> updateProfile(int userId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/auth/profile/$userId'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body), token: _token);
    } else {
      throw Exception('Failed to update profile');
    }
  }
}
