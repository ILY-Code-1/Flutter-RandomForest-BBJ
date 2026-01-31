// File: add_edit_user_screen.dart
// Halaman untuk menambah atau mengedit user

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';

class AddEditUserScreen extends StatefulWidget {
  final UserModel? user;

  const AddEditUserScreen({super.key, this.user});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'admin'; // Default value yang valid

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _namaController.text = widget.user!.nama;
      _emailController.text = widget.user!.email;
      _selectedRole = widget.user!.role;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final authController = Get.find<AuthController>();
      bool success;

      if (isEdit) {
        // Update user
        success = await authController.updateUser(
          widget.user!.id,
          nama: _namaController.text,
          role: _selectedRole,
        );
      } else {
        // Create new user
        success = await authController.createUser(
          email: _emailController.text,
          password: _passwordController.text,
          nama: _namaController.text,
          role: _selectedRole,
        );
      }

      if (success) {
        Get.back(result: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: CustomAppBar(title: isEdit ? 'Edit User' : 'Tambah User'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nama
            CustomTextField(
              controller: _namaController,
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Masukkan email',
              keyboardType: TextInputType.emailAddress,
              readOnly: isEdit, // Email tidak bisa diubah saat edit
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!value.contains('@')) {
                  return 'Email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password (hanya untuk create)
            if (!isEdit) ...[
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Masukkan password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Role
            CustomDropdown(
              label: 'Role',
              value: _selectedRole,
              items: const ['admin', 'marketing'],
              onChanged: (value) {
                setState(() => _selectedRole = value.toString());
              },
              itemLabel: (String role) {
                switch (role) {
                  case 'admin':
                    return 'Admin';
                  case 'marketing':
                    return 'Marketing';
                  default:
                    return '';
                }
              },
            ),
            const SizedBox(height: 24),

            // Info box
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
                      'Admin: Akses penuh ke semua fitur\nMarketing: Hanya bisa melihat prediksi yang di-assign',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            Obx(
              () => CustomButton(
                text: isEdit ? 'Simpan Perubahan' : 'Tambah User',
                onPressed: authController.isLoading.value ? null : _handleSave,
                isLoading: authController.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
