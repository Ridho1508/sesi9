import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nusa_kas/main.dart' as app;

String _teks(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

Future<void> _tambah(
  WidgetTester tester, {
  required String keterangan,
  required String nominal,
  bool pengeluaran = false,
}) async {
  await tester.tap(find.byKey(const Key('tambahFab')));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('keteranganField')), keterangan);
  await tester.enterText(find.byKey(const Key('nominalField')), nominal);

  if (pengeluaran) {
    final jenis = find.byKey(const Key('jenisPengeluaran'));
    await tester.ensureVisible(jenis);
    await tester.pumpAndSettle();
    await tester.tap(jenis);
    await tester.pumpAndSettle();
  }

  final simpan = find.byKey(const Key('simpanButton'));
  await tester.ensureVisible(simpan);
  await tester.pumpAndSettle();
  await tester.tap(simpan);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tambah dua transaksi lalu periksa saldo', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(_teks(tester, 'saldoText'), 'Rp 0');

    await _tambah(tester, keterangan: 'Iuran anggota', nominal: '100000');
    await _tambah(
      tester,
      keterangan: 'Beli konsumsi',
      nominal: '30000',
      pengeluaran: true,
    );

    expect(_teks(tester, 'saldoText'), 'Rp 70.000');
    expect(_teks(tester, 'pemasukanText'), 'Rp 100.000');
    expect(_teks(tester, 'pengeluaranText'), 'Rp 30.000');
    expect(find.text('Iuran anggota'), findsOneWidget);
    expect(find.text('Beli konsumsi'), findsOneWidget);
  });
}
