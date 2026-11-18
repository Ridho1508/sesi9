import 'package:flutter/material.dart';

import '../../domain/models/transaksi.dart';
import 'home_screen.dart';
import 'kas_view_model.dart';

class TambahTransaksiScreen extends StatefulWidget {
  const TambahTransaksiScreen({super.key, required this.viewModel});

  final KasViewModel viewModel;

  @override
  State<TambahTransaksiScreen> createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();
  final _nominalController = TextEditingController();
  JenisTransaksi _jenis = JenisTransaksi.pemasukan;
  bool _gagal = false;

  @override
  void dispose() {
    _keteranganController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  String? _validasiNominal(String? v) {
    final nominal = int.tryParse((v ?? '').trim());
    if (nominal == null) return 'Nominal harus berupa angka';
    if (nominal <= 0) return widget.viewModel.validasiNominal(nominal, _jenis);
    return null;
  }

  /// Hanya memeriksa aturan "pengeluaran melebihi saldo".
  String? _validasiJenis(JenisTransaksi? _) {
    final nominal = int.tryParse(_nominalController.text.trim());
    if (nominal == null || nominal <= 0) return null;
    return widget.viewModel.validasiNominal(nominal, _jenis);
  }

  void _pilihJenis(FormFieldState<JenisTransaksi> state, JenisTransaksi j) {
    state.didChange(j);
    setState(() => _jenis = j);
    if (state.hasError) state.validate();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _gagal = true);
      return;
    }
    final error = widget.viewModel.tambahTransaksi(
      keterangan: _keteranganController.text,
      nominal: int.parse(_nominalController.text.trim()),
      jenis: _jenis,
    );
    if (error != null) {
      setState(() => _gagal = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KasWarna.latar,
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Catat Transaksi',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600, height: 1.2)),
            Text('NusaKas',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: KasWarna.teksSekunder)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Keterangan Transaksi', aksi: 'Wajib diisi'),
              TextFormField(
                key: const Key('keteranganField'),
                controller: _keteranganController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Iuran kas bulanan pengurus',
                  helperText:
                      'Tuliskan sumber pemasukan atau tujuan belanja secara ringkas.',
                  helperMaxLines: 2,
                  suffixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Keterangan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 20),
              const _Label('Nominal (Rp)', aksi: 'IDR'),
              TextFormField(
                key: const Key('nominalField'),
                controller: _nominalController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  prefixText: 'Rp  ',
                  prefixStyle: TextStyle(
                      color: KasWarna.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                  hintText: '0',
                  helperText: 'Gunakan angka tanpa titik atau koma',
                ),
                validator: _validasiNominal,
              ),
              const SizedBox(height: 20),
              const _Label('Jenis Transaksi'),
              FormField<JenisTransaksi>(
                key: const Key('jenisField'),
                initialValue: _jenis,
                validator: _validasiJenis,
                builder: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SegmenJenis(
                            key: const Key('jenisPemasukan'),
                            jenis: JenisTransaksi.pemasukan,
                            terpilih: _jenis == JenisTransaksi.pemasukan,
                            onTap: () =>
                                _pilihJenis(state, JenisTransaksi.pemasukan),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SegmenJenis(
                            key: const Key('jenisPengeluaran'),
                            jenis: JenisTransaksi.pengeluaran,
                            terpilih: _jenis == JenisTransaksi.pengeluaran,
                            onTap: () =>
                                _pilihJenis(state, JenisTransaksi.pengeluaran),
                          ),
                        ),
                      ],
                    ),
                    if (_jenis == JenisTransaksi.pengeluaran) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: KasWarna.pengeluaranBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Batas maksimum kas saat ini:',
                                style: TextStyle(fontSize: 13)),
                            Text(formatRupiah(widget.viewModel.saldo),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: KasWarna.pengeluaranTeks)),
                          ],
                        ),
                      ),
                    ],
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 16, color: KasWarna.pengeluaranTeks),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(state.errorText!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: KasWarna.pengeluaranTeks)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _Ringkasan(
                nominalController: _nominalController,
                jenis: _jenis,
                viewModel: widget.viewModel,
              ),
              if (_gagal) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDAD6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error,
                          color: KasWarna.pengeluaranTeks),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gagal Menyimpan',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: KasWarna.pengeluaranTeks)),
                            SizedBox(height: 2),
                            Text('Harap periksa kembali isian formulir di atas.',
                                style: TextStyle(
                                    color: KasWarna.pengeluaranTeks)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _gagal = false),
                        child: const Icon(Icons.close,
                            color: KasWarna.pengeluaranTeks),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  key: const Key('simpanButton'),
                  style: FilledButton.styleFrom(
                    backgroundColor: KasWarna.primaryDark,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: _simpan,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Simpan Transaksi',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Pastikan seluruh data keuangan telah sesuai standar bendahara.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 12, color: KasWarna.teksSekunder),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.judul, {this.aksi});

  final String judul;
  final String? aksi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(judul,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          if (aksi != null)
            Text(aksi!,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: KasWarna.primary)),
        ],
      ),
    );
  }
}

class _SegmenJenis extends StatelessWidget {
  const _SegmenJenis({
    super.key,
    required this.jenis,
    required this.terpilih,
    required this.onTap,
  });

  final JenisTransaksi jenis;
  final bool terpilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final masuk = jenis == JenisTransaksi.pemasukan;
    final warnaAktif = masuk ? KasWarna.pemasukan : KasWarna.pengeluaran;
    final warnaIsi = terpilih ? Colors.white : KasWarna.teksSekunder;
    return Material(
      color: terpilih ? warnaAktif : KasWarna.abuAbu,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(masuk ? Icons.south_west : Icons.north_east,
                  size: 18, color: warnaIsi),
              const SizedBox(width: 8),
              Text(jenis.label,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: warnaIsi)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ringkasan extends StatelessWidget {
  const _Ringkasan({
    required this.nominalController,
    required this.jenis,
    required this.viewModel,
  });

  final TextEditingController nominalController;
  final JenisTransaksi jenis;
  final KasViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: nominalController,
      builder: (context, _) {
        final nominal = int.tryParse(nominalController.text.trim());
        final valid =
            nominal != null && viewModel.validasiNominal(nominal, jenis) == null;
        final masuk = jenis == JenisTransaksi.pemasukan;
        final status = nominal == null
            ? 'Menunggu nominal'
            : valid
                ? 'Siap disimpan'
                : 'Perlu diperbaiki';
        final warnaStatus = valid ? KasWarna.pemasukanTeks : KasWarna.teksSekunder;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KasWarna.abuAbu,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('RINGKASAN VALIDASI',
                      style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.5,
                          color: KasWarna.teksSekunder)),
                  Text(status,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: warnaStatus)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dampak ke Saldo Kas'),
                  Text(
                    valid
                        ? '${masuk ? '+' : '-'} ${formatRupiah(nominal)}'
                        : '-',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: !valid
                            ? KasWarna.teksSekunder
                            : masuk
                                ? KasWarna.pemasukanTeks
                                : KasWarna.pengeluaranTeks),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
