// File: app_pages.dart
// Deskripsi: Konfigurasi GetX pages/routes dengan bindings.

import 'package:get/get.dart';
import '../controllers/prediction_controller.dart';
import '../controllers/navigation_controller.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/detail_prediksi_screen.dart';
import '../presentation/screens/pilihan_input_screen.dart';
import '../presentation/screens/form_prediksi_screen.dart';
import '../presentation/screens/upload_excel_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PredictionController>(() => PredictionController());
        Get.lazyPut<NavigationController>(() => NavigationController());
      }),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailPrediksiScreen(),
    ),
    GetPage(
      name: AppRoutes.pilihanInput,
      page: () => const PilihanInputScreen(),
    ),
    GetPage(
      name: AppRoutes.form,
      page: () => const FormPrediksiScreen(),
    ),
    GetPage(
      name: AppRoutes.uploadExcel,
      page: () => const UploadExcelScreen(),
    ),
  ];
}
