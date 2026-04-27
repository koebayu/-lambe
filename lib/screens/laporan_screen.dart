// lib/screens/laporan_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_data.dart';
import '../models/models.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});
  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final data = AppData();
  String periode = 'Hari Ini';
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final fmtDate = DateFormat('dd/MM/yyyy HH:mm');

  List<Transaction> get filtered {
    final now = DateTime.now();
    switch (periode) {
      case 'Hari Ini':
        return data.transactions
            .where((t) =>
                t.date.year == now.year &&
                t.date.month == now.month &&
                t.date.day == now.day)
            .toList();
      case 'Minggu Ini':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return data.transactions
            .where((t) => t.date.isAfter(
                DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)))
            .toList();
      case 'Bulan Ini':
        return data.transactions
            .where(
                (t) => t.date.year == now.year && t.date.month == now.month)
            .toList();
      default:
        return data.transactions;
    }
  }

  double get totalPendapatan => filtered.fold(0, (s, t) => s + t.total);
  int get jumlahTransaksi => filtered.length;

  Map<String, double> get topMenu {
    final map = <String, double>{};
    for (final tx in filtered) {
      for (final item in tx.items) {
        final name = item['name'] as String;
        final qty = (item['qty'] as int).toDouble();
        map[name] = (map[name] ?? 0) + qty;
      }
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Periode selector
            Row(
              children: ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Semua']
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(p, style: const TextStyle(fontSize: 12)),
                          selected: periode == p,
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                              color: periode == p ? Colors.white : Colors.black87),
                          onSelected: (_) => setState(() => periode = p),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),

            // Summary cards
            Row(children: [
              _MetricCard(
                label: 'Total Pendapatan',
                value: fmt.format(totalPendapatan),
                color: Colors.blue,
                icon: Icons.trending_up,
              ),
              const SizedBox(width: 10),
              _MetricCard(
                label: 'Transaksi',
                value: '$jumlahTransaksi',
                color: Colors.green,
                icon: Icons.receipt,
              ),
            ]),
            const SizedBox(height: 12),

            // Top menu
            if (topMenu.isNotEmpty) ...[
              const Text('Menu Terlaris',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: topMenu.entries.map((e) {
                    final max = topMenu.values.first;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: const TextStyle(fontSize: 13)),
                              Text('${e.value.toInt()} porsi',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: e.value / max,
                            backgroundColor: Colors.grey.shade100,
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Transaction history
            const Text('Riwayat Transaksi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Text('Belum ada transaksi',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              ...filtered.reversed.map((tx) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ExpansionTile(
                      title: Text(fmt.format(tx.total),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                          '${fmtDate.format(tx.date)} • ${tx.paymentMethod}',
                          style: const TextStyle(fontSize: 11)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            children: tx.items
                                .map((item) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            '${item['name']} x${item['qty']}',
                                            style: const TextStyle(fontSize: 13)),
                                        Text(
                                            fmt.format(item['subtotal']),
                                            style: const TextStyle(fontSize: 13)),
                                      ],
                                    ))
                                .toList(),
                          ),
                        )
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
