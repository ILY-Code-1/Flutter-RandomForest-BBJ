import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/nasabah_controller.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/nasabah_bbj_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddEditNasabahScreen extends StatefulWidget {
  final NasabahBBJModel? nasabah;

  const AddEditNasabahScreen({super.key, this.nasabah});

  @override
  State<AddEditNasabahScreen> createState() => _AddEditNasabahScreenState();
}

class _AddEditNasabahScreenState extends State<AddEditNasabahScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _usiaController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _pendapatanController = TextEditingController();
  final _frekuensiController = TextEditingController();
  final _saldoController = TextEditingController();
  final _lamaController = TextEditingController();

  String _jenisKelamin = 'Laki-laki';
  String _statusNasabah = 'Aktif';

  bool get isEdit => widget.nasabah != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final n = widget.nasabah!;
      _idController.text = n.idNasabah;
      _usiaController.text = n.usia.toString();
      _pekerjaanController.text = n.pekerjaan;
      _pendapatanController.text = n.pendapatanBulanan.toStringAsFixed(0);
      _frekuensiController.text = n.frekuensiTransaksi.toString();
      _saldoController.text = n.saldoRataRata.toStringAsFixed(0);
      _lamaController.text = n.lamaMenjadiNasabah.toString();
      _jenisKelamin = n.jenisKelamin;
      _statusNasabah = n.statusNasabah;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _usiaController.dispose();
    _pekerjaanController.dispose();
    _pendapatanController.dispose();
    _frekuensiController.dispose();
    _saldoController.dispose();
    _lamaController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<NasabahController>();
    final now = DateTime.now();

    final nasabah = NasabahBBJModel(
      id: isEdit ? widget.nasabah!.id : '',
      idNasabah: _idController.text.trim(),
      usia: int.parse(_usiaController.text.trim()),
      jenisKelamin: _jenisKelamin,
      pekerjaan: _pekerjaanController.text.trim(),
      pendapatanBulanan: double.parse(_pendapatanController.text.trim()),
      frekuensiTransaksi: int.parse(_frekuensiController.text.trim()),
      saldoRataRata: double.parse(_saldoController.text.trim()),
      lamaMenjadiNasabah: int.parse(_lamaController.text.trim()),
      statusNasabah: _statusNasabah,
      createdAt: isEdit ? widget.nasabah!.createdAt : now,
      updatedAt: now,
    );

    bool success;
    if (isEdit) {
      success = await controller.updateNasabah(nasabah);
    } else {
      success = await controller.addNasabah(nasabah);
    }

    if (success) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NasabahController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: isEdit ? 'Edit Nasabah' : 'Tambah Nasabah',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _idController,
              label: 'ID Nasabah',
              hint: 'Contoh: NSB6521040085',
              readOnly: isEdit,
              validator: (v) => (v == null || v.isEmpty) ? 'ID tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _usiaController,
              label: 'Usia',
              hint: 'Contoh: 35',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Usia tidak boleh kosong';
                if (int.tryParse(v) == null) return 'Usia harus berupa angka';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Jenis Kelamin',
              value: _jenisKelamin,
              items: const ['Laki-laki', 'Perempuan'],
              onChanged: (v) => setState(() => _jenisKelamin = v!),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _pekerjaanController,
              label: 'Pekerjaan',
              hint: 'Contoh: 013 WIRASWASTA',
              validator: (v) => (v == null || v.isEmpty) ? 'Pekerjaan tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _pendapatanController,
              label: 'Pendapatan Bulanan (Rp)',
              hint: 'Contoh: 5000000',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Pendapatan tidak boleh kosong';
                if (double.tryParse(v) == null) return 'Pendapatan harus berupa angka';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _frekuensiController,
              label: 'Frekuensi Transaksi (per bulan)',
              hint: 'Contoh: 12',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Frekuensi tidak boleh kosong';
                if (int.tryParse(v) == null) return 'Frekuensi harus berupa angka';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _saldoController,
              label: 'Saldo Rata-rata (Rp/bulan)',
              hint: 'Contoh: 8000000',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Saldo tidak boleh kosong';
                if (double.tryParse(v) == null) return 'Saldo harus berupa angka';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _lamaController,
              label: 'Lama Menjadi Nasabah (bulan)',
              hint: 'Contoh: 5',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Lama nasabah tidak boleh kosong';
                if (int.tryParse(v) == null) return 'Lama nasabah harus berupa angka';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Status Nasabah',
              value: _statusNasabah,
              items: const ['Aktif', 'Pasif'],
              onChanged: (v) => setState(() => _statusNasabah = v!),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pastikan data nasabah sudah benar sebelum disimpan.',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => CustomButton(
                  text: isEdit ? 'Simpan Perubahan' : 'Tambah Nasabah',
                  onPressed: controller.isLoading.value ? null : _handleSave,
                  isLoading: controller.isLoading.value,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
