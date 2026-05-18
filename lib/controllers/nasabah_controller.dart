import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/nasabah_bbj_model.dart';
import '../data/services/nasabah_service.dart';

class NasabahController extends GetxController {
  final NasabahService _nasabahService = NasabahService();

  final RxList<NasabahBBJModel> nasabahList = <NasabahBBJModel>[].obs;
  final RxList<NasabahBBJModel> filteredList = <NasabahBBJModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSeeding = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterStatus = 'Semua'.obs;

  @override
  void onInit() {
    super.onInit();
    loadNasabah();
    ever(searchQuery, (_) => _applyFilter());
    ever(filterStatus, (_) => _applyFilter());
  }

  Future<void> loadNasabah() async {
    isLoading.value = true;
    try {
      final data = await _nasabahService.getAllNasabah();
      nasabahList.assignAll(data);
      _applyFilter();
    } catch (e) {
      _showError('Gagal memuat data nasabah: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    var result = nasabahList.toList();
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((n) {
        return n.idNasabah.toLowerCase().contains(q) ||
            n.pekerjaan.toLowerCase().contains(q);
      }).toList();
    }
    if (filterStatus.value != 'Semua') {
      result = result.where((n) => n.statusNasabah == filterStatus.value).toList();
    }
    filteredList.assignAll(result);
  }

  Future<bool> addNasabah(NasabahBBJModel nasabah) async {
    isLoading.value = true;
    try {
      final added = await _nasabahService.addNasabah(nasabah);
      nasabahList.add(added);
      _applyFilter();
      Get.snackbar('Berhasil', 'Nasabah berhasil ditambahkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      return true;
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateNasabah(NasabahBBJModel nasabah) async {
    isLoading.value = true;
    try {
      await _nasabahService.updateNasabah(nasabah);
      final index = nasabahList.indexWhere((n) => n.id == nasabah.id);
      if (index >= 0) {
        nasabahList[index] = nasabah;
        _applyFilter();
      }
      Get.snackbar('Berhasil', 'Data nasabah berhasil diupdate',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      return true;
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteNasabah(String id) async {
    isLoading.value = true;
    try {
      await _nasabahService.deleteNasabah(id);
      nasabahList.removeWhere((n) => n.id == id);
      _applyFilter();
      Get.snackbar('Berhasil', 'Nasabah berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      return true;
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> seedData() async {
    isSeeding.value = true;
    try {
      await _nasabahService.seedInitialData();
      await loadNasabah();
      Get.snackbar('Berhasil', '${nasabahList.length} data nasabah berhasil diimport',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3));
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isSeeding.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar('Error', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3));
  }

  int get jumlahAktif => nasabahList.where((n) => n.statusNasabah == 'Aktif').length;
  int get jumlahPasif => nasabahList.where((n) => n.statusNasabah == 'Pasif').length;
}
