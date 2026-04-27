// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../models/app_data.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final data = AppData();
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  void showAddEdit({MenuItem? item}) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final priceCtrl = TextEditingController(
        text: item != null ? item.price.toInt().toString() : '');
    final catCtrl = TextEditingController(text: item?.category ?? 'Makanan');

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
            Text(item == null ? 'Tambah Menu' : 'Edit Menu',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Menu')),
            const SizedBox(height: 8),
            TextField(controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Harga', prefixText: 'Rp ')),
            const SizedBox(height: 8),
            TextField(controller: catCtrl,
                decoration: const InputDecoration(
                    labelText: 'Kategori',
                    hintText: 'Makanan / Minuman / dll')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                  setState(() {
                    if (item == null) {
                      data.menuItems.add(MenuItem(
                        id: const Uuid().v4(),
                        name: nameCtrl.text,
                        price: double.tryParse(priceCtrl.text) ?? 0,
                        category: catCtrl.text.isEmpty ? 'Lainnya' : catCtrl.text,
                      ));
                    } else {
                      item.name = nameCtrl.text;
                      item.price = double.tryParse(priceCtrl.text) ?? 0;
                      item.category = catCtrl.text.isEmpty ? 'Lainnya' : catCtrl.text;
                    }
                    data.saveMenu();
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

  void deleteItem(MenuItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Menu?'),
        content: Text('Hapus ${item.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              setState(() {
                data.menuItems.remove(item);
                data.saveMenu();
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
    final grouped = <String, List<MenuItem>>{};
    for (final m in data.menuItems) {
      grouped.putIfAbsent(m.category, () => []).add(m);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Menu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: data.menuItems.isEmpty
          ? const Center(child: Text('Belum ada menu'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(entry.key,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue)),
                    ),
                    ...entry.value.map((m) => Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: Text(m.name,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(fmt.format(m.price)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    onPressed: () => showAddEdit(item: m)),
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 18, color: Colors.red),
                                    onPressed: () => deleteItem(m)),
                              ],
                            ),
                          ),
                        )),
                  ],
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEdit(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
