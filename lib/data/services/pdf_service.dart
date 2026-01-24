// File: pdf_service.dart
// Service untuk generate laporan PDF hasil prediksi Random Forest

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/prediction_model.dart';

class PdfService {
  static Future<File> generatePredictionReport(PredictionSessionModel session) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(session),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummarySection(session),
          pw.SizedBox(height: 20),
          _buildNasabahSection(session),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${session.flag.replaceAll(':', '-')}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildHeader(PredictionSessionModel session) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 1)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LAPORAN HASIL PREDIKSI',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.Text(
                    'RANDOM FOREST - BPR BOGOR JABAR',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue700,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  session.flag,
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Tanggal: ${_formatDate(session.tanggalPrediksi)}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 12, bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '© BPR Bogor Jabar',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Bank Perkreditan Rakyat',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Generated with Random Forest App',
                    style: const pw.TextStyle(
                      fontSize: 7,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection(PredictionSessionModel session) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue900,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RINGKASAN PREDIKSI',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Data', session.jumlahData.toString()),
              _buildSummaryItem('Prediksi Aktif', session.nasabahAktif.toString()),
              _buildSummaryItem('Prediksi Pasif', session.nasabahTidakAktif.toString()),
              _buildSummaryItem('Prediksi Benar', session.prediksiBenar.toString()),
              _buildSummaryItem('Akurasi', '${session.akurasi.toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey300,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildNasabahSection(PredictionSessionModel session) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETAIL NASABAH',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 12),
        ...session.nasabahList.asMap().entries.map((entry) {
          final index = entry.key;
          final nasabah = entry.value;
          return _buildNasabahCard(nasabah, index + 1);
        }),
      ],
    );
  }

  static pw.Widget _buildNasabahCard(NasabahModel nasabah, int index) {
    final isAktif = nasabah.finalPrediksi == 'Aktif';
    final isBenar = nasabah.evaluasi == 'Benar';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue900,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      '#$index',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'ID: ${nasabah.idNasabah}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: isAktif ? PdfColors.green100 : PdfColors.red100,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'Status Awal: ${nasabah.statusNasabah}',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: isAktif ? PdfColors.green800 : PdfColors.red800,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),

          // Data Nasabah
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDataRow('Usia', '${nasabah.usia} tahun'),
                    _buildDataRow('Jenis Kelamin', nasabah.jenisKelamin),
                    _buildDataRow('Pekerjaan', nasabah.pekerjaan),
                    _buildDataRow('Pendapatan', 'Rp ${_formatNumber(nasabah.pendapatanBulanan)}'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDataRow('Frekuensi Transaksi', '${nasabah.frekuensiTransaksi}x/bulan'),
                    _buildDataRow('Saldo Rata-rata', 'Rp ${_formatNumber(nasabah.saldoRataRata)}'),
                    _buildDataRow('Lama Nasabah', '${nasabah.lamaMenjadiNasabah} tahun'),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),

          // Hasil Prediksi Pohon
          pw.Text(
            'Hasil Prediksi 7 Pohon:',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 8,
            runSpacing: 4,
            children: nasabah.prediksiPohon.asMap().entries.map((entry) {
              final pohonIndex = entry.key + 1;
              final hasil = entry.value;
              final pohonAktif = hasil == 'Aktif';
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: pohonAktif ? PdfColors.green50 : PdfColors.red50,
                  border: pw.Border.all(
                    color: pohonAktif ? PdfColors.green300 : PdfColors.red300,
                  ),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'P$pohonIndex: $hasil',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: pohonAktif ? PdfColors.green800 : PdfColors.red800,
                  ),
                ),
              );
            }).toList(),
          ),
          pw.SizedBox(height: 10),

          // Final Result
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      'FINAL PREDIKSI: ',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: isAktif ? PdfColors.green : PdfColors.red,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        nasabah.finalPrediksi,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      'EVALUASI: ',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: isBenar ? PdfColors.green : PdfColors.red,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        nasabah.evaluasi,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDataRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label:',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
