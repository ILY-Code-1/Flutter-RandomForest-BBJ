// File: random_forest_service.dart
// Service untuk menjalankan algoritma Random Forest dengan 57 pohon keputusan
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
      _pohon1,
      _pohon2,
      _pohon3,
      _pohon4,
      _pohon5,
      _pohon6,
      _pohon7,
      _pohon8,
      _pohon9,
      _pohon10,
      _pohon11,
      _pohon12,
      _pohon13,
      _pohon14,
      _pohon15,
      _pohon16,
      _pohon17,
      _pohon18,
      _pohon19,
      _pohon20,
      _pohon21,
      _pohon22,
      _pohon23,
      _pohon24,
      _pohon25,
      _pohon26,
      _pohon27,
      _pohon28,
      _pohon29,
      _pohon30,
      _pohon31,
      _pohon32,
      _pohon33,
      _pohon34,
      _pohon35,
      _pohon36,
      _pohon37,
      _pohon38,
      _pohon39,
      _pohon40,
      _pohon41,
      _pohon42,
      _pohon43,
      _pohon44,
      _pohon45,
      _pohon46,
      _pohon47,
      _pohon48,
      _pohon49,
      _pohon50,
      _pohon51,
      _pohon52,
      _pohon53,
      _pohon54,
      _pohon55,
      _pohon56,
      _pohon57,
    ];
  }

  int get jumlahPohon => _semuaPohon.length;

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN PREDICTION METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  NasabahModel predict(NasabahInputModel input, String id, String idNasabah) {
    List<String> hasilPohon = [];
    for (var pohon in _semuaPohon) {
      hasilPohon.add(pohon(input));
    }

    int countAktif = hasilPohon.where((h) => h == aktif).length;
    int countTidakAktif = hasilPohon.where((h) => h == tidakAktif).length;

    String finalPrediksi = countAktif > countTidakAktif ? aktif : tidakAktif;

    String prediksiAwal = input.statusNasabah;

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

  // ─────────────────────────────────────────────────────────────────────────────
  // HELPER METHODS for Pekerjaan Categorization (kode-based)
  // ─────────────────────────────────────────────────────────────────────────────
  // Format input.pekerjaan: "005 ADMINISTRASI UMUM", "013 WIRASWASTA", dll.
  // Kode: 005=Administrasi, 007=Konsultan, 009=Pengajar, 013=Wiraswasta,
  //       026=Pengamanan, 032=Buruh, 034=IRT, 035=Informal, 099=Lain-lain
  // ─────────────────────────────────────────────────────────────────────────────

  String _kodePekerjaan(NasabahInputModel input) {
    if (input.pekerjaan.length >= 3) {
      return input.pekerjaan.substring(0, 3);
    }
    return '';
  }

  bool _isPekerjaanStabil(NasabahInputModel input) {
    return ['005', '007', '009', '026'].contains(_kodePekerjaan(input));
  }

  bool _isPekerjaanWiraswasta(NasabahInputModel input) {
    return _kodePekerjaan(input) == '013';
  }

  bool _isPekerjaanRentan(NasabahInputModel input) {
    return ['032', '034', '035', '099'].contains(_kodePekerjaan(input));
  }

  bool _isIRTatauInformal(NasabahInputModel input) {
    return ['034', '035'].contains(_kodePekerjaan(input));
  }



  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 1: Fokus pada Frekuensi Transaksi & Saldo Rata-rata (Tabungan)
  // ═══════════════════════════════════════════════════════════════════════════
  // Logika:
  // - Jika frekuensi transaksi >= 8 dan saldo >= 1jt -> Aktif
  // - Jika frekuensi transaksi >= 5 dan saldo >= 3jt -> Aktif
  // - Jika frekuensi transaksi >= 12 -> Aktif (sangat sering transaksi)
  // - Selain itu -> Pasif
  String _pohon1(NasabahInputModel input) {
    if (input.frekuensiTransaksi >= 8 && input.saldoRataRata >= 1000000) {
      return aktif;
    }
    if (input.frekuensiTransaksi >= 5 && input.saldoRataRata >= 3000000) {
      return aktif;
    }
    if (input.frekuensiTransaksi >= 12) {
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
  // - Lama >= 1 tahun dengan pekerjaan stabil (005,007,009,026) -> Aktif
  // - Lama < 1 tahun dengan frekuensi >= 10 -> Aktif (nasabah baru aktif)
  // - Selain itu -> Pasif
  String _pohon3(NasabahInputModel input) {
    if (input.lamaMenjadiNasabah >= 3) {
      return aktif;
    }

    if (input.lamaMenjadiNasabah >= 1 && _isPekerjaanStabil(input)) {
      return aktif;
    }
    if (input.lamaMenjadiNasabah < 1 && input.frekuensiTransaksi >= 10) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 4: Fokus pada Saldo Rata-rata & Frekuensi (Tabungan)
  // ═══════════════════════════════════════════════════════════════════════════
  // Logika:
  // - Saldo >= 10jt -> Aktif (high value customer)
  // - Saldo >= 3jt dan frekuensi >= 4 -> Aktif
  // - Saldo >= 1jt dan frekuensi >= 8 -> Aktif (tabungan aktif saldo sedang)
  // - Frekuensi >= 15 -> Aktif (sangat aktif transaksi)
  // - Selain itu -> Pasif
  String _pohon4(NasabahInputModel input) {
    if (input.saldoRataRata >= 10000000) {
      return aktif;
    }
    if (input.saldoRataRata >= 3000000 && input.frekuensiTransaksi >= 4) {
      return aktif;
    }
    if (input.saldoRataRata >= 1000000 && input.frekuensiTransaksi >= 8) {
      return aktif;
    }
    if (input.frekuensiTransaksi >= 15) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 5: Kombinasi Pendapatan, Transaksi, Lama Nasabah (Tabungan)
  // ═══════════════════════════════════════════════════════════════════════════
  // Logika:
  // - Pendapatan >= 5jt dan transaksi >= 6 -> Aktif
  // - Pendapatan >= 3jt dan lama >= 2 tahun -> Aktif
  // - Transaksi >= 12 (sangat aktif, cocok untuk tabungan) -> Aktif
  // - Selain itu -> Pasif
  String _pohon5(NasabahInputModel input) {
    if (input.pendapatanBulanan >= 5000000 && input.frekuensiTransaksi >= 6) {
      return aktif;
    }
    if (input.pendapatanBulanan >= 3000000 && input.lamaMenjadiNasabah >= 2) {
      return aktif;
    }
    if (input.frekuensiTransaksi >= 12) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 6: Fokus Usia, Jenis Kelamin, Pendapatan (Tabungan)
  // ═══════════════════════════════════════════════════════════════════════════
  // Logika:
  // - Usia 25-55 dengan pendapatan >= 5jt -> Aktif
  // - Laki-laki usia >= 25 dengan pendapatan >= 3jt dan saldo >= 2jt -> Aktif
  // - Perempuan dengan pendapatan >= 3jt dan frekuensi >= 6 -> Aktif
  // - Selain itu -> Pasif
  String _pohon6(NasabahInputModel input) {
    if (input.usia >= 25 && input.usia <= 55 && input.pendapatanBulanan >= 5000000) {
      return aktif;
    }
    if (input.jenisKelamin == 'Laki-laki' &&
        input.usia >= 25 &&
        input.pendapatanBulanan >= 3000000 &&
        input.saldoRataRata >= 2000000) {
      return aktif;
    }
    if (input.jenisKelamin == 'Perempuan' &&
        input.pendapatanBulanan >= 3000000 &&
        input.frekuensiTransaksi >= 6) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 7: Comprehensive - Semua Faktor dengan Bobot
  // ═══════════════════════════════════════════════════════════════════
  // Logika berbasis skor:
  // - Hitung skor dari semua faktor
  // - Skor >= 4 -> Aktif
  // - Skor < 4 -> Pasif
  String _pohon7(NasabahInputModel input) {
    int skor = 0;

    // Usia produktif (+1)
    if (input.usia >= 25 && input.usia <= 55) skor++;

    // Pendapatan bagus (+1)
    if (input.pendapatanBulanan >= 4000000) skor++;

    // Frekuensi transaksi aktif (+1)
    if (input.frekuensiTransaksi >= 6) skor++;

    // Saldo cukup (+1)
    if (input.saldoRataRata >= 2000000) skor++;

    // Nasabah lama (+1)
    if (input.lamaMenjadiNasabah >= 2) skor++;

    // Pekerjaan stabil (005,007,009,013,026: +1)
    if (_isPekerjaanStabil(input) || _isPekerjaanWiraswasta(input)) skor++;

    // Bonus frekuensi tinggi (+1)
    if (input.frekuensiTransaksi >= 12) skor++;

    return skor >= 4 ? aktif : tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 8: Saldo < 750rb DAN Frekuensi < 4
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon8(NasabahInputModel input) {
    if (input.saldoRataRata < 750000 && input.frekuensiTransaksi < 4) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 9: Pekerjaan Stabil (005,007,009,026) DAN Frekuensi >= 4
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon9(NasabahInputModel input) {
    if (_isPekerjaanStabil(input) && input.frekuensiTransaksi >= 4) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 10: Usia < 25 DAN Frekuensi < 4
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon10(NasabahInputModel input) {
    if (input.usia < 25 && input.frekuensiTransaksi < 4) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 11: Pendapatan >= 3jt DAN Saldo >= 1jt (Tabungan)
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon11(NasabahInputModel input) {
    if (input.pendapatanBulanan >= 3000000 && input.saldoRataRata >= 1000000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 12: Pekerjaan Stabil (005,007,009,026) DAN Frekuensi >= 5
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon12(NasabahInputModel input) {
    if (_isPekerjaanStabil(input) && input.frekuensiTransaksi >= 5) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 13: IRT/Informal (034,035) DAN Saldo < 500rb DAN Frekuensi < 3
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon13(NasabahInputModel input) {
    if (_isIRTatauInformal(input) && input.saldoRataRata < 500000 && input.frekuensiTransaksi < 3) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 14: Usia >= 50 DAN Frekuensi < 3
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon14(NasabahInputModel input) {
    if (input.usia >= 50 && input.frekuensiTransaksi < 3) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 15: Lama Nasabah < 1 tahun DAN Frekuensi < 5
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon15(NasabahInputModel input) {
    if (input.lamaMenjadiNasabah < 1 && input.frekuensiTransaksi < 5) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 16: Usia 25-40 DAN Frekuensi >= 6
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon16(NasabahInputModel input) {
    if (input.usia >= 25 && input.usia <= 40 && input.frekuensiTransaksi >= 6) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 17: IRT/Informal/Buruh (032,034,035) DAN Frekuensi < 3
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon17(NasabahInputModel input) {
    if (_isPekerjaanRentan(input) && input.frekuensiTransaksi < 3) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 18: Wiraswasta (013) DAN Saldo >= 2.5jt
  // ═══════════════════════════════════════════════════════════════════
  String _pohon18(NasabahInputModel input) {
    if (_isPekerjaanWiraswasta(input) && input.saldoRataRata >= 2500000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 19: Frekuensi >= 8 DAN Saldo >= 1.5jt
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon19(NasabahInputModel input) {
    if (input.frekuensiTransaksi >= 8 && input.saldoRataRata >= 1500000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 20: Pendapatan >= 4jt DAN Frekuensi >= 5
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon20(NasabahInputModel input) {
    if (input.pendapatanBulanan >= 4000000 && input.frekuensiTransaksi >= 5) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═════════════════════════════════════════════════════════════════════════��═
  // POHON 21: Pendapatan < 3jt DAN Frekuensi < 4
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon21(NasabahInputModel input) {
    if (input.pendapatanBulanan < 3000000 && input.frekuensiTransaksi < 4) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 22: Jenis Kelamin Laki-laki DAN Frekuensi >= 7
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon22(NasabahInputModel input) {
    if (input.jenisKelamin == 'Laki-laki' && input.frekuensiTransaksi >= 7) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 23: Frekuensi >= 8 DAN Pendapatan >= 2.5jt (Tabungan)
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon23(NasabahInputModel input) {
    if (input.frekuensiTransaksi >= 8 && input.pendapatanBulanan >= 2500000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 24: Frekuensi < 3 DAN Pendapatan < 2.5jt
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon24(NasabahInputModel input) {
    if (input.frekuensiTransaksi < 3 && input.pendapatanBulanan < 2500000) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 25: Pekerjaan Stabil (005,007,009,026) DAN Frekuensi >= 4
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon25(NasabahInputModel input) {
    if (_isPekerjaanStabil(input) && input.frekuensiTransaksi >= 4) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 26: Saldo < 1jt DAN Pendapatan < 3jt
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon26(NasabahInputModel input) {
    if (input.saldoRataRata < 1000000 && input.pendapatanBulanan < 3000000) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 27: Usia >= 45 DAN Frekuensi < 4
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon27(NasabahInputModel input) {
    if (input.usia >= 45 && input.frekuensiTransaksi < 4) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 28: Usia < 30 DAN Frekuensi < 5
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon28(NasabahInputModel input) {
    if (input.usia < 30 && input.frekuensiTransaksi < 5) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 29: Pendapatan >= 6jt DAN Frekuensi >= 7
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon29(NasabahInputModel input) {
    if (input.pendapatanBulanan >= 6000000 && input.frekuensiTransaksi >= 7) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 30: Frekuensi < 5 DAN Saldo < 1.2jt
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon30(NasabahInputModel input) {
    if (input.frekuensiTransaksi < 5 && input.saldoRataRata < 1200000) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 31: Frekuensi >= 8 DAN Saldo >= 1.8jt
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon31(NasabahInputModel input) {
    if (input.frekuensiTransaksi >= 8 && input.saldoRataRata >= 1800000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 32: Lama Nasabah < 1.5 tahun DAN Pendapatan < 3jt
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon32(NasabahInputModel input) {
    if (input.lamaMenjadiNasabah < 1 && input.pendapatanBulanan < 3000000) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 33: Lama Nasabah >= 3 tahun DAN Pendapatan >= 3.5jt
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon33(NasabahInputModel input) {
    if (input.lamaMenjadiNasabah >= 3 && input.pendapatanBulanan >= 3500000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 34: Wiraswasta (013) DAN Frekuensi >= 5
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon34(NasabahInputModel input) {
    if (_isPekerjaanWiraswasta(input) && input.frekuensiTransaksi >= 5) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 35: Usia >= 55 DAN Frekuensi < 4
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon35(NasabahInputModel input) {
    if (input.usia >= 55 && input.frekuensiTransaksi < 4) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 36: Frekuensi <= 2 DAN Saldo < 500rb
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon36(NasabahInputModel input) {
    if (input.frekuensiTransaksi <= 2 && input.saldoRataRata < 500000) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 37: Pendapatan < 2.5jt DAN Saldo < 750rb
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon37(NasabahInputModel input) {
    if (input.pendapatanBulanan < 2500000 && input.saldoRataRata < 750000) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 38: Pendapatan >= 4jt DAN Saldo >= 1.5jt (Tabungan)
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon38(NasabahInputModel input) {
    if (input.pendapatanBulanan >= 4000000 && input.saldoRataRata >= 1500000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 39: Lama Nasabah < 2 tahun DAN Frekuensi < 4
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon39(NasabahInputModel input) {
    if (input.lamaMenjadiNasabah < 2 && input.frekuensiTransaksi < 4) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 40: Lama Nasabah >= 4 tahun DAN Frekuensi >= 5
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon40(NasabahInputModel input) {
    if (input.lamaMenjadiNasabah >= 4 && input.frekuensiTransaksi >= 5) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 41: Buruh/IRT/Informal (032,034,035) DAN Frekuensi < 2
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon41(NasabahInputModel input) {
    if (_isPekerjaanRentan(input) && input.frekuensiTransaksi < 2) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 42: Pekerjaan Stabil/Wiraswasta (005,007,009,013,026) DAN Pendapatan >= 4jt
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon42(NasabahInputModel input) {
    if ((_isPekerjaanStabil(input) || _isPekerjaanWiraswasta(input)) && input.pendapatanBulanan >= 4000000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 43: Usia >= 30 DAN Frekuensi >= 6
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon43(NasabahInputModel input) {
    if (input.usia >= 30 && input.frekuensiTransaksi >= 6) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 44: Saldo < 600rb DAN Pendapatan < 3jt
  // ═══════════��═��═════════════════════════════════════════════════════
  String _pohon44(NasabahInputModel input) {
    if (input.saldoRataRata < 600000 && input.pendapatanBulanan < 3000000) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 45: Saldo >= 2jt DAN Frekuensi >= 5 (Tabungan)
  // ═══════════════════════════════════════════════════════════════════
  String _pohon45(NasabahInputModel input) {
    if (input.saldoRataRata >= 2000000 && input.frekuensiTransaksi >= 5) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 46: Frekuensi < 4 DAN Lama < 1 tahun
  // ═══════════════════════════════════════════════════════════════════
  String _pohon46(NasabahInputModel input) {
    if (input.frekuensiTransaksi < 4 && input.lamaMenjadiNasabah < 1) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 47: Frekuensi >= 9 DAN Lama >= 2 tahun
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon47(NasabahInputModel input) {
    if (input.frekuensiTransaksi >= 9 && input.lamaMenjadiNasabah >= 2) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 48: Frekuensi >= 6 DAN Saldo >= 1jt
  // ═══════════════════════════════════════════════════════════════════
  String _pohon48(NasabahInputModel input) {
    if (input.frekuensiTransaksi >= 6 && input.saldoRataRata >= 1000000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 49: Usia < 28 DAN Pendapatan < 3jt
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon49(NasabahInputModel input) {
    if (input.usia < 28 && input.pendapatanBulanan < 3000000) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 50: Lama Nasabah >= 2 tahun DAN Frekuensi >= 5
  // ═══════════════════════════════���═���═════════════════════════════════════════
  String _pohon50(NasabahInputModel input) {
    if (input.lamaMenjadiNasabah >= 2 && input.frekuensiTransaksi >= 5) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 51: Saldo < 800rb DAN Frekuensi < 4
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon51(NasabahInputModel input) {
    if (input.saldoRataRata < 800000 && input.frekuensiTransaksi < 4) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 52: Pekerjaan Stabil/Wiraswasta (005,007,009,013,026) DAN Frekuensi >= 5
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon52(NasabahInputModel input) {
    if ((_isPekerjaanStabil(input) || _isPekerjaanWiraswasta(input)) && input.frekuensiTransaksi >= 5) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 53: Pendapatan < 2.5jt DAN Frekuensi <= 3
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon53(NasabahInputModel input) {
    if (input.pendapatanBulanan < 2500000 && input.frekuensiTransaksi <= 3) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 54: Usia >= 35 DAN Saldo >= 2jt
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon54(NasabahInputModel input) {
    if (input.usia >= 35 && input.saldoRataRata >= 2000000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════
  // POHON 55: Lama Nasabah < 1 tahun DAN Saldo < 700rb
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon55(NasabahInputModel input) {
    if (input.lamaMenjadiNasabah < 1 && input.saldoRataRata < 700000) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 56: Frekuensi >= 7 DAN Pendapatan >= 4jt
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon56(NasabahInputModel input) {
    if (input.frekuensiTransaksi >= 7 && input.pendapatanBulanan >= 4000000) {
      return aktif;
    }
    return tidakAktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POHON 57: IRT/Lain-lain (034,099) DAN Saldo < 600rb DAN Frekuensi < 3
  // ═══════════════════════════════════════════════════════════════════════════
  String _pohon57(NasabahInputModel input) {
    String kode = _kodePekerjaan(input);
    if ((kode == '034' || kode == '099') && input.saldoRataRata < 600000 && input.frekuensiTransaksi < 3) {
      return tidakAktif;
    }
    return aktif;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER: Get deskripsi semua pohon (untuk dokumentasi/debug)
  // ═══════════════════════════════════════════════════════════════════════════
  static List<String> getDeskripsiPohon() {
    return [
      'Pohon 1: Frekuensi & Saldo (Tabungan: >=8+1jt atau >=12)',
      'Pohon 2: Fokus Pendapatan & Usia',
      'Pohon 3: Lama Nasabah & Pekerjaan (kode 005,007,009,026)',
      'Pohon 4: Saldo & Frekuensi (Tabungan: >=3jt+4x atau >=1jt+8x)',
      'Pohon 5: Pendapatan, Transaksi, Lama (Tabungan: >=12x aktif)',
      'Pohon 6: Usia, Gender, Pendapatan (Tabungan: threshold rendah)',
      'Pohon 7: Score-based (pekerjaan: kode 005,007,009,013,026)',
      'Pohon 8: Saldo < 750rb & Frekuensi < 4',
      'Pohon 9: Pekerjaan Stabil (005,007,009,026) & Frekuensi >= 4',
      'Pohon 10: Usia < 25 & Frekuensi < 4',
      'Pohon 11: Pendapatan >= 3jt & Saldo >= 1jt (Tabungan)',
      'Pohon 12: Pekerjaan Stabil (005,007,009,026) & Frekuensi >= 5',
      'Pohon 13: IRT/Informal (034,035) & Saldo < 500rb & Frek < 3',
      'Pohon 14: Usia >= 50 & Frekuensi < 3',
      'Pohon 15: Lama < 1 tahun & Frekuensi < 5',
      'Pohon 16: Usia 25-40 & Frekuensi >= 6',
      'Pohon 17: IRT/Informal/Buruh (032,034,035) & Frekuensi < 3',
      'Pohon 18: Wiraswasta (013) & Saldo >= 2.5jt',
      'Pohon 19: Frekuensi >= 8 & Saldo >= 1.5jt',
      'Pohon 20: Pendapatan >= 4jt & Frekuensi >= 5',
      'Pohon 21: Pendapatan < 3jt & Frekuensi < 4',
      'Pohon 22: Laki-laki & Frekuensi >= 7',
      'Pohon 23: Frekuensi >= 8 & Pendapatan >= 2.5jt (Tabungan)',
      'Pohon 24: Frekuensi < 3 & Pendapatan < 2.5jt',
      'Pohon 25: Pekerjaan Stabil (005,007,009,026) & Frekuensi >= 4',
      'Pohon 26: Saldo < 1jt & Pendapatan < 3jt',
      'Pohon 27: Usia >= 45 & Frekuensi < 4',
      'Pohon 28: Usia < 30 & Frekuensi < 5',
      'Pohon 29: Pendapatan >= 6jt & Frekuensi >= 7',
      'Pohon 30: Frekuensi < 5 & Saldo < 1.2jt',
      'Pohon 31: Frekuensi >= 8 & Saldo >= 1.8jt',
      'Pohon 32: Lama < 1.5 tahun & Pendapatan < 3jt',
      'Pohon 33: Lama >= 3 tahun & Pendapatan >= 3.5jt',
      'Pohon 34: Wiraswasta (013) & Frekuensi >= 5',
      'Pohon 35: Usia >= 55 & Frekuensi < 4',
      'Pohon 36: Frekuensi <= 2 & Saldo < 500rb',
      'Pohon 37: Pendapatan < 2.5jt & Saldo < 750rb',
      'Pohon 38: Pendapatan >= 4jt & Saldo >= 1.5jt (Tabungan)',
      'Pohon 39: Lama < 2 tahun & Frekuensi < 4',
      'Pohon 40: Lama >= 4 tahun & Frekuensi >= 5',
      'Pohon 41: Buruh/IRT/Informal (032,034,035) & Frekuensi < 2',
      'Pohon 42: Stabil/Wiraswasta (005,007,009,013,026) & Gaji >= 4jt',
      'Pohon 43: Usia >= 30 & Frekuensi >= 6',
      'Pohon 44: Saldo < 600rb & Pendapatan < 3jt',
      'Pohon 45: Saldo >= 2jt & Frekuensi >= 5 (Tabungan)',
      'Pohon 46: Frekuensi < 4 & Lama < 1 tahun',
      'Pohon 47: Frekuensi >= 9 & Lama >= 2 tahun',
      'Pohon 48: Frekuensi >= 6 & Saldo >= 1jt',
      'Pohon 49: Usia < 28 & Pendapatan < 3jt',
      'Pohon 50: Lama >= 2 tahun & Frekuensi >= 5',
      'Pohon 51: Saldo < 800rb & Frekuensi < 4',
      'Pohon 52: Stabil/Wiraswasta (005,007,009,013,026) & Frek >= 5',
      'Pohon 53: Pendapatan < 2.5jt & Frekuensi <= 3',
      'Pohon 54: Usia >= 35 & Saldo >= 2jt',
      'Pohon 55: Lama < 1 tahun & Saldo < 700rb',
      'Pohon 56: Frekuensi >= 7 & Pendapatan >= 4jt',
      'Pohon 57: IRT/Lain-lain (034,099) & Saldo < 600rb & Frek < 3',
    ];
  }
}