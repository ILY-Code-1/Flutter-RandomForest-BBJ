// File: prediction_controller.dart
// GetX Controller untuk mengelola state prediksi nasabah dengan SQLite

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import '../data/models/prediction_model.dart';
import '../data/services/database_service.dart';
import '../data/services/firestore_service.dart';
import '../data/services/random_forest_service.dart';
import '../routes/app_routes.dart';
import 'auth_controller.dart';

class PredictionController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  final FirestoreService _firestoreService = FirestoreService();
  final RandomForestService _rfService = RandomForestService();

  final RxList<PredictionSessionModel> predictionSessions = <PredictionSessionModel>[].obs;
  final RxList<NasabahInputModel> tempNasabahList = <NasabahInputModel>[].obs;
  final RxList<String> tempIdNasabahList = <String>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final RxInt editingIndex = (-1).obs;

  // Excel related variables
  final RxString excelFileName = ''.obs;
  final RxList<Map<String, dynamic>> excelData = <Map<String, dynamic>>[].obs;

  // Form controllers
  final idNasabahController = TextEditingController();
  final usiaController = TextEditingController();
  final pekerjaanController = TextEditingController();
  final pendapatanController = TextEditingController();
  final frekuensiController = TextEditingController();
  final saldoController = TextEditingController();
  final lamaController = TextEditingController();

  final RxString jenisKelamin = 'Laki-laki'.obs;
  final RxString statusNasabah = 'Aktif'.obs;

  final Rx<PredictionSessionModel?> currentSession = Rx<PredictionSessionModel?>(null);

  int get totalSessions => predictionSessions.length;

  int get totalNasabahAktif {
    int count = 0;
    for (var session in predictionSessions) {
      count += session.nasabahAktif;
    }
    return count;
  }

  int get totalNasabahTidakAktif {
    int count = 0;
    for (var session in predictionSessions) {
      count += session.nasabahTidakAktif;
    }
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  @override
  void onClose() {
    idNasabahController.dispose();
    usiaController.dispose();
    pekerjaanController.dispose();
    pendapatanController.dispose();
    frekuensiController.dispose();
    saldoController.dispose();
    lamaController.dispose();
    super.onClose();
  }

  Future<void> loadSessions() async {
    isLoading.value = true;
    try {
      // Try to get AuthController
      final authController = Get.isRegistered<AuthController>() 
          ? Get.find<AuthController>() 
          : null;
      final currentUser = authController?.currentUser.value;

      List<PredictionSessionModel> sessions = [];

      if (currentUser != null) {
        // Load from Firestore based on role
        if (currentUser.isAdmin) {
          sessions = await _firestoreService.getAllPredictions();
        } else {
          sessions = await _firestoreService.getUserPredictions(currentUser.id);
        }
        
        // Save to SQLite for offline access
        for (var session in sessions) {
          await _dbService.insertSession(session);
        }
      } else {
        // Fallback to SQLite if no user (offline mode)
        sessions = await _dbService.getAllSessions();
        if (sessions.isEmpty) {
          await _createInitialSampleData();
          sessions = await _dbService.getAllSessions();
        }
      }

      predictionSessions.assignAll(sessions);
    } catch (e) {
      _showError('Gagal memuat data: $e');
      // Try fallback to SQLite on error
      try {
        final localSessions = await _dbService.getAllSessions();
        predictionSessions.assignAll(localSessions);
      } catch (e2) {
        _showError('Gagal memuat data lokal: $e2');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createInitialSampleData() async {
    final sampleData = [
      {'id': 'NSB001', 'usia': 35, 'gender': 'Laki-laki', 'pekerjaan': 'Wiraswasta', 'pendapatan': 8000000.0, 'frekuensi': 15, 'saldo': 5000000.0, 'lama': 3, 'status': 'Aktif'},
      {'id': 'NSB002', 'usia': 28, 'gender': 'Perempuan', 'pekerjaan': 'Karyawan Swasta', 'pendapatan': 5500000.0, 'frekuensi': 12, 'saldo': 3500000.0, 'lama': 2, 'status': 'Aktif'},
      {'id': 'NSB003', 'usia': 45, 'gender': 'Laki-laki', 'pekerjaan': 'PNS', 'pendapatan': 10000000.0, 'frekuensi': 20, 'saldo': 15000000.0, 'lama': 5, 'status': 'Aktif'},
      {'id': 'NSB004', 'usia': 22, 'gender': 'Perempuan', 'pekerjaan': 'Mahasiswa', 'pendapatan': 1500000.0, 'frekuensi': 3, 'saldo': 500000.0, 'lama': 1, 'status': 'Pasif'},
      {'id': 'NSB005', 'usia': 50, 'gender': 'Laki-laki', 'pekerjaan': 'Pengusaha', 'pendapatan': 25000000.0, 'frekuensi': 30, 'saldo': 50000000.0, 'lama': 8, 'status': 'Aktif'},
      {'id': 'NSB006', 'usia': 32, 'gender': 'Perempuan', 'pekerjaan': 'Dokter', 'pendapatan': 15000000.0, 'frekuensi': 18, 'saldo': 20000000.0, 'lama': 4, 'status': 'Aktif'},
      {'id': 'NSB007', 'usia': 40, 'gender': 'Laki-laki', 'pekerjaan': 'Guru', 'pendapatan': 6000000.0, 'frekuensi': 10, 'saldo': 4000000.0, 'lama': 6, 'status': 'Aktif'},
      {'id': 'NSB008', 'usia': 26, 'gender': 'Perempuan', 'pekerjaan': 'Freelancer', 'pendapatan': 4000000.0, 'frekuensi': 5, 'saldo': 2000000.0, 'lama': 1, 'status': 'Pasif'},
      {'id': 'NSB009', 'usia': 55, 'gender': 'Laki-laki', 'pekerjaan': 'Pensiunan', 'pendapatan': 8000000.0, 'frekuensi': 8, 'saldo': 30000000.0, 'lama': 10, 'status': 'Aktif'},
      {'id': 'NSB010', 'usia': 30, 'gender': 'Perempuan', 'pekerjaan': 'Karyawan Bank', 'pendapatan': 9000000.0, 'frekuensi': 25, 'saldo': 12000000.0, 'lama': 3, 'status': 'Aktif'},
      {'id': 'NSB011', 'usia': 38, 'gender': 'Laki-laki', 'pekerjaan': 'Kontraktor', 'pendapatan': 12000000.0, 'frekuensi': 14, 'saldo': 8000000.0, 'lama': 4, 'status': 'Aktif'},
      {'id': 'NSB012', 'usia': 24, 'gender': 'Perempuan', 'pekerjaan': 'Kasir', 'pendapatan': 3000000.0, 'frekuensi': 4, 'saldo': 1000000.0, 'lama': 1, 'status': 'Pasif'},
      {'id': 'NSB013', 'usia': 48, 'gender': 'Laki-laki', 'pekerjaan': 'Dosen', 'pendapatan': 11000000.0, 'frekuensi': 16, 'saldo': 18000000.0, 'lama': 7, 'status': 'Aktif'},
      {'id': 'NSB014', 'usia': 29, 'gender': 'Perempuan', 'pekerjaan': 'Perawat', 'pendapatan': 5000000.0, 'frekuensi': 9, 'saldo': 3000000.0, 'lama': 2, 'status': 'Aktif'},
      {'id': 'NSB015', 'usia': 60, 'gender': 'Laki-laki', 'pekerjaan': 'Petani', 'pendapatan': 4000000.0, 'frekuensi': 2, 'saldo': 6000000.0, 'lama': 15, 'status': 'Pasif'},
      {'id': 'NSB016', 'usia': 33, 'gender': 'Perempuan', 'pekerjaan': 'Desainer', 'pendapatan': 7000000.0, 'frekuensi': 11, 'saldo': 5500000.0, 'lama': 3, 'status': 'Aktif'},
      {'id': 'NSB017', 'usia': 42, 'gender': 'Laki-laki', 'pekerjaan': 'Pedagang', 'pendapatan': 6500000.0, 'frekuensi': 22, 'saldo': 4500000.0, 'lama': 5, 'status': 'Aktif'},
      {'id': 'NSB018', 'usia': 27, 'gender': 'Perempuan', 'pekerjaan': 'Admin', 'pendapatan': 4500000.0, 'frekuensi': 6, 'saldo': 2500000.0, 'lama': 2, 'status': 'Pasif'},
      {'id': 'NSB019', 'usia': 52, 'gender': 'Laki-laki', 'pekerjaan': 'Manager', 'pendapatan': 18000000.0, 'frekuensi': 28, 'saldo': 35000000.0, 'lama': 9, 'status': 'Aktif'},
      {'id': 'NSB020', 'usia': 36, 'gender': 'Perempuan', 'pekerjaan': 'Akuntan', 'pendapatan': 8500000.0, 'frekuensi': 13, 'saldo': 7000000.0, 'lama': 4, 'status': 'Aktif'},
    ];

    final now = DateTime.now();
    final sessionId = now.millisecondsSinceEpoch.toString();
    List<NasabahModel> hasilPrediksi = [];

    for (int i = 0; i < sampleData.length; i++) {
      final data = sampleData[i];
      final input = NasabahInputModel(
        usia: data['usia'] as int,
        jenisKelamin: data['gender'] as String,
        pekerjaan: data['pekerjaan'] as String,
        pendapatanBulanan: data['pendapatan'] as double,
        frekuensiTransaksi: data['frekuensi'] as int,
        saldoRataRata: data['saldo'] as double,
        lamaMenjadiNasabah: data['lama'] as int,
        statusNasabah: data['status'] as String,
      );

      final hasil = _rfService.predict(input, '${sessionId}_$i', data['id'] as String);
      hasilPrediksi.add(hasil);
    }

    int benar = hasilPrediksi.where((n) => n.evaluasi == 'Benar').length;
    double akurasi = (benar / hasilPrediksi.length) * 100;

    final authController = Get.isRegistered<AuthController>() 
        ? Get.find<AuthController>() 
        : null;
    final currentUser = authController?.currentUser.value;

    final session = PredictionSessionModel(
      id: sessionId,
      tanggalPrediksi: now,
      nasabahList: hasilPrediksi,
      akurasi: akurasi,
      createdBy: currentUser?.id ?? '',
      assignedUserIds: [],
      comments: [],
    );

    await _saveSession(session);
  }

  void addNasabahToTemp() {
    if (!validateForm()) return;

    final input = NasabahInputModel(
      usia: int.tryParse(usiaController.text) ?? 0,
      jenisKelamin: jenisKelamin.value,
      pekerjaan: pekerjaanController.text,
      pendapatanBulanan: double.tryParse(pendapatanController.text) ?? 0,
      frekuensiTransaksi: int.tryParse(frekuensiController.text) ?? 0,
      saldoRataRata: double.tryParse(saldoController.text) ?? 0,
      lamaMenjadiNasabah: int.tryParse(lamaController.text) ?? 0,
      statusNasabah: statusNasabah.value,
    );

    tempNasabahList.add(input);
    tempIdNasabahList.add(idNasabahController.text);
    clearForm();

    Get.snackbar(
      'Berhasil',
      'Nasabah berhasil ditambahkan ke daftar',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void updateNasabahInTemp() {
    if (!validateForm()) return;
    if (editingIndex.value < 0) return;

    final input = NasabahInputModel(
      usia: int.tryParse(usiaController.text) ?? 0,
      jenisKelamin: jenisKelamin.value,
      pekerjaan: pekerjaanController.text,
      pendapatanBulanan: double.tryParse(pendapatanController.text) ?? 0,
      frekuensiTransaksi: int.tryParse(frekuensiController.text) ?? 0,
      saldoRataRata: double.tryParse(saldoController.text) ?? 0,
      lamaMenjadiNasabah: int.tryParse(lamaController.text) ?? 0,
      statusNasabah: statusNasabah.value,
    );

    tempNasabahList[editingIndex.value] = input;
    tempIdNasabahList[editingIndex.value] = idNasabahController.text;

    clearForm();
    isEditMode.value = false;
    editingIndex.value = -1;

    Get.snackbar(
      'Berhasil',
      'Data nasabah berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void setEditModeFromTemp(int index) {
    if (index < 0 || index >= tempNasabahList.length) return;

    final input = tempNasabahList[index];
    editingIndex.value = index;
    isEditMode.value = true;

    idNasabahController.text = tempIdNasabahList[index];
    usiaController.text = input.usia.toString();
    jenisKelamin.value = input.jenisKelamin;
    pekerjaanController.text = input.pekerjaan;
    pendapatanController.text = input.pendapatanBulanan.toStringAsFixed(0);
    frekuensiController.text = input.frekuensiTransaksi.toString();
    saldoController.text = input.saldoRataRata.toStringAsFixed(0);
    lamaController.text = input.lamaMenjadiNasabah.toString();
    statusNasabah.value = input.statusNasabah;
  }

  void removeNasabahFromTemp(int index) {
    if (index >= 0 && index < tempNasabahList.length) {
      tempNasabahList.removeAt(index);
      tempIdNasabahList.removeAt(index);
    }
  }

  Future<void> submitPrediction() async {
    if (tempNasabahList.isEmpty) {
      _showError('Tambahkan minimal 1 data nasabah terlebih dahulu');
      return;
    }

    isLoading.value = true;

    try {
      final now = DateTime.now();
      final sessionId = now.millisecondsSinceEpoch.toString();

      List<NasabahModel> hasilPrediksi = [];

      for (int i = 0; i < tempNasabahList.length; i++) {
        final input = tempNasabahList[i];
        final idNasabah = tempIdNasabahList[i];
        final id = '${sessionId}_$i';

        final hasil = _rfService.predict(input, id, idNasabah);
        hasilPrediksi.add(hasil);
      }

      int benar = hasilPrediksi.where((n) => n.evaluasi == 'Benar').length;
      double akurasi = (benar / hasilPrediksi.length) * 100;

      final authController = Get.isRegistered<AuthController>() 
          ? Get.find<AuthController>() 
          : null;
      final currentUser = authController?.currentUser.value;

      final session = PredictionSessionModel(
        id: sessionId,
        tanggalPrediksi: now,
        nasabahList: hasilPrediksi,
        akurasi: akurasi,
        createdBy: currentUser?.id ?? '',
        assignedUserIds: [],
        comments: [],
      );

      await _saveSession(session);
      predictionSessions.insert(0, session);
      currentSession.value = session;

      tempNasabahList.clear();
      tempIdNasabahList.clear();
      clearForm();

      Get.snackbar(
        'Berhasil',
        'Prediksi berhasil disimpan dengan akurasi ${akurasi.toStringAsFixed(1)}%',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      Get.toNamed(AppRoutes.detail);

    } catch (e) {
      _showError('Gagal menyimpan prediksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      // Delete from Firestore
      try {
        await _firestoreService.deletePrediction(id);
      } catch (e) {
        // Continue even if Firestore delete fails (offline mode)
      }

      // Delete from SQLite
      await _dbService.deleteSession(id);
      predictionSessions.removeWhere((s) => s.id == id);

      Get.snackbar(
        'Berhasil',
        'Riwayat prediksi berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _showError('Gagal menghapus: $e');
    }
  }

  void setCurrentSession(PredictionSessionModel session) {
    currentSession.value = session;
  }

  void clearForm() {
    idNasabahController.clear();
    usiaController.clear();
    pekerjaanController.clear();
    pendapatanController.clear();
    frekuensiController.clear();
    saldoController.clear();
    lamaController.clear();
    jenisKelamin.value = 'Laki-laki';
    statusNasabah.value = 'Aktif';
    isEditMode.value = false;
    editingIndex.value = -1;
  }

  void clearAllTemp() {
    tempNasabahList.clear();
    tempIdNasabahList.clear();
    clearForm();
  }

  bool validateForm() {
    if (idNasabahController.text.isEmpty) {
      _showError('ID Nasabah tidak boleh kosong');
      return false;
    }
    if (usiaController.text.isEmpty) {
      _showError('Usia tidak boleh kosong');
      return false;
    }
    if (pekerjaanController.text.isEmpty) {
      _showError('Pekerjaan tidak boleh kosong');
      return false;
    }
    if (pendapatanController.text.isEmpty) {
      _showError('Pendapatan bulanan tidak boleh kosong');
      return false;
    }
    if (frekuensiController.text.isEmpty) {
      _showError('Frekuensi transaksi tidak boleh kosong');
      return false;
    }
    if (saldoController.text.isEmpty) {
      _showError('Saldo rata-rata tidak boleh kosong');
      return false;
    }
    if (lamaController.text.isEmpty) {
      _showError('Lama menjadi nasabah tidak boleh kosong');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _saveSession(PredictionSessionModel session) async {
    try {
      // Save to Firestore
      await _firestoreService.savePredictionSession(session);
    } catch (e) {
      // Continue even if Firestore save fails (offline mode)
      print('Failed to save to Firestore: $e');
    }

    // Save to SQLite
    await _dbService.insertSession(session);
  }

  String getTempNasabahInfo(int index) {
    if (index < 0 || index >= tempNasabahList.length) return '';
    final n = tempNasabahList[index];
    return '${n.pekerjaan} - ${n.statusNasabah}';
  }

  String getTempIdNasabah(int index) {
    if (index < 0 || index >= tempIdNasabahList.length) return '';
    return tempIdNasabahList[index];
  }

  // Excel Import Methods
  Future<void> pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        excelFileName.value = result.files.single.name;
        await _readExcelFile(filePath);
      }
    } catch (e) {
      _showError('Gagal memilih file: $e');
    }
  }

  Future<void> _readExcelFile(String filePath) async {
    isLoading.value = true;
    try {
      final bytes = File(filePath).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      excelData.clear();

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        // Skip header row, start from row 1 (index 1)
        for (var i = 1; i < sheet.maxRows; i++) {
          final row = sheet.rows[i];
          
          // Check if row has enough columns and is not empty
          if (row.length < 9) continue;
          
          // Skip if ID Nasabah is empty
          if (row[0]?.value == null) continue;

          try {
            final data = {
              'idNasabah': _getCellValue(row[0]),
              'usia': _parseToInt(_getCellValue(row[1])),
              'jenisKelamin': _getCellValue(row[2]),
              'pekerjaan': _getCellValue(row[3]),
              'pendapatanBulanan': _parseToDouble(_getCellValue(row[4])),
              'frekuensiTransaksi': _parseToInt(_getCellValue(row[5])),
              'saldoRataRata': _parseToDouble(_getCellValue(row[6])),
              'lamaMenjadiNasabah': _parseToInt(_getCellValue(row[7])),
              'statusNasabah': _getCellValue(row[8]),
            };

            // Validate required fields
            if (_validateExcelRow(data)) {
              excelData.add(data);
            }
          } catch (e) {
            // Skip invalid rows
            continue;
          }
        }
      }

      if (excelData.isEmpty) {
        _showError('Tidak ada data valid yang ditemukan dalam file Excel');
        excelFileName.value = '';
      } else {
        Get.snackbar(
          'Berhasil',
          '${excelData.length} data nasabah berhasil dibaca',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _showError('Gagal membaca file Excel: $e');
      excelFileName.value = '';
      excelData.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String _getCellValue(Data? cell) {
    if (cell == null || cell.value == null) return '';
    return cell.value.toString().trim();
  }

  int _parseToInt(String value) {
    if (value.isEmpty) return 0;
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  double _parseToDouble(String value) {
    if (value.isEmpty) return 0.0;
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  bool _validateExcelRow(Map<String, dynamic> data) {
    if (data['idNasabah'].toString().isEmpty) return false;
    if (data['usia'] == 0) return false;
    if (data['jenisKelamin'].toString().isEmpty) return false;
    if (data['pekerjaan'].toString().isEmpty) return false;
    if (data['pendapatanBulanan'] == 0) return false;
    if (data['frekuensiTransaksi'] == 0) return false;
    if (data['saldoRataRata'] == 0) return false;
    if (data['lamaMenjadiNasabah'] == 0) return false;
    if (data['statusNasabah'].toString().isEmpty) return false;
    
    // Validate gender
    final gender = data['jenisKelamin'].toString();
    if (gender != 'Laki-laki' && gender != 'Perempuan') return false;
    
    // Validate status
    final status = data['statusNasabah'].toString();
    if (status != 'Aktif' && status != 'Pasif') return false;
    
    return true;
  }

  Future<void> submitExcelPrediction() async {
    if (excelData.isEmpty) {
      _showError('Tidak ada data untuk diproses');
      return;
    }

    isLoading.value = true;

    try {
      final now = DateTime.now();
      final sessionId = now.millisecondsSinceEpoch.toString();

      List<NasabahModel> hasilPrediksi = [];

      for (int i = 0; i < excelData.length; i++) {
        final data = excelData[i];
        
        final input = NasabahInputModel(
          usia: data['usia'] as int,
          jenisKelamin: data['jenisKelamin'] as String,
          pekerjaan: data['pekerjaan'] as String,
          pendapatanBulanan: data['pendapatanBulanan'] as double,
          frekuensiTransaksi: data['frekuensiTransaksi'] as int,
          saldoRataRata: data['saldoRataRata'] as double,
          lamaMenjadiNasabah: data['lamaMenjadiNasabah'] as int,
          statusNasabah: data['statusNasabah'] as String,
        );

        final id = '${sessionId}_$i';
        final idNasabah = data['idNasabah'] as String;

        final hasil = _rfService.predict(input, id, idNasabah);
        hasilPrediksi.add(hasil);
      }

      int benar = hasilPrediksi.where((n) => n.evaluasi == 'Benar').length;
      double akurasi = (benar / hasilPrediksi.length) * 100;

      final authController = Get.isRegistered<AuthController>() 
          ? Get.find<AuthController>() 
          : null;
      final currentUser = authController?.currentUser.value;

      final session = PredictionSessionModel(
        id: sessionId,
        tanggalPrediksi: now,
        nasabahList: hasilPrediksi,
        akurasi: akurasi,
        createdBy: currentUser?.id ?? '',
        assignedUserIds: [],
        comments: [],
      );

      await _saveSession(session);
      predictionSessions.insert(0, session);
      currentSession.value = session;

      // Clear Excel data
      clearExcelData();

      Get.snackbar(
        'Berhasil',
        'Prediksi berhasil disimpan dengan akurasi ${akurasi.toStringAsFixed(1)}%',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      Get.toNamed(AppRoutes.detail);

    } catch (e) {
      _showError('Gagal menyimpan prediksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearExcelData() {
    excelFileName.value = '';
    excelData.clear();
  }
}
