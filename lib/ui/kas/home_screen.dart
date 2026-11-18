import 'package:flutter/material.dart';

import '../../domain/models/transaksi.dart';
import 'kas_view_model.dart';
import 'tambah_transaksi_screen.dart';

/// Palet warna dari desain Stitch (NusaKas Ledger System).
class KasWarna {
  KasWarna._();
  static const primary = Color(0xFF00796B);
  static const primaryDark = Color(0xFF005E53);
  static const onPrimaryContainer = Color(0xFFA1FEEC);
  static const pemasukan = Color(0xFF2E7D32);
  static const pemasukanTeks = Color(0xFF1B5E20);
  static const pemasukanBg = Color(0xFFDDF7D9);
  static const pengeluaran = Color(0xFFD32F2F);
  static const pengeluaranTeks = Color(0xFFB71C1C);
  static const pengeluaranBg = Color(0xFFFCE4E2);
  static const latar = Color(0xFFF8FAF9);
  static const teks = Color(0xFF191C1C);
  static const teksSekunder = Color(0xFF3E4946);
  static const garis = Color(0xFFBDC9C5);
  static const abuAbu = Color(0xFFEEF0EF);
}

String formatRupiah(int nilai) {
  final digits = nilai.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${nilai < 0 ? '-' : ''}Rp $buffer';
}

String _formatTanggal(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

const _bayangan = [
  BoxShadow(color: Color(0x0F00796B), blurRadius: 8, offset: Offset(0, 2)),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final KasViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final daftar = viewModel.daftarTransaksi;
        return Scaffold(
          backgroundColor: KasWarna.latar,
          appBar: AppBar(
            toolbarHeight: 64,
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: KasWarna.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('NusaKas',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.2)),
                    Text('Buku Kas',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: KasWarna.teksSekunder)),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('tambahFab'),
            backgroundColor: KasWarna.primaryDark,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TambahTransaksiScreen(viewModel: viewModel),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          body: ListView.builder(
            key: const Key('daftarTransaksi'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: daftar.isEmpty ? 2 : daftar.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) return _Header(viewModel: viewModel);
              if (daftar.isEmpty) return const _KeadaanKosong();
              return _itemTransaksi(context, daftar[i - 1]);
            },
          ),
        );
      },
    );
  }

  Widget _itemTransaksi(BuildContext context, Transaksi t) {
    final masuk = t.jenis == JenisTransaksi.pemasukan;
    final warna = masuk ? KasWarna.pemasukanTeks : KasWarna.pengeluaranTeks;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(t.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: KasWarna.pengeluaranTeks,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: Colors.white),
              SizedBox(height: 2),
              Text('HAPUS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          if (!viewModel.bisaHapus(t.id)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Tidak bisa dihapus: saldo akan menjadi negatif'),
              ),
            );
            return false;
          }
          return true;
        },
        onDismissed: (_) {
          viewModel.hapusTransaksi(t.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${t.keterangan}" dihapus')),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _bayangan,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      masuk ? KasWarna.pemasukanBg : KasWarna.pengeluaranBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(masuk ? Icons.south_west : Icons.north_east,
                    color: warna),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.keterangan,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(_formatTanggal(t.tanggal),
                        style: const TextStyle(
                            fontSize: 12, color: KasWarna.teksSekunder)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${masuk ? '+' : '-'} ${formatRupiah(t.nominal)}',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: warna),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.viewModel});

  final KasViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final daftar = viewModel.daftarTransaksi;
    final jumlahMasuk =
        daftar.where((t) => t.jenis == JenisTransaksi.pemasukan).length;
    final jumlahKeluar = daftar.length - jumlahMasuk;
    final sekarang = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [KasWarna.primary, KasWarna.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3800796B),
                  blurRadius: 20,
                  offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saldo Kas Aktif',
                      style: TextStyle(
                          color: KasWarna.onPrimaryContainer, fontSize: 14)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x26FFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('Himpunan Mahasiswa',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatRupiah(viewModel.saldo),
                key: const Key('saldoText'),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.event,
                      size: 14, color: KasWarna.onPrimaryContainer),
                  const SizedBox(width: 4),
                  Text('Periode ${_bulan[sekarang.month - 1]} ${sekarang.year}',
                      style: const TextStyle(
                          color: KasWarna.onPrimaryContainer, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _KotakTotal(
                judul: 'Pemasukan',
                nilai: formatRupiah(viewModel.totalPemasukan),
                jumlah: jumlahMasuk,
                keyTeks: const Key('pemasukanText'),
                warnaTeks: KasWarna.pemasukanTeks,
                latar: KasWarna.pemasukanBg,
                warnaIkon: KasWarna.pemasukanTeks,
                ikon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KotakTotal(
                judul: 'Pengeluaran',
                nilai: formatRupiah(viewModel.totalPengeluaran),
                jumlah: jumlahKeluar,
                keyTeks: const Key('pengeluaranText'),
                warnaTeks: KasWarna.pengeluaranTeks,
                latar: KasWarna.pengeluaranBg,
                warnaIkon: KasWarna.pengeluaranTeks,
                ikon: Icons.arrow_upward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text('Riwayat Transaksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: KasWarna.abuAbu,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('${daftar.length}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        if (daftar.isNotEmpty) ...[
          const SizedBox(height: 4),
          const Text('Geser transaksi ke kiri untuk menghapus',
              style: TextStyle(fontSize: 12, color: KasWarna.teksSekunder)),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _KotakTotal extends StatelessWidget {
  const _KotakTotal({
    required this.judul,
    required this.nilai,
    required this.jumlah,
    required this.keyTeks,
    required this.warnaTeks,
    required this.latar,
    required this.warnaIkon,
    required this.ikon,
  });

  final String judul;
  final String nilai;
  final int jumlah;
  final Key keyTeks;
  final Color warnaTeks;
  final Color latar;
  final Color warnaIkon;
  final IconData ikon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration:
                    BoxDecoration(color: warnaIkon, shape: BoxShape.circle),
                child: Icon(ikon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(judul,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: warnaTeks)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(nilai,
                key: keyTeks,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: warnaTeks)),
          ),
          const SizedBox(height: 2),
          Text('$jumlah transaksi',
              style: TextStyle(fontSize: 12, color: warnaTeks)),
        ],
      ),
    );
  }
}

class _KeadaanKosong extends StatelessWidget {
  const _KeadaanKosong();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _bayangan,
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFD5F5EE),
            child: Icon(Icons.receipt_long_outlined,
                size: 40, color: KasWarna.primaryDark),
          ),
          SizedBox(height: 16),
          Text('Belum ada transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text(
            'Catatan kas himpunan Anda masih kosong. Tekan tombol Tambah '
            'untuk mencatat pemasukan atau pengeluaran pertama.',
            textAlign: TextAlign.center,
            style: TextStyle(color: KasWarna.teksSekunder, height: 1.4),
          ),
        ],
      ),
    );
  }
}
