class NasabahBBJModel {
  final String id;
  final String idNasabah;
  final int usia;
  final String jenisKelamin;
  final String pekerjaan;
  final double pendapatanBulanan;
  final int frekuensiTransaksi;
  final double saldoRataRata;
  final int lamaMenjadiNasabah;
  final String statusNasabah;
  final DateTime createdAt;
  final DateTime updatedAt;

  NasabahBBJModel({
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
    required this.createdAt,
    required this.updatedAt,
  });

  NasabahBBJModel copyWith({
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NasabahBBJModel(
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NasabahBBJModel.fromJson(Map<String, dynamic> json) {
    return NasabahBBJModel(
      id: json['id'] as String? ?? '',
      idNasabah: json['idNasabah'] as String,
      usia: (json['usia'] as num).toInt(),
      jenisKelamin: json['jenisKelamin'] as String,
      pekerjaan: json['pekerjaan'] as String,
      pendapatanBulanan: (json['pendapatanBulanan'] as num).toDouble(),
      frekuensiTransaksi: (json['frekuensiTransaksi'] as num).toInt(),
      saldoRataRata: (json['saldoRataRata'] as num).toDouble(),
      lamaMenjadiNasabah: (json['lamaMenjadiNasabah'] as num).toInt(),
      statusNasabah: json['statusNasabah'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
