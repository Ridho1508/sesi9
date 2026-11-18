import 'package:flutter/foundation.dart';

import '../../data/repositories/transaksi_repository.dart';
import '../../domain/kas_calculator.dart';
import '../../domain/models/transaksi.dart';

class KasViewModel extends ChangeNotifier {
  KasViewModel({
    TransaksiRepository? repository,
    KasCalculator calculator = const KasCalculator(),
  })  : _repository = repository ?? TransaksiRepository(),
        _calculator = calculator;

  final TransaksiRepository _repository;
  final KasCalculator _calculator;

  List<Transaksi> get daftarTransaksi => _repository.semua();
  int get saldo => _calculator.hitungSaldo(daftarTransaksi);
  int get totalPemasukan => _calculator.totalPemasukan(daftarTransaksi);
  int get totalPengeluaran => _calculator.totalPengeluaran(daftarTransaksi);

  String? validasiNominal(int nominal, JenisTransaksi jenis) =>
      _calculator.validasiTransaksi(daftarTransaksi, nominal, jenis);

  /// Mengembalikan pesan error, atau null jika berhasil disimpan.
  String? tambahTransaksi({
    required String keterangan,
    required int nominal,
    required JenisTransaksi jenis,
    DateTime? tanggal,
  }) {
    final error = validasiNominal(nominal, jenis);
    if (error != null) return error;

    final sekarang = tanggal ?? DateTime.now();
    _repository.tambah(Transaksi(
      id: sekarang.microsecondsSinceEpoch.toString(),
      keterangan: keterangan.trim(),
      nominal: nominal,
      jenis: jenis,
      tanggal: sekarang,
    ));
    notifyListeners();
    return null;
  }

  /// Transaksi tidak boleh dihapus jika saldo akhir menjadi negatif.
  bool bisaHapus(String id) {
    final sisa = daftarTransaksi.where((t) => t.id != id).toList();
    return _calculator.hitungSaldo(sisa) >= 0;
  }

  void hapusTransaksi(String id) {
    _repository.hapus(id);
    notifyListeners();
  }
}
