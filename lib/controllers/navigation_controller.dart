// File: navigation_controller.dart
// Deskripsi: GetX Controller untuk mengelola bottom navigation state.

import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  void goToHome() {
    currentIndex.value = 0;
  }

  void goToAddPrediction() {
    currentIndex.value = 1;
  }

  void goToHistory() {
    currentIndex.value = 2;
  }

  void goToManageUsers() {
    currentIndex.value = 3;
  }
}
