import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TanggalIndonesia extends StatelessWidget {
  final DateTime? tanggal;
  final TextStyle? style;
  final String prefix;

  const TanggalIndonesia({
    super.key,
    required this.tanggal,
    this.style,
    this.prefix = 'Tanggal: ',
  });

  @override
  Widget build(BuildContext context) {
    // Inisialisasi data lokal untuk Bahasa Indonesia
    initializeDateFormatting('id_ID', null);

    return Text(
      '$prefix${_formatDate(tanggal)}',
      style: style,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }
}
