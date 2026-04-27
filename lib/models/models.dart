// lib/models/models.dart
import 'dart:convert';

class MenuItem {
  final String id;
  String name;
  double price;
  String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'price': price, 'category': category};

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
        id: j['id'],
        name: j['name'],
        price: j['price'].toDouble(),
        category: j['category'],
      );
}

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});

  double get subtotal => menuItem.price * quantity;
}

class Transaction {
  final String id;
  final DateTime date;
  final List<Map<String, dynamic>> items;
  final double total;
  final double bayar;
  final double kembalian;
  final String paymentMethod;

  Transaction({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.bayar,
    required this.kembalian,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items,
        'total': total,
        'bayar': bayar,
        'kembalian': kembalian,
        'paymentMethod': paymentMethod,
      };

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id'],
        date: DateTime.parse(j['date']),
        items: List<Map<String, dynamic>>.from(j['items']),
        total: j['total'].toDouble(),
        bayar: j['bayar'].toDouble(),
        kembalian: j['kembalian'].toDouble(),
        paymentMethod: j['paymentMethod'],
      );
}

class StockItem {
  final String id;
  String name;
  double qty;
  String unit;
  double minQty;

  StockItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.unit,
    required this.minQty,
  });

  String get status {
    if (qty <= 0) return 'habis';
    if (qty <= minQty) return 'menipis';
    return 'aman';
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'qty': qty, 'unit': unit, 'minQty': minQty};

  factory StockItem.fromJson(Map<String, dynamic> j) => StockItem(
        id: j['id'],
        name: j['name'],
        qty: j['qty'].toDouble(),
        unit: j['unit'],
        minQty: j['minQty'].toDouble(),
      );
}

class HutangItem {
  final String id;
  String nama;
  double jumlah;
  String tipe; // 'hutang' atau 'piutang'
  String keterangan;
  DateTime tanggal;
  bool lunas;

  HutangItem({
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.tipe,
    required this.keterangan,
    required this.tanggal,
    this.lunas = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'jumlah': jumlah,
        'tipe': tipe,
        'keterangan': keterangan,
        'tanggal': tanggal.toIso8601String(),
        'lunas': lunas,
      };

  factory HutangItem.fromJson(Map<String, dynamic> j) => HutangItem(
        id: j['id'],
        nama: j['nama'],
        jumlah: j['jumlah'].toDouble(),
        tipe: j['tipe'],
        keterangan: j['keterangan'],
        tanggal: DateTime.parse(j['tanggal']),
        lunas: j['lunas'] ?? false,
      );
}
