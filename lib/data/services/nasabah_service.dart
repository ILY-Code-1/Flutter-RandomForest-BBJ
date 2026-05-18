import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nasabah_bbj_model.dart';

class NasabahService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String nasabahCollection = 'nasabah_bbj';

  Future<List<NasabahBBJModel>> getAllNasabah() async {
    try {
      final snapshot = await _firestore
          .collection(nasabahCollection)
          .orderBy('idNasabah')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return NasabahBBJModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data nasabah: $e');
    }
  }

  Future<NasabahBBJModel> addNasabah(NasabahBBJModel nasabah) async {
    try {
      final existing = await _firestore
          .collection(nasabahCollection)
          .where('idNasabah', isEqualTo: nasabah.idNasabah)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        throw Exception('ID Nasabah ${nasabah.idNasabah} sudah ada');
      }
      final docRef = _firestore.collection(nasabahCollection).doc();
      final data = nasabah.toJson();
      data['id'] = docRef.id;
      await docRef.set(data);
      return nasabah.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Gagal menambah nasabah: $e');
    }
  }

  Future<void> updateNasabah(NasabahBBJModel nasabah) async {
    try {
      final existing = await _firestore
          .collection(nasabahCollection)
          .where('idNasabah', isEqualTo: nasabah.idNasabah)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty && existing.docs.first.id != nasabah.id) {
        throw Exception('ID Nasabah ${nasabah.idNasabah} sudah digunakan');
      }
      await _firestore
          .collection(nasabahCollection)
          .doc(nasabah.id)
          .update(nasabah.toJson());
    } catch (e) {
      throw Exception('Gagal mengupdate nasabah: $e');
    }
  }

  Future<void> deleteNasabah(String id) async {
    try {
      await _firestore.collection(nasabahCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus nasabah: $e');
    }
  }

  Future<void> seedInitialData() async {
    try {
      final existing = await _firestore
          .collection(nasabahCollection)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        throw Exception('Data nasabah sudah ada. Hapus semua data terlebih dahulu sebelum import ulang.');
      }

      final now = DateTime.now();
      final batch = _firestore.batch();
      final seedData = _getSeedData();

      for (final item in seedData) {
        final docRef = _firestore.collection(nasabahCollection).doc();
        final data = {
          'id': docRef.id,
          'idNasabah': item[0],
          'usia': item[1],
          'jenisKelamin': item[2],
          'pekerjaan': item[3],
          'pendapatanBulanan': (item[4] as num).toDouble(),
          'frekuensiTransaksi': item[5],
          'saldoRataRata': (item[6] as num).toDouble(),
          'lamaMenjadiNasabah': item[7],
          'statusNasabah': item[8],
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };
        batch.set(docRef, data);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Gagal import data awal: $e');
    }
  }

  List<List<dynamic>> _getSeedData() {
    return [
      ['NSB6521040085', 31, 'Perempuan', '013 WIRASWASTA', 4500000, 18, 12500000, 9, 'Aktif'],
      ['NSB6521040093', 37, 'Perempuan', '034 IBU RUMAH TANGGA', 2500000, 10, 4500000, 9, 'Aktif'],
      ['NSB6521040107', 37, 'Perempuan', '034 IBU RUMAH TANGGA', 2600000, 11, 4800000, 9, 'Aktif'],
      ['NSB6521040141', 47, 'Perempuan', '013 WIRASWASTA', 6000000, 20, 18000000, 9, 'Aktif'],
      ['NSB6521040328', 41, 'Perempuan', '009 PENGAJAR (GURU, DOSEN)', 5200000, 16, 15000000, 8, 'Aktif'],
      ['NSB6521040352', 27, 'Perempuan', '034 IBU RUMAH TANGGA', 2200000, 9, 3500000, 8, 'Aktif'],
      ['NSB6521040360', 30, 'Perempuan', '034 IBU RUMAH TANGGA', 2400000, 10, 4000000, 8, 'Aktif'],
      ['NSB6521040387', 40, 'Perempuan', '005 ADMINISTRASI UMUM', 4800000, 14, 11000000, 8, 'Aktif'],
      ['NSB6521040409', 30, 'Perempuan', '013 WIRASWASTA', 4200000, 15, 9500000, 8, 'Aktif'],
      ['NSB6521040451', 38, 'Perempuan', '013 WIRASWASTA', 5500000, 17, 14500000, 8, 'Aktif'],
      ['NSB6521040468', 43, 'Laki-laki', '013 WIRASWASTA', 6500000, 21, 20000000, 8, 'Aktif'],
      ['NSB6521040492', 65, 'Perempuan', '013 WIRASWASTA', 4000000, 12, 9000000, 8, 'Aktif'],
      ['NSB6521040549', 35, 'Laki-laki', '013 WIRASWASTA', 5800000, 18, 16000000, 8, 'Aktif'],
      ['NSB6521040557', 27, 'Perempuan', '013 WIRASWASTA', 4300000, 14, 8700000, 8, 'Aktif'],
      ['NSB6521041006', 32, 'Perempuan', '013 WIRASWASTA', 4600000, 13, 9800000, 6, 'Aktif'],
      ['NSB6521041014', 44, 'Laki-laki', '013 WIRASWASTA', 6200000, 19, 17500000, 6, 'Aktif'],
      ['NSB6521041030', 44, 'Laki-laki', '013 WIRASWASTA', 6400000, 20, 18200000, 6, 'Aktif'],
      ['NSB6521041103', 28, 'Laki-laki', '099 LAIN-LAIN', 3200000, 9, 5200000, 6, 'Aktif'],
      ['NSB6521041111', 28, 'Laki-laki', '099 LAIN-LAIN', 3000000, 8, 4800000, 6, 'Aktif'],
      ['NSB6521041121', 24, 'Laki-laki', '099 LAIN-LAIN', 2800000, 7, 4300000, 6, 'Aktif'],
      ['NSB6521041138', 24, 'Laki-laki', '099 LAIN-LAIN', 2900000, 7, 4500000, 6, 'Aktif'],
      ['NSB6521041154', 66, 'Perempuan', '013 WIRASWASTA', 3800000, 11, 8200000, 6, 'Aktif'],
      ['NSB6521041162', 36, 'Laki-laki', '013 WIRASWASTA', 5600000, 17, 15500000, 6, 'Aktif'],
      ['NSB6521041219', 57, 'Perempuan', '034 IBU RUMAH TANGGA', 2600000, 8, 5000000, 6, 'Aktif'],
      ['NSB6521041227', 57, 'Perempuan', '034 IBU RUMAH TANGGA', 2700000, 9, 5200000, 6, 'Aktif'],
      ['NSB6521041375', 61, 'Laki-laki', '013 WIRASWASTA', 4200000, 10, 9200000, 5, 'Aktif'],
      ['NSB6521041391', 34, 'Perempuan', '013 WIRASWASTA', 4800000, 14, 11000000, 5, 'Aktif'],
      ['NSB6521041413', 58, 'Perempuan', '013 WIRASWASTA', 4100000, 10, 8800000, 5, 'Aktif'],
      ['NSB6521041502', 50, 'Perempuan', '035 PEKERJA INFORMAL (ASISTEN RUMAH TANGGA, ASONGAN, DLL)', 3000000, 8, 6000000, 5, 'Aktif'],
      ['NSB6521041553', 40, 'Perempuan', '013 WIRASWASTA', 5300000, 16, 14000000, 5, 'Aktif'],
      ['NSB6521041601', 47, 'Perempuan', '013 WIRASWASTA', 5900000, 18, 16500000, 5, 'Aktif'],
      ['NSB6521041618', 41, 'Perempuan', '013 WIRASWASTA', 5200000, 15, 13000000, 5, 'Aktif'],
      ['NSB6521041626', 30, 'Perempuan', '013 WIRASWASTA', 4500000, 13, 9800000, 5, 'Aktif'],
      ['NSB6521041634', 32, 'Perempuan', '013 WIRASWASTA', 4700000, 14, 10500000, 5, 'Aktif'],
      ['NSB6521041707', 41, 'Laki-laki', '032 BURUH (BURUH PABRIK, BURUH BANGUNAN, BURUH TANI)', 3800000, 9, 7500000, 4, 'Aktif'],
      ['NSB6521041715', 23, 'Perempuan', '099 LAIN-LAIN', 2700000, 6, 4200000, 4, 'Aktif'],
      ['NSB6521041723', 32, 'Perempuan', '099 LAIN-LAIN', 3000000, 7, 4800000, 4, 'Aktif'],
      ['NSB6521041741', 28, 'Perempuan', '013 WIRASWASTA', 4300000, 12, 9000000, 4, 'Aktif'],
      ['NSB6521041766', 29, 'Laki-laki', '032 BURUH (BURUH PABRIK, BURUH BANGUNAN, BURUH TANI)', 3600000, 8, 6800000, 4, 'Aktif'],
      ['NSB6521041774', 28, 'Laki-laki', '099 LAIN-LAIN', 3100000, 7, 5200000, 4, 'Aktif'],
      ['NSB6521041790', 36, 'Perempuan', '034 IBU RUMAH TANGGA', 2600000, 7, 4800000, 4, 'Aktif'],
      ['NSB6521041871', 35, 'Laki-laki', '013 WIRASWASTA', 5400000, 15, 14500000, 4, 'Aktif'],
      ['NSB6521041881', 44, 'Perempuan', '013 WIRASWASTA', 5600000, 12, 12000000, 3, 'Aktif'],
      ['NSB6521041898', 44, 'Perempuan', '013 WIRASWASTA', 5700000, 13, 12500000, 3, 'Aktif'],
      ['NSB6521041952', 31, 'Perempuan', '013 WIRASWASTA', 4500000, 11, 9800000, 3, 'Aktif'],
      ['NSB6521041979', 43, 'Laki-laki', '013 WIRASWASTA', 6000000, 14, 15000000, 3, 'Aktif'],
      ['NSB6521042142', 57, 'Perempuan', '013 WIRASWASTA', 3900000, 9, 8500000, 2, 'Aktif'],
      ['NSB6521042282', 32, 'Laki-laki', '013 WIRASWASTA', 4700000, 6, 8200000, 1, 'Aktif'],
      ['NSB6521042320', 28, 'Perempuan', '034 IBU RUMAH TANGGA', 2400000, 5, 4000000, 1, 'Aktif'],
      ['NSB6521041200', 33, 'Perempuan', '009 PENGAJAR (GURU, DOSEN)', 5000000, 14, 13000000, 6, 'Aktif'],
      ['NSB6521041243', 30, 'Perempuan', '034 IBU RUMAH TANGGA', 2500000, 8, 4600000, 6, 'Aktif'],
      ['NSB6521041332', 28, 'Laki-laki', '013 WIRASWASTA', 4400000, 13, 9500000, 6, 'Aktif'],
      ['NSB6521041677', 20, 'Laki-laki', '099 LAIN-LAIN', 2600000, 6, 3800000, 5, 'Aktif'],
      ['NSB6521041782', 46, 'Perempuan', '013 WIRASWASTA', 5800000, 12, 13500000, 4, 'Aktif'],
      ['NSB6521041847', 30, 'Laki-laki', '026 PENGAMANAN', 3900000, 10, 8000000, 4, 'Aktif'],
      ['NSB6521000016', 54, 'Laki-laki', '013 WIRASWASTA', 4500000, 4, 7200000, 180, 'Pasif'],
      ['NSB6521000024', 63, 'Laki-laki', '013 WIRASWASTA', 4300000, 3, 6900000, 180, 'Pasif'],
      ['NSB6521000040', 63, 'Laki-laki', '013 WIRASWASTA', 4200000, 3, 6800000, 180, 'Pasif'],
      ['NSB6521000067', 63, 'Laki-laki', '034 IBU RUMAH TANGGA', 2400000, 2, 3600000, 180, 'Pasif'],
      ['NSB6521000075', 63, 'Laki-laki', '013 WIRASWASTA', 4100000, 3, 6700000, 180, 'Pasif'],
      ['NSB6521000083', 63, 'Laki-laki', '013 WIRASWASTA', 4000000, 3, 6600000, 180, 'Pasif'],
      ['NSB6521000091', 63, 'Perempuan', '034 IBU RUMAH TANGGA', 2500000, 2, 3800000, 180, 'Pasif'],
      ['NSB6521000121', 63, 'Laki-laki', '034 IBU RUMAH TANGGA', 2400000, 2, 3700000, 180, 'Pasif'],
      ['NSB6521000131', 63, 'Laki-laki', '013 WIRASWASTA', 4200000, 3, 6800000, 180, 'Pasif'],
      ['NSB6521000148', 63, 'Perempuan', '034 IBU RUMAH TANGGA', 2500000, 2, 3900000, 180, 'Pasif'],
      ['NSB6521000164', 63, 'Laki-laki', '013 WIRASWASTA', 4300000, 3, 7000000, 180, 'Pasif'],
      ['NSB6521000172', 63, 'Laki-laki', '013 WIRASWASTA', 4200000, 3, 6900000, 180, 'Pasif'],
      ['NSB6521000180', 63, 'Laki-laki', '013 WIRASWASTA', 4100000, 3, 6800000, 180, 'Pasif'],
      ['NSB6521000199', 66, 'Laki-laki', '007 KONSULTAN/ANALIS', 6000000, 4, 12000000, 180, 'Pasif'],
      ['NSB6521000202', 63, 'Laki-laki', '013 WIRASWASTA', 4200000, 3, 6900000, 180, 'Pasif'],
      ['NSB6521000210', 63, 'Laki-laki', '013 WIRASWASTA', 4300000, 3, 7000000, 180, 'Pasif'],
      ['NSB6521000229', 63, 'Laki-laki', '013 WIRASWASTA', 4400000, 3, 7100000, 180, 'Pasif'],
      ['NSB6521000350', 54, 'Laki-laki', '099 LAIN-LAIN', 3500000, 4, 6000000, 180, 'Pasif'],
      ['NSB6521000415', 63, 'Perempuan', '034 IBU RUMAH TANGGA', 2600000, 2, 4000000, 180, 'Pasif'],
      ['NSB6521000458', 51, 'Laki-laki', '099 LAIN-LAIN', 3600000, 4, 6200000, 180, 'Pasif'],
      ['NSB6521000466', 63, 'Laki-laki', '013 WIRASWASTA', 4300000, 3, 7000000, 180, 'Pasif'],
      ['NSB6521000482', 47, 'Laki-laki', '099 LAIN-LAIN', 3400000, 3, 5800000, 144, 'Pasif'],
      ['NSB6521000504', 63, 'Laki-laki', '013 WIRASWASTA', 4200000, 3, 6900000, 180, 'Pasif'],
      ['NSB6521000520', 40, 'Laki-laki', '099 LAIN-LAIN', 3800000, 6, 7500000, 177, 'Aktif'],
      ['NSB6521000539', 63, 'Laki-laki', '013 WIRASWASTA', 4300000, 3, 7000000, 180, 'Pasif'],
      ['NSB6521000547', 75, 'Laki-laki', '099 LAIN-LAIN', 3000000, 2, 5000000, 153, 'Pasif'],
      ['NSB6521000555', 63, 'Laki-laki', '013 WIRASWASTA', 4200000, 3, 6900000, 180, 'Pasif'],
      ['NSB6521000581', 52, 'Perempuan', '013 WIRASWASTA', 4800000, 6, 9800000, 180, 'Aktif'],
      ['NSB6521000598', 42, 'Laki-laki', '013 WIRASWASTA', 5200000, 4, 9500000, 166, 'Pasif'],
      ['NSB6521000695', 49, 'Perempuan', '034 IBU RUMAH TANGGA', 2700000, 3, 4200000, 180, 'Pasif'],
      ['NSB6521000741', 63, 'Laki-laki', '013 WIRASWASTA', 4300000, 3, 7000000, 180, 'Pasif'],
      ['NSB6521000768', 48, 'Perempuan', '099 LAIN-LAIN', 3200000, 4, 5600000, 180, 'Aktif'],
      ['NSB6521000814', 63, 'Perempuan', '034 IBU RUMAH TANGGA', 2600000, 2, 4000000, 180, 'Pasif'],
      ['NSB6521000822', 62, 'Perempuan', '034 IBU RUMAH TANGGA', 2700000, 3, 4200000, 180, 'Aktif'],
      ['NSB6521000857', 53, 'Laki-laki', '013 WIRASWASTA', 4500000, 4, 7800000, 180, 'Pasif'],
      ['NSB6521000873', 67, 'Laki-laki', '013 WIRASWASTA', 4100000, 3, 6900000, 180, 'Pasif'],
      ['NSB6521000881', 63, 'Perempuan', '034 IBU RUMAH TANGGA', 2600000, 2, 4000000, 180, 'Pasif'],
      ['NSB6521000903', 45, 'Perempuan', '034 IBU RUMAH TANGGA', 2800000, 3, 4600000, 180, 'Pasif'],
      ['NSB6521000911', 49, 'Perempuan', '034 IBU RUMAH TANGGA', 2900000, 3, 4800000, 180, 'Pasif'],
      ['NSB6521000921', 64, 'Laki-laki', '013 WIRASWASTA', 4200000, 3, 7000000, 180, 'Pasif'],
      ['NSB6521000946', 38, 'Laki-laki', '013 WIRASWASTA', 5000000, 4, 9000000, 168, 'Pasif'],
      ['NSB6521000989', 40, 'Laki-laki', '013 WIRASWASTA', 5200000, 4, 9500000, 180, 'Pasif'],
      ['NSB6521000997', 63, 'Laki-laki', '013 WIRASWASTA', 4300000, 3, 7000000, 180, 'Pasif'],
      ['NSB6521001012', 46, 'Laki-laki', '013 WIRASWASTA', 5400000, 4, 9800000, 180, 'Pasif'],
      ['NSB6521001020', 63, 'Perempuan', '034 IBU RUMAH TANGGA', 2600000, 2, 4000000, 180, 'Pasif'],
    ];
  }
}
