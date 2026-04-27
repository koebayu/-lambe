// lib/screens/kasir_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../models/app_data.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});
  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  final data = AppData();
  final List<CartItem> cart = [];
  String selectedCategory = 'Semua';
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  List<String> get categories {
    final cats = data.menuItems.map((e) => e.category).toSet().toList();
    return ['Semua', ...cats];
  }

  List<MenuItem> get filteredMenu => selectedCategory == 'Semua'
      ? data.menuItems
      : data.menuItems.where((m) => m.category == selectedCategory).toList();

  double get subtotal => cart.fold(0, (s, c) => s + c.subtotal);
  double get pajak => subtotal * 0.0;
  double get total => subtotal + pajak;

  void addToCart(MenuItem item) {
    setState(() {
      final idx = cart.indexWhere((c) => c.menuItem.id == item.id);
      if (idx >= 0) {
        cart[idx].quantity++;
      } else {
        cart.add(CartItem(menuItem: item));
      }
    });
  }

  void removeFromCart(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        cart.remove(item);
      }
    });
  }

  void clearCart() => setState(() => cart.clear());

  void showCheckout() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong!')),
      );
      return;
    }
    final bayarCtrl = TextEditingController();
    String paymentMethod = 'Tunai';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16, right: 16, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pembayaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(children: [
                const Text('Total: ', style: TextStyle(fontSize: 15)),
                Text(fmt.format(total),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Metode: '),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: const Text('Tunai'),
                    selected: paymentMethod == 'Tunai',
                    onSelected: (_) => setModal(() => paymentMethod = 'Tunai')),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: const Text('Transfer'),
                    selected: paymentMethod == 'Transfer',
                    onSelected: (_) =>
                        setModal(() => paymentMethod = 'Transfer')),
              ]),
              if (paymentMethod == 'Tunai') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: bayarCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Jumlah Bayar', prefixText: 'Rp '),
                  onChanged: (_) => setModal(() {}),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kembalian: ${fmt.format((double.tryParse(bayarCtrl.text.replaceAll('.', '')) ?? 0) - total)}',
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _processPayment(paymentMethod, bayarCtrl.text),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Proses Pembayaran',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment(String method, String bayarStr) {
    final bayar = method == 'Tunai'
        ? (double.tryParse(bayarStr.replaceAll('.', '')) ?? total)
        : total;
    final kembalian = bayar - total;

    final tx = Transaction(
      id: const Uuid().v4(),
      date: DateTime.now(),
      items: cart
          .map((c) => {
                'name': c.menuItem.name,
                'price': c.menuItem.price,
                'qty': c.quantity,
                'subtotal': c.subtotal,
              })
          .toList(),
      total: total,
      bayar: bayar,
      kembalian: kembalian,
      paymentMethod: method,
    );

    data.transactions.add(tx);
    data.saveTransactions();
    clearCart();
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Transaksi Berhasil!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: ${fmt.format(total)}'),
            if (method == 'Tunai') Text('Kembalian: ${fmt.format(kembalian)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: clearCart,
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            )
        ],
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final selected = cat == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: selected ? Colors.blue : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(cat,
                          style: TextStyle(
                              fontSize: 13,
                              color: selected ? Colors.white : Colors.black87,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                    ),
                  ),
                );
              },
            ),
          ),
          // Menu grid
          Expanded(
            flex: 3,
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredMenu.length,
              itemBuilder: (_, i) {
                final item = filteredMenu[i];
                final inCart = cart.where((c) => c.menuItem.id == item.id);
                final qty = inCart.isEmpty ? 0 : inCart.first.quantity;
                return GestureDetector(
                  onTap: () => addToCart(item),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: qty > 0 ? Colors.blue.shade50 : Colors.white,
                      border: Border.all(
                          color: qty > 0 ? Colors.blue : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(fmt.format(item.price),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.blue)),
                            if (qty > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text('$qty',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Cart
          if (cart.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: cart.length,
                      itemBuilder: (_, i) {
                        final c = cart[i];
                        return Row(
                          children: [
                            Expanded(
                                child: Text(c.menuItem.name,
                                    style: const TextStyle(fontSize: 13))),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 20),
                              onPressed: () => removeFromCart(c),
                            ),
                            Text('${c.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () => setState(() => c.quantity++),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(fmt.format(c.subtotal),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      children: [
                        Text('Total: ${fmt.format(total)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: showCheckout,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text('Bayar',
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
