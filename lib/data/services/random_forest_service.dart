// File: random_forest_service.dart
// Service untuk menjalankan algoritma Random Forest dengan 7 pohon keputusan
// 
// CARA MENAMBAH/MENGURANGI POHON:
// 1. Tambahkan method baru seperti _pohon8(), _pohon9(), dst
// 2. Update list _semuaPohon di constructor
// 3. Setiap pohon menerima data nasabah dan mengembalikan 'Aktif' atau 'Pasif'

import '../models/prediction_model.dart';

typedef DecisionTree = String Function(NasabahInputModel input);

class NasabahInputModel {
  final int usia;
  final String jenisKelamin;
  final String pekerjaan;
  final double pendapatanBulanan;
  final int frekuensiTransaksi;
  final double saldoRataRata;
  final int lamaMenjadiNasabah;
  final String statusNasabah;

  NasabahInputModel({
    required this.usia,
    required this.jenisKelamin,
    required this.pekerjaan,
    required this.pendapatanBulanan,
    required this.frekuensiTransaksi,
    required this.saldoRataRata,
    required this.lamaMenjadiNasabah,
    required this.statusNasabah,
  });
}

class RandomForestService {
  static const String aktif = 'Aktif';
  static const String tidakAktif = 'Pasif';

  // ═══════════════════════════════════════════════════════════════════════════
  // DAFTAR POHON KEPUTUSAN
  // Untuk menambah/mengurangi pohon, edit list ini
  // ═══════════════════════════════════════════════════════════════════════════
  late final List<DecisionTree> _semuaPohon;

  RandomForestService() {
    _semuaPohon = [
      _pohon1, // Fokus: Frekuensi Transaksi & Saldo
      _pohon2, // Fokus: Pendapatan & Usia
      _pohon3, // Fokus: Lama Menjadi Nasabah & Pekerjaan
      _pohon4, // Fokus: Saldo Rata-rata & Frekuensi
      _pohon5, // Fokus: Kombinasi Pendapatan, Transaksi, Lama Nasabah
      _pohon6, // Fokus: Usia & Jenis Kelamin & Pendapatan
      _pohon7, // Fokus: Comprehensive - Semua Faktor
    ];
  }

  int get jumlahPohon => _semuaPohon.length;

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN PREDICTION METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  NasabahModel predict(NasabahInputModel input, String id, String idNasabah) {
    // Jalankan semua pohon dan kumpulkan hasil
    List<String> hasilPohon = [];
    for (var pohon in _semuaPohon) {
      hasilPohon.add(pohon(input));
    }

    // Voting majority
    int countAktif = hasilPohon.where((h) => h == aktif).length;
    int countTidakAktif = hasilPohon.where((h) => h == tidakAktif).length;

    String finalPrediksi = countAktif > countTidakAktif ? aktif : tidakAktif;

    // Prediksi awal berdasarkan status saat ini
    String prediksiAwal = input.statusNasabah;

    // Evaluasi apakah prediksi benar
    String evaluasi = (finalPrediksi == input.statusNasabah) ? 'Benar' : 'Salah';

    return NasabahModel(
      id: id,
      idNasabah: idNasabah,
      usia: input.usia,
      jenisKelamin: input.jenisKelamin,
      pekerjaan: input.pekerjaan,
      pendapatanBulanan: input.pendapatanBulanan,
      frekuensiTransaksi: input.frekuensiTransaksi,
      saldoRataRata: input.saldoRataRata,
      lamaMenjadiNasabah: input.lamaMenjadiNasabah,
      statusNasabah: input.statusNasabah,
      prediksiAwal: prediksiAwal,
      prediksiPohon: hasilPohon,
      finalPrediksi: finalPrediksi,
      evaluasi: evaluasi,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 1: Fokus pada Frekuensi Transaksi & Saldo Rata-rata
  // ═══════════════════════════════════════════════════════════════════════════
  // Logika:
  // - Jika frekuensi transaksi >= 10 dan saldo >= 3jt -> Aktif
  // - Jika frekuensi transaksi >= 5 dan saldo >= 5jt -> Aktif
  // - Selain itu -> Pasif
  String _pohon1(NasabahInputModel input) {
    if (input.frekuensiTransaksi >= 10 && input.saldoRataRata >= 3000000) {
      return aktif;
    }
    if (input.frekuensiTransaksi >= 5 && input.saldoRataRata >= 5000000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 2: Fokus pada Pendapatan & Usia
  // ═══════════════════════════════════════════════════════════════════════════
  // Logika:
  // - Usia 25-55 (usia produktif) dengan pendapatan >= 5jt -> Aktif
  // - Usia < 25 dengan pendapatan >= 3jt dan frekuensi >= 8 -> Aktif
  // - Usia > 55 dengan pendapatan >= 10jt -> Aktif
  // - Selain itu -> Pasif
  String _pohon2(NasabahInputModel input) {
    if (input.usia >= 25 && input.usia <= 55 && input.pendapatanBulanan >= 5000000) {
      return aktif;
    }
    if (input.usia < 25 && input.pendapatanBulanan >= 3000000 && input.frekuensiTransaksi >= 8) {
      return aktif;
    }
    if (input.usia > 55 && input.pendapatanBulanan >= 10000000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 3: Fokus pada Lama Menjadi Nasabah & Pekerjaan
  // ═══════════════════════════════════════════════════════════════════════════
  // Logika:
  // - Lama >= 3 tahun -> Aktif (nasabah loyal)
  // - Lama >= 1 tahun dengan pekerjaan stabil (PNS, Karyawan, Profesional) -> Aktif
  // - Lama < 1 tahun dengan frekuensi >= 15 -> Aktif (nasabah baru aktif)
  // - Selain itu -> Pasif
  String _pohon3(NasabahInputModel input) {
    if (input.lamaMenjadiNasabah >= 3) {
      return aktif;
    }

    List<String> pekerjaanStabil = ['pns', 'karyawan', 'profesional', 'dokter', 'guru', 'dosen'];
    String pekerjaanLower = input.pekerjaan.toLowerCase();
    bool isPekerjaanStabil = pekerjaanStabil.any((p) => pekerjaanLower.contains(p));

    if (input.lamaMenjadiNasabah >= 1 && isPekerjaanStabil) {
      return aktif;
    }
    if (input.lamaMenjadiNasabah < 1 && input.frekuensiTransaksi >= 15) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 4: Fokus pada Saldo Rata-rata & Frekuensi (lebih detail)
  // ═══════════════════════════════════════════════════════════════════════════
  // Logika:
  // - Saldo >= 10jt -> Aktif (high value customer)
  // - Saldo >= 5jt dan frekuensi >= 5 -> Aktif
  // - Saldo >= 2jt dan frekuensi >= 12 -> Aktif (aktif tapi saldo rendah)
  // - Selain itu -> Pasif
  String _pohon4(NasabahInputModel input) {
    if (input.saldoRataRata >= 10000000) {
      return aktif;
    }
    if (input.saldoRataRata >= 5000000 && input.frekuensiTransaksi >= 5) {
      return aktif;
    }
    if (input.saldoRataRata >= 2000000 && input.frekuensiTransaksi >= 12) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 5: Kombinasi Pendapatan, Transaksi, Lama Nasabah
  // ═══════════════════════════════════════════════════════════════════════════
  // Logika:
  // - Pendapatan >= 7jt dan transaksi >= 8 -> Aktif
  // - Pendapatan >= 5jt dan lama >= 2 tahun -> Aktif
  // - Transaksi >= 20 (sangat aktif) -> Aktif
  // - Pendapatan < 3jt dan transaksi < 3 -> Pasif
  // - Selain itu perlu analisis lebih -> Pasif
  String _pohon5(NasabahInputModel input) {
    if (input.pendapatanBulanan >= 7000000 && input.frekuensiTransaksi >= 8) {
      return aktif;
    }
    if (input.pendapatanBulanan >= 5000000 && input.lamaMenjadiNasabah >= 2) {
      return aktif;
    }
    if (input.frekuensiTransaksi >= 20) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 6: Fokus Usia, Jenis Kelamin, Pendapatan
  // ═══════════════════════════════════════════════════════════════════════════
  // Logika:
  // - Usia 30-50 dengan pendapatan >= 6jt -> Aktif (prime earning years)
  // - Laki-laki usia >= 25 dengan pendapatan >= 5jt dan saldo >= 3jt -> Aktif
  // - Perempuan dengan pendapatan >= 4jt dan frekuensi >= 10 -> Aktif
  // - Selain itu -> Pasif
  String _pohon6(NasabahInputModel input) {
    if (input.usia >= 30 && input.usia <= 50 && input.pendapatanBulanan >= 6000000) {
      return aktif;
    }
    if (input.jenisKelamin == 'Laki-laki' &&
        input.usia >= 25 &&
        input.pendapatanBulanan >= 5000000 &&
        input.saldoRataRata >= 3000000) {
      return aktif;
    }
    if (input.jenisKelamin == 'Perempuan' &&
        input.pendapatanBulanan >= 4000000 &&
        input.frekuensiTransaksi >= 10) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 7: Comprehensive - Semua Faktor dengan Bobot
  // ═══════════════════════════════════════════════════════════════════════════
  // Logika berbasis skor:
  // - Hitung skor dari semua faktor
  // - Skor >= 4 -> Aktif
  // - Skor < 4 -> Pasif
  String _pohon7(NasabahInputModel input) {
    int skor = 0;

    // Usia produktif (+1)
    if (input.usia >= 25 && input.usia <= 55) skor++;

    // Pendapatan bagus (+1)
    if (input.pendapatanBulanan >= 5000000) skor++;

    // Frekuensi transaksi aktif (+1)
    if (input.frekuensiTransaksi >= 8) skor++;

    // Saldo cukup (+1)
    if (input.saldoRataRata >= 3000000) skor++;

    // Nasabah lama (+1)
    if (input.lamaMenjadiNasabah >= 2) skor++;

    // Pekerjaan tetap (+1)
    List<String> pekerjaanTetap = ['pns', 'karyawan', 'swasta', 'profesional', 'dokter', 'guru', 'wiraswasta'];
    String pekerjaanLower = input.pekerjaan.toLowerCase();
    bool hasPekerjaanTetap = pekerjaanTetap.any((p) => pekerjaanLower.contains(p));
    if (hasPekerjaanTetap) skor++;

    // Pendapatan sangat tinggi (+1 bonus)
    if (input.pendapatanBulanan >= 10000000) skor++;

    return skor >= 4 ? aktif : tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER: Get deskripsi semua pohon (untuk dokumentasi/debug)
  // ═══════════════════════════════════════════════════════════════════════════
  static List<String> getDeskripsiPohon() {
    return [
      'Pohon 1: Fokus Frekuensi Transaksi & Saldo',
      'Pohon 2: Fokus Pendapatan & Usia',
      'Pohon 3: Fokus Lama Nasabah & Pekerjaan',
      'Pohon 4: Fokus Saldo & Frekuensi Detail',
      'Pohon 5: Kombinasi Pendapatan, Transaksi, Lama',
      'Pohon 6: Fokus Usia, Gender, Pendapatan',
      'Pohon 7: Comprehensive Score-based',
    ];
  }
}
