import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nusa_kas/domain/models/transaksi.dart';
import 'package:nusa_kas/ui/kas/kas_view_model.dart';
import 'package:nusa_kas/ui/kas/tambah_transaksi_screen.dart';

Future<void> _pasang(WidgetTester tester, KasViewModel vm) {
  return tester.pumpWidget(
    MaterialApp(home: TambahTransaksiScreen(viewModel: vm)),
  );
}

Future<void> _pilihPengeluaran(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('jenisField')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pengeluaran').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('form kosong menampilkan pesan validasi', (tester) async {
    final vm = KasViewModel();
    await _pasang(tester, vm);

    await tester.tap(find.byKey(const Key('simpanButton')));
    await tester.pump();

    expect(find.text('Keterangan wajib diisi'), findsOneWidget);
    expect(find.text('Nominal harus berupa angka'), findsOneWidget);
    expect(vm.daftarTransaksi, isEmpty);
  });

  testWidgets('nominal nol dan pengeluaran melebihi saldo ditolak',
      (tester) async {
    final vm = KasViewModel();
    await _pasang(tester, vm);

    await tester.enterText(
        find.byKey(const Key('keteranganField')), 'Beli konsumsi');
    await tester.enterText(find.byKey(const Key('nominalField')), '0');
    await tester.tap(find.byKey(const Key('simpanButton')));
    await tester.pump();
    expect(find.text('Nominal harus lebih dari 0'), findsOneWidget);

    await _pilihPengeluaran(tester);
    await tester.enterText(find.byKey(const Key('nominalField')), '5000');
    await tester.tap(find.byKey(const Key('simpanButton')));
    await tester.pump();
    expect(find.text('Pengeluaran melebihi saldo'), findsOneWidget);
    expect(vm.daftarTransaksi, isEmpty);
  });

  testWidgets('pemasukan valid tersimpan ke view model', (tester) async {
    final vm = KasViewModel();
    await _pasang(tester, vm);

    await tester.enterText(
        find.byKey(const Key('keteranganField')), 'Iuran anggota');
    await tester.enterText(find.byKey(const Key('nominalField')), '100000');
    await tester.tap(find.byKey(const Key('simpanButton')));
    await tester.pumpAndSettle();

    expect(vm.daftarTransaksi, hasLength(1));
    expect(vm.daftarTransaksi.first.jenis, JenisTransaksi.pemasukan);
    expect(vm.saldo, 100000);
  });
}
