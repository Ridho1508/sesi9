import 'package:flutter_test/flutter_test.dart';
import 'package:nusa_kas/domain/kas_calculator.dart';
import 'package:nusa_kas/domain/models/transaksi.dart';

Transaksi _trx(int nominal, JenisTransaksi jenis) => Transaksi(
      id: '$nominal-${jenis.name}',
      keterangan: 'Uji',
      nominal: nominal,
      jenis: jenis,
      tanggal: DateTime(2026, 11, 18),
    );

void main() {
  const calc = KasCalculator();

  group('daftar kosong', () {
    test('saldo = 0', () => expect(calc.hitungSaldo([]), 0));
    test('total pemasukan = 0', () => expect(calc.totalPemasukan([]), 0));
    test('total pengeluaran = 0', () => expect(calc.totalPengeluaran([]), 0));
  });

  group('perhitungan', () {
    final daftar = [
      _trx(100000, JenisTransaksi.pemasukan),
      _trx(50000, JenisTransaksi.pemasukan),
      _trx(30000, JenisTransaksi.pengeluaran),
    ];

    test('totalPemasukan hanya menjumlah pemasukan', () {
      expect(calc.totalPemasukan(daftar), 150000);
    });

    test('totalPengeluaran hanya menjumlah pengeluaran', () {
      expect(calc.totalPengeluaran(daftar), 30000);
    });

    test('hitungSaldo = pemasukan - pengeluaran', () {
      expect(calc.hitungSaldo(daftar), 120000);
    });
  });

  group('validasi', () {
    final daftar = [_trx(100000, JenisTransaksi.pemasukan)];

    test('nominal nol ditolak', () {
      expect(calc.validasiTransaksi(daftar, 0, JenisTransaksi.pemasukan),
          isNotNull);
    });

    test('nominal negatif ditolak', () {
      expect(calc.validasiTransaksi(daftar, -500, JenisTransaksi.pemasukan),
          isNotNull);
    });

    test('pengeluaran tepat sama dengan saldo diterima (nilai batas)', () {
      expect(calc.validasiTransaksi(daftar, 100000, JenisTransaksi.pengeluaran),
          isNull);
    });

    test('pengeluaran lebih 1 rupiah dari saldo ditolak', () {
      expect(calc.validasiTransaksi(daftar, 100001, JenisTransaksi.pengeluaran),
          'Pengeluaran melebihi saldo');
    });

    test('pengeluaran pada daftar kosong ditolak', () {
      expect(calc.validasiTransaksi([], 1, JenisTransaksi.pengeluaran),
          isNotNull);
    });

    test('pemasukan nominal terkecil (1) diterima', () {
      expect(calc.validasiTransaksi([], 1, JenisTransaksi.pemasukan), isNull);
    });
  });
}
