enum JenisTransaksi {
  pemasukan('Pemasukan'),
  pengeluaran('Pengeluaran');

  const JenisTransaksi(this.label);
  final String label;
}

class Transaksi {
  const Transaksi({
    required this.id,
    required this.keterangan,
    required this.nominal,
    required this.jenis,
    required this.tanggal,
  });

  final String id;
  final String keterangan;
  final int nominal; // dalam rupiah
  final JenisTransaksi jenis;
  final DateTime tanggal;
}
