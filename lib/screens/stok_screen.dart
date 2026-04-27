// lib/screens/stok_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../models/app_data.dart';

class StokScreen extends StatefulWidget {
  const StokScreen({super.key});
  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> {
  final data = AppData();

  Color statusColor(String status) {
    switch (status) {
      case 'habis': return Colors.red;
      case 'menipis': return Colors.orange;
      default: return Colors.green;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'habis': return 'Habis';
      case 'menipis': return 'Menipis';
      default: return 'Aman';
    }
  }

  void showAddEdit({StockItem? item}) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final qtyCtrl = TextEditingController(text: item?.qty.toString() ?? '');
    final unitCtrl = TextEditingController(text: item?.unit ?? '');
    final minCtrl = TextEditingController(text: item?.minQty.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item == null ? 'Tambah Stok' : 'Edit Stok',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Bahan')),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Jumlah'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: unitCtrl,
                  decoration: const InputDecoration(labelText: 'Satuan (kg, liter...)'))),
            ]),
            const SizedBox(height: 8),
            TextField(controller: minCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Minimum Stok')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isEmpty) return;
                  setState(() {
                    if (item == null) {
                      data.stockItems.add(StockItem(
                        id: const Uuid().v4(),
                        name: nameCtrl.text,
                        qty: double.tryParse(qtyCtrl.text) ?? 0,
                        unit: unitCtrl.text,
                        minQty: double.tryParse(minCtrl.text) ?? 0,
                      ));
                    } else {
                      item.name = nameCtrl.text;
                      item.qty = double.tryParse(qtyCtrl.text) ?? 0;
                      item.unit = unitCtrl.text;
                      item.minQty = double.tryParse(minCtrl.text) ?? 0;
                    }
                    data.saveStock();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void deleteItem(StockItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Stok?'),
        content: Text('Hapus ${item.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              setState(() {
                data.stockItems.remove(item);
                data.saveStock();
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menipis = data.stockItems.where((s) => s.status != 'aman').length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Bahan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (menipis > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.orange.shade50,
              child: Text(
                '⚠️  $menipis bahan perlu diperhatikan!',
                style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
              ),
            ),
          Expanded(
            child: data.stockItems.isEmpty
                ? const Center(child: Text('Belum ada data stok'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: data.stockItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final s = data.stockItems[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        title: Text(s.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${s.qty} ${s.unit} • Min: ${s.minQty} ${s.unit}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor(s.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(statusLabel(s.status),
                                  style: TextStyle(
                                      color: statusColor(s.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () => showAddEdit(item: s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                              onPressed: () => deleteItem(s),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEdit(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
