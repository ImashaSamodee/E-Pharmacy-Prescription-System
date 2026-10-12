import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal() {
    _initializeDefaultState();
  }

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  List<CartItemModel> _cartItems = [];
  List<CartItemModel> get cartItems => _cartItems;

  int _unreadNotifications = 3;
  int get unreadNotifications => _unreadNotifications;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  void _initializeDefaultState() {
    // Default logged in user Kasun Perera matching screenshots
    _currentUser = UserModel(
      id: 2,
      name: 'Kasun Perera',
      email: 'kasun@email.com',
      role: 'PATIENT',
      phone: '+94 77 123 4567',
      address: 'No. 123, Galle Road, Colombo 04, Colombo',
    );

    // Initial default cart matching Screen 4 & Screen 5
    _cartItems = [
      CartItemModel(
        medicineId: 1,
        name: 'Panadol 500mg',
        dosage: 'Paracetamol\nQty: 1 strip (10 tablets)',
        price: 120.0,
        quantity: 1,
        isSelected: true,
        confidence: '96%',
      ),
      CartItemModel(
        medicineId: 5,
        name: 'Amoxicillin 500mg',
        dosage: 'Antibiotic\nQty: 1 strip (10 capsules)',
        price: 280.0,
        quantity: 1,
        isSelected: true,
        confidence: '95%',
      ),
      CartItemModel(
        medicineId: 3,
        name: 'Vitamin C 1000mg',
        dosage: 'Supplement\nQty: 1 strip (10 tablets)',
        price: 450.0,
        quantity: 1,
        isSelected: true,
        confidence: '94%',
      ),
      CartItemModel(
        medicineId: 6,
        name: 'Cetirizine 10mg',
        dosage: 'Allergy Relief\nQty: 1 strip (10 tablets)',
        price: 180.0,
        quantity: 1,
        isSelected: true,
        confidence: '92%',
      ),
    ];
  }

  void setUser(UserModel user) {
    _currentUser = user;
    ApiService().setToken(user.token);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    ApiService().setToken(null);
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setUnreadNotifications(int count) {
    _unreadNotifications = count;
    notifyListeners();
  }

  void addToCart(MedicineModel med) {
    final existingIndex = _cartItems.indexWhere((it) => it.medicineId == med.id || it.name == med.name);
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItemModel(
        medicineId: med.id,
        name: med.name,
        dosage: med.genericName != null ? '${med.genericName!}\nQty: ${med.dosageForm ?? "1 strip"}' : (med.dosageForm ?? '1 strip'),
        price: med.price,
        quantity: 1,
        isSelected: true,
        confidence: med.confidence,
      ));
    }
    notifyListeners();
  }

  void addCartItem(CartItemModel item) {
    final existingIndex = _cartItems.indexWhere((it) => it.name.toLowerCase() == item.name.toLowerCase());
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += item.quantity;
      _cartItems[existingIndex].isSelected = true;
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void setExtractedCartItems(List<CartItemModel> items) {
    _cartItems = items;
    notifyListeners();
  }

  void updateQuantity(CartItemModel item, int delta) {
    item.quantity += delta;
    if (item.quantity <= 0) {
      _cartItems.remove(item);
    }
    notifyListeners();
  }

  void toggleItemSelection(CartItemModel item) {
    item.isSelected = !item.isSelected;
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double get subtotal {
    return _cartItems
        .where((it) => it.isSelected)
        .fold(0.0, (sum, it) => sum + it.totalPrice);
  }

  double get deliveryFee => _cartItems.isEmpty ? 0.0 : 250.0;

  double get totalAmount => subtotal + deliveryFee;

  int get selectedItemsCount => _cartItems.where((it) => it.isSelected).length;
}
