// lib/models/app_data.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppData {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  List<MenuItem> menuItems = [];
  List<Transaction> transactions = [];
  List<StockItem> stockItems = [];
  List<HutangItem> hutangItems = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final menuJson = prefs.getString('menuItems');
    if (menuJson != null) {
      menuItems = (jsonDecode(menuJson) as List)
          .map((e) => MenuItem.fromJson(e))
          .toList();
    } else {
      _loadDefaultMenu();
    }

    final txJson = prefs.getString('transactions');
    if (txJson != null) {
      transactions = (jsonDecode(txJson) as List)
          .map((e) => Transaction.fromJson(e))
          .toList();
    }

    final stockJson = prefs.getString('stockItems');
    if (stockJson != null) {
      stockItems = (jsonDecode(stockJson) as List)
          .map((e) => StockItem.fromJson(e))
          .toList();
    } else {
      _loadDefaultStock();
    }

    final hutangJson = prefs.getString('hutangItems');
    if (hutangJson != null) {
      hutangItems = (jsonDecode(hutangJson) as List)
          .map((e) => HutangItem.fromJson(e))
          .toList();
    }
  }

  void _loadDefaultMenu() {
    menuItems = [
      MenuItem(id: '1', name: 'Nasi Goreng', price: 15000, category: 'Makanan'),
      MenuItem(id: '2', name: 'Mie Goreng', price: 13000, category: 'Makanan'),
      MenuItem(id: '3', name: 'Ayam Bakar', price: 20000, category: 'Makanan'),
      MenuItem(id: '4', name: 'Soto Ayam', price: 12000, category: 'Makanan'),
      MenuItem(id: '5', name: 'Es Teh', price: 5000, category: 'Minuman'),
      MenuItem(id: '6', name: 'Es Jeruk', price: 6000, category: 'Minuman'),
      MenuItem(id: '7', name: 'Kopi Hitam', price: 5000, category: 'Minuman'),
      MenuItem(id: '8', name: 'Air Mineral', price: 3000, category: 'Minuman'),
    ];
  }

  void _loadDefaultStock() {
    stockItems = [
      StockItem(id: '1', name: 'Beras', qty: 25, unit: 'kg', minQty: 5),
      StockItem(id: '2', name: 'Minyak Goreng', qty: 3, unit: 'liter', minQty: 2),
      StockItem(id: '3', name: 'Ayam', qty: 10, unit: 'kg', minQty: 3),
      StockItem(id: '4', name: 'Telur', qty: 2, unit: 'kg', minQty: 1),
      StockItem(id: '5', name: 'Gas LPG', qty: 1, unit: 'tabung', minQty: 1),
    ];
  }

  Future<void> saveMenu() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'menuItems', jsonEncode(menuItems.map((e) => e.toJson()).toList()));
  }

  Future<void> saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions',
        jsonEncode(transactions.map((e) => e.toJson()).toList()));
  }

  Future<void> saveStock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'stockItems', jsonEncode(stockItems.map((e) => e.toJson()).toList()));
  }

  Future<void> saveHutang() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'hutangItems', jsonEncode(hutangItems.map((e) => e.toJson()).toList()));
  }

  double get totalPenjualanHari {
    final today = DateTime.now();
    return transactions
        .where((t) =>
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day)
        .fold(0.0, (sum, t) => sum + t.total);
  }

  int get jumlahTransaksiHari {
    final today = DateTime.now();
    return transactions
        .where((t) =>
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day)
        .length;
  }

  double get totalHutang => hutangItems
      .where((h) => h.tipe == 'hutang' && !h.lunas)
      .fold(0.0, (s, h) => s + h.jumlah);

  double get totalPiutang => hutangItems
      .where((h) => h.tipe == 'piutang' && !h.lunas)
      .fold(0.0, (s, h) => s + h.jumlah);
}
