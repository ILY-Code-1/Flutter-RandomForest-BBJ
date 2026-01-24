// File: main_screen.dart
// Deskripsi: Screen utama yang memilih tampilan berdasarkan role user

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'admin_main_screen.dart';
import 'marketing_main_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser.value;

      if (user == null) {
        // User belum login, tampilkan loading
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Tampilkan UI berdasarkan role
      if (user.isAdmin) {
        return const AdminMainScreen();
      } else {
        return const MarketingMainScreen();
      }
    });
  }
}
