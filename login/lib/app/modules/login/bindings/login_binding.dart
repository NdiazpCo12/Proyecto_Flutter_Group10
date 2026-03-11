import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../services/auth_service.dart';
import '../../profile/controllers/profile_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Register AuthService as a singleton
    Get.put<AuthService>(AuthService(), permanent: true);
    // Register LoginController with AuthService injected
    Get.lazyPut<LoginController>(
      () => LoginController(authService: Get.find<AuthService>()),
    );
    // Put ProfileController early so it's available after login
    Get.put(ProfileController(), permanent: true);
  }
}
