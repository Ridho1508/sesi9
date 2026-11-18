import 'package:flutter/material.dart';

import 'ui/kas/home_screen.dart';
import 'ui/kas/kas_view_model.dart';

void main() => runApp(const NusaKasApp());

class NusaKasApp extends StatefulWidget {
  const NusaKasApp({super.key});

  @override
  State<NusaKasApp> createState() => _NusaKasAppState();
}

class _NusaKasAppState extends State<NusaKasApp> {
  final _viewModel = KasViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  ThemeData _tema() {
    OutlineInputBorder garis(Color warna, double lebar) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: warna, width: lebar),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: KasWarna.primary)
          .copyWith(primary: KasWarna.primary),
      scaffoldBackgroundColor: KasWarna.latar,
      appBarTheme: const AppBarTheme(
        backgroundColor: KasWarna.latar,
        foregroundColor: KasWarna.teks,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: garis(KasWarna.garis, 1),
        enabledBorder: garis(KasWarna.garis, 1),
        focusedBorder: garis(KasWarna.primary, 2),
        errorBorder: garis(KasWarna.pengeluaranTeks, 1.5),
        focusedErrorBorder: garis(KasWarna.pengeluaranTeks, 2),
        errorStyle: const TextStyle(color: KasWarna.pengeluaranTeks),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NusaKas',
      debugShowCheckedModeBanner: false,
      theme: _tema(),
      home: HomeScreen(viewModel: _viewModel),
    );
  }
}
