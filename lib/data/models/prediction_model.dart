// File: prediction_model.dart
// Model data untuk prediksi nasabah dengan JSON serialization untuk Firestore

import 'comment_model.dart';

class NasabahModel {
  final String id;
  final String idNasabah;
  final int usia;
  final String jenisKelamin;
  final String pekerjaan;
  final double pendapatanBulanan;
  final int frekuensiTransaksi;
  final double saldoRataRata;
  final int lamaMenjadiNasabah;
  final String statusNasabah; // Status aktual (ground truth)
  final String prediksiAwal;
  final List<String> prediksiPohon; // Hasil dari setiap pohon
  final String finalPrediksi;
  final String evaluasi; // Benar/Salah

  NasabahModel({
    required this.id,
    required this.idNasabah,
    required this.usia,
    required this.jenisKelamin,
    required this.pekerjaan,
    required this.pendapatanBulanan,
    required this.frekuensiTransaksi,
    required this.saldoRataRata,
    required this.lamaMenjadiNasabah,
    required this.statusNasabah,
    required this.prediksiAwal,
    required this.prediksiPohon,
    required this.finalPrediksi,
    required this.evaluasi,
  });

  NasabahModel copyWith({
    String? id,
    String? idNasabah,
    int? usia,
    String? jenisKelamin,
    String? pekerjaan,
    double? pendapatanBulanan,
    int? frekuensiTransaksi,
    double? saldoRataRata,
    int? lamaMenjadiNasabah,
    String? statusNasabah,
    String? prediksiAwal,
    List<String>? prediksiPohon,
    String? finalPrediksi,
    String? evaluasi,
  }) {
    return NasabahModel(
      id: id ?? this.id,
      idNasabah: idNasabah ?? this.idNasabah,
      usia: usia ?? this.usia,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      pendapatanBulanan: pendapatanBulanan ?? this.pendapatanBulanan,
      frekuensiTransaksi: frekuensiTransaksi ?? this.frekuensiTransaksi,
      saldoRataRata: saldoRataRata ?? this.saldoRataRata,
      lamaMenjadiNasabah: lamaMenjadiNasabah ?? this.lamaMenjadiNasabah,
      statusNasabah: statusNasabah ?? this.statusNasabah,
      prediksiAwal: prediksiAwal ?? this.prediksiAwal,
      prediksiPohon: prediksiPohon ?? this.prediksiPohon,
      finalPrediksi: finalPrediksi ?? this.finalPrediksi,
      evaluasi: evaluasi ?? this.evaluasi,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idNasabah': idNasabah,
      'usia': usia,
      'jenisKelamin': jenisKelamin,
      'pekerjaan': pekerjaan,
      'pendapatanBulanan': pendapatanBulanan,
      'frekuensiTransaksi': frekuensiTransaksi,
      'saldoRataRata': saldoRataRata,
      'lamaMenjadiNasabah': lamaMenjadiNasabah,
      'statusNasabah': statusNasabah,
      'prediksiAwal': prediksiAwal,
      'prediksiPohon': prediksiPohon,
      'finalPrediksi': finalPrediksi,
      'evaluasi': evaluasi,
    };
  }

  factory NasabahModel.fromJson(Map<String, dynamic> json) {
    return NasabahModel(
      id: json['id'] as String,
      idNasabah: json['idNasabah'] as String,
      usia: json['usia'] as int,
      jenisKelamin: json['jenisKelamin'] as String,
      pekerjaan: json['pekerjaan'] as String,
      pendapatanBulanan: (json['pendapatanBulanan'] as num).toDouble(),
      frekuensiTransaksi: json['frekuensiTransaksi'] as int,
      saldoRataRata: (json['saldoRataRata'] as num).toDouble(),
      lamaMenjadiNasabah: json['lamaMenjadiNasabah'] as int,
      statusNasabah: json['statusNasabah'] as String,
      prediksiAwal: json['prediksiAwal'] as String,
      prediksiPohon: List<String>.from(json['prediksiPohon']),
      finalPrediksi: json['finalPrediksi'] as String,
      evaluasi: json['evaluasi'] as String,
    );
  }
}

class PredictionSessionModel {
  final String id;
  final String flag; // Format: PREDICT_DD-MM-YYYY_HH:mm:ss
  final DateTime tanggalPrediksi;
  final List<NasabahModel> nasabahList;
  final double akurasi;
  final String createdBy; // User ID yang membuat prediksi
  final List<String> assignedUserIds; // List user ID yang dapat melihat (untuk marketing)
  final List<CommentModel> comments; // List komentar

  PredictionSessionModel({
    required this.id,
    String? flag,
    required this.tanggalPrediksi,
    required this.nasabahList,
    required this.akurasi,
    required this.createdBy,
    this.assignedUserIds = const [],
    this.comments = const [],
  }) : flag = flag ?? _generateFlag(tanggalPrediksi);

  static String _generateFlag(DateTime d) {
    return 'PREDICT_${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}_${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';
  }

  String get formattedDate => flag;

  int get jumlahData => nasabahList.length;

  int get nasabahAktif => nasabahList.where((n) => n.finalPrediksi == 'Aktif').length;

  int get nasabahTidakAktif => nasabahList.where((n) => n.finalPrediksi == 'Pasif').length;

  int get prediksiBenar => nasabahList.where((n) => n.evaluasi == 'Benar').length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flag': flag,
      'tanggalPrediksi': tanggalPrediksi.toIso8601String(),
      'nasabahList': nasabahList.map((n) => n.toJson()).toList(),
      'akurasi': akurasi,
      'createdBy': createdBy,
      'assignedUserIds': assignedUserIds,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  factory PredictionSessionModel.fromJson(Map<String, dynamic> json) {
    return PredictionSessionModel(
      id: json['id'] as String,
      flag: json['flag'] as String,
      tanggalPrediksi: DateTime.parse(json['tanggalPrediksi'] as String),
      nasabahList: (json['nasabahList'] as List)
          .map((item) => NasabahModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      akurasi: (json['akurasi'] as num).toDouble(),
      createdBy: json['createdBy'] as String? ?? '',
      assignedUserIds: json['assignedUserIds'] != null
          ? List<String>.from(json['assignedUserIds'] as List)
          : [],
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((item) => CommentModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  String toDetailString() {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('LAPORAN HASIL PREDIKSI RANDOM FOREST');
    buffer.writeln('BPR Bogor Jabar');
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('');
    buffer.writeln('Session: $flag');
    buffer.writeln('Tanggal: ${tanggalPrediksi.day.toString().padLeft(2, '0')}/${tanggalPrediksi.month.toString().padLeft(2, '0')}/${tanggalPrediksi.year} ${tanggalPrediksi.hour.toString().padLeft(2, '0')}:${tanggalPrediksi.minute.toString().padLeft(2, '0')}');
    buffer.writeln('');
    buffer.writeln('───────────────────────────────────────────');
    buffer.writeln('RINGKASAN:');
    buffer.writeln('───────────────────────────────────────────');
    buffer.writeln('Total Data Nasabah : $jumlahData');
    buffer.writeln('Prediksi Aktif     : $nasabahAktif');
    buffer.writeln('Prediksi Pasif: $nasabahTidakAktif');
    buffer.writeln('Prediksi Benar     : $prediksiBenar');
    buffer.writeln('Akurasi            : ${akurasi.toStringAsFixed(2)}%');
    buffer.writeln('');

    for (int i = 0; i < nasabahList.length; i++) {
      final n = nasabahList[i];
      buffer.writeln('───────────────────────────────────────────');
      buffer.writeln('NASABAH ${i + 1}: ${n.idNasabah}');
      buffer.writeln('───────────────────────────────────────────');
      buffer.writeln('Data Input:');
      buffer.writeln('  - Usia                : ${n.usia} tahun');
      buffer.writeln('  - Jenis Kelamin       : ${n.jenisKelamin}');
      buffer.writeln('  - Pekerjaan           : ${n.pekerjaan}');
      buffer.writeln('  - Pendapatan Bulanan  : Rp ${_formatNumber(n.pendapatanBulanan)}');
      buffer.writeln('  - Frekuensi Transaksi : ${n.frekuensiTransaksi}x/bulan');
      buffer.writeln('  - Saldo Rata-rata     : Rp ${_formatNumber(n.saldoRataRata)}');
      buffer.writeln('  - Lama Menjadi Nasabah: ${n.lamaMenjadiNasabah} tahun');
      buffer.writeln('  - Status Aktual       : ${n.statusNasabah}');
      buffer.writeln('');
      buffer.writeln('Hasil Prediksi Pohon:');
      for (int j = 0; j < n.prediksiPohon.length; j++) {
        buffer.writeln('  - Pohon ${j + 1}: ${n.prediksiPohon[j]}');
      }
      buffer.writeln('');
      buffer.writeln('Prediksi Awal  : ${n.prediksiAwal}');
      buffer.writeln('Final Prediksi : ${n.finalPrediksi}');
      buffer.writeln('Evaluasi       : ${n.evaluasi}');
      buffer.writeln('');
    }

    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('Generated by BPR Bogor Jabar Random Forest App');
    buffer.writeln('═══════════════════════════════════════════');

    return buffer.toString();
  }

  static String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
