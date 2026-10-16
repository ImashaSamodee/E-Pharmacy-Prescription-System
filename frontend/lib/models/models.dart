class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String address;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.address,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 1,
      name: json['name'] ?? 'Kasun Perera',
      email: json['email'] ?? 'kasun@email.com',
      role: json['role'] ?? 'PATIENT',
      phone: json['phone'] ?? '+94 77 123 4567',
      address: json['address'] ?? 'No. 123, Galle Road, Colombo 04, Colombo',
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'phone': phone,
    'address': address,
    'token': token,
  };
}

class MedicineModel {
  final int id;
  final String name;
  final String? genericName;
  final String? category;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? description;
  final String? dosageForm;
  final String? confidence;

  MedicineModel({
    required this.id,
    required this.name,
    this.genericName,
    this.category,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.description,
    this.dosageForm,
    this.confidence,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      genericName: json['genericName'],
      category: json['category'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      stock: json['stock'] is int ? json['stock'] : 100,
      imageUrl: json['imageUrl'],
      description: json['description'],
      dosageForm: json['dosageForm'],
      confidence: json['confidence'],
    );
  }
}

class CartItemModel {
  final int? medicineId;
  final String name;
  final String dosage;
  final double price;
  int quantity;
  bool isSelected;
  final String? confidence;

  CartItemModel({
    this.medicineId,
    required this.name,
    required this.dosage,
    required this.price,
    this.quantity = 1,
    this.isSelected = true,
    this.confidence,
  });

  double get totalPrice => price * quantity;
}

class OrderItemModel {
  final int? id;
  final String medicineName;
  final String dosage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItemModel({
    this.id,
    required this.medicineName,
    required this.dosage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] is int ? json['id'] : null,
      medicineName: json['medicineName'] ?? 'Medicine',
      dosage: json['dosage'] ?? '1 strip (10 tablets)',
      quantity: json['quantity'] is int ? json['quantity'] : 1,
      unitPrice: json['unitPrice'] != null ? (json['unitPrice'] as num).toDouble() : 0.0,
      totalPrice: json['totalPrice'] != null ? (json['totalPrice'] as num).toDouble() : 0.0,
    );
  }
}

class OrderModel {
  final int id;
  final String orderNumber;
  final UserModel? user;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  String status;
  final String paymentMethod;
  final String paymentStatus;
  final String deliveryAddress;
  final String customerName;
  final String customerPhone;
  final String? estimatedDelivery;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    this.user,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.deliveryAddress,
    required this.customerName,
    required this.customerPhone,
    this.estimatedDelivery,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List<dynamic>? ?? [];
    List<OrderItemModel> itemsList = rawItems.map((e) => OrderItemModel.fromJson(e)).toList();

    return OrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orderNumber: json['orderNumber'] ?? 'EP1000',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      items: itemsList,
      subtotal: json['subtotal'] != null ? (json['subtotal'] as num).toDouble() : 0.0,
      deliveryFee: json['deliveryFee'] != null ? (json['deliveryFee'] as num).toDouble() : 250.0,
      totalAmount: json['totalAmount'] != null ? (json['totalAmount'] as num).toDouble() : 0.0,
      status: json['status'] ?? 'PROCESSING',
      paymentMethod: json['paymentMethod'] ?? 'CARD',
      paymentStatus: json['paymentStatus'] ?? 'PAID',
      deliveryAddress: json['deliveryAddress'] ?? 'No. 123, Galle Road, Colombo 04',
      customerName: json['customerName'] ?? 'Kasun Perera',
      customerPhone: json['customerPhone'] ?? '+94 77 123 4567',
      estimatedDelivery: json['estimatedDelivery'] ?? 'Tomorrow, 13 Oct 2026 (9:00 AM - 5:00 PM)',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}

class PrescriptionScanModel {
  final int id;
  final String prescriptionCode;
  final String imageUrl;
  final String? extractedText;
  final String? extractedMedicinesJson;
  final String status;
  final int aiDetectedCount;
  final double? totalPrice;
  final String? pharmacistNotes;
  final DateTime createdAt;

  PrescriptionScanModel({
    required this.id,
    required this.prescriptionCode,
    required this.imageUrl,
    this.extractedText,
    this.extractedMedicinesJson,
    required this.status,
    required this.aiDetectedCount,
    this.totalPrice,
    this.pharmacistNotes,
    required this.createdAt,
  });

  factory PrescriptionScanModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionScanModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      prescriptionCode: json['prescriptionCode'] ?? 'EP${1000 + (json['id'] is int ? json['id'] as int : 0)}',
      imageUrl: json['imageUrl'] ?? 'prescription.jpg',
      extractedText: json['extractedText'],
      extractedMedicinesJson: json['extractedMedicinesJson']?.toString(),
      status: json['status'] ?? 'PENDING',
      aiDetectedCount: json['aiDetectedCount'] is int ? json['aiDetectedCount'] : 0,
      totalPrice: json['totalPrice'] != null ? (json['totalPrice'] as num).toDouble() : null,
      pharmacistNotes: json['pharmacistNotes'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'ORDER',
      isRead: json['isRead'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}
