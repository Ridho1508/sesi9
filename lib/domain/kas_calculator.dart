import 'models/transaksi.dart';

/// Logika hitung kas, terpisah dari widget.
class KasCalculator {
  const KasCalculator();

  int totalPemasukan(List<Transaksi> daftar) => daftar
      .where((t) => t.jenis == JenisTransaksi.pemasukan)
      .fold(0, (jumlah, t) => jumlah + t.nominal);

  int totalPengeluaran(List<Transaksi> daftar) => daftar
      .where((t) => t.jenis == JenisTransaksi.pengeluaran)
      .fold(0, (jumlah, t) => jumlah + t.nominal);

  int hitungSaldo(List<Transaksi> daftar) =>
      totalPemasukan(daftar) - totalPengeluaran(daftar);

  /// Mengembalikan pesan error, atau null jika transaksi valid.
  String? validasiTransaksi(
    List<Transaksi> daftar,
    int nominal,
    JenisTransaksi jenis,
  ) {
    if (nominal <= 0) return 'Nominal harus lebih dari 0';
    if (jenis == JenisTransaksi.pengeluaran &&
        nominal > hitungSaldo(daftar)) {
      return 'Pengeluaran melebihi saldo';
    }
    return null;
  }
}
