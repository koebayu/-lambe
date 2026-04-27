// lib/screens/hutang_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../models/app_data.dart';

class HutangScreen extends StatefulWidget {
  const HutangScreen({super.key});
  @override
  State<HutangScreen> createState() => _HutangScreenState();
}

class _HutangScreenState extends State<HutangScreen> {
  final data = AppData();
  String filter = 'Semua';
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final fmtDate = DateFormat('dd/MM/yyyy');

  List<HutangItem> get filtered {
    switch (filter) {
      case 'Hutang': return data.hutangItems.where((h) => h.tipe == 'hutang').toList();
      case 'Piutang': return data.hutangItems.where((h) => h.tipe == 'piutang').toList();
      case 'Lunas': return data.hutangItems.where((h) => h.lunas).toList();
      default: return data.hutangItems;
    }
  }

  void showAddDialog() {
    final namaCtrl = TextEditingController();
    final jumlahCtrl = TextEditingController();
    final ketCtrl = TextEditingController();
    String tipe = 'hutang';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(
        builder: (_, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16, right: 16, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tambah Hutang / Piutang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Tipe: '),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: const Text('Hutang (kita berhutang)'),
                    selected: tipe == 'hutang',
                    selectedColor: Colors.red.shade100,
                    onSelected: (_) => setModal(() => tipe = 'hutang')),
                const SizedBox(width: 6),
                ChoiceChip(
                    label: const Text('Piutang (orang berhutang ke kita)'),
                    selected: tipe == 'piutang',
                    selectedColor: Colors.green.shade100,
                    onSelected: (_) => setModal(() => tipe = 'piutang')),
              ]),
              const SizedBox(height: 10),
              TextField(controller: namaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama')),
              const SizedBox(height: 8),
              TextField(controller: jumlahCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Jumlah', prefixText: 'Rp ')),
              const SizedBox(height: 8),
              TextField(controller: ketCtrl,
                  decoration: const InputDecoration(labelText: 'Keterangan')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (namaCtrl.text.isEmpty || jumlahCtrl.text.isEmpty) return;
                    setState(() {
                      data.hutangItems.add(HutangItem(
                        id: const Uuid().v4(),
                        nama: namaCtrl.text,
                        jumlah: double.tryParse(jumlahCtrl.text) ?? 0,
                        tipe: tipe,
                        keterangan: ketCtrl.text,
                        tanggal: DateTime.now(),
                      ));
                      data.saveHutang();
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hutang & Piutang'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade50,
            child: Row(children: [
              Expanded(child: _SummaryTile(
                  label: 'Total Hutang',
                  value: fmt.format(data.totalHutang),
                  color: Colors.red)),
              const SizedBox(width: 10),
              Expanded(child: _SummaryTile(
                  label: 'Total Piutang',
                  value: fmt.format(data.totalPiutang),
                  color: Colors.green)),
            ]),
          ),
          // Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: ['Semua', 'Hutang', 'Piutang', 'Lunas']
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f, style: const TextStyle(fontSize: 12)),
                          selected: filter == f,
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                              color: filter == f ? Colors.white : Colors.black87),
                          onSelected: (_) => setState(() => filter = f),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // List
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Tidak ada data'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final h = filtered[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: h.tipe == 'hutang'
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            child: Text(
                              h.nama[0].toUpperCase(),
                              style: TextStyle(
                                  color: h.tipe == 'hutang'
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Row(children: [
                            Text(h.nama,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration: h.lunas
                                        ? TextDecoration.lineThrough
                                        : null)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: h.tipe == 'hutang'
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                h.tipe == 'hutang' ? 'Hutang' : 'Piutang',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: h.tipe == 'hutang'
                                        ? Colors.red
                                        : Colors.green),
                              ),
                            ),
                          ]),
                          subtitle: Text(
                              '${h.keterangan.isNotEmpty ? h.keterangan : "-"} • ${fmtDate.format(h.tanggal)}',
                              style: const TextStyle(fontSize: 11)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(fmt.format(h.jumlah),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: h.tipe == 'hutang'
                                          ? Colors.red
                                          : Colors.green)),
                              if (!h.lunas)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      h.lunas = true;
                                      data.saveHutang();
                                    });
                                  },
                                  child: const Text('Tandai Lunas',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.blue)),
                                )
                              else
                                const Text('Lunas',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
