import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final user = Rxn<AppUser>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final authUser = _supabase.auth.currentUser;

      if (authUser == null) {
        errorMessage.value = 'User not logged in';
        isLoading.value = false;
        return;
      }

      final data = await _supabase
          .from('user') // table: public.user
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (data == null) {
        errorMessage.value = 'Profile data not found';
      } else {
        user.value = AppUser.fromJson(data);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      // TODO: adjust this route to your login page
      // Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('Logout Failed', e.toString());
    }
  }

  void goToProfileDetail() {
    // TODO: navigate to "Tentang Profil" page
    // Get.toNamed(Routes.PROFILE_DETAIL);
  }

  void goToHelp() {
    // TODO: navigate to "Bantuan" page
    // Get.toNamed(Routes.HELP);
  }

  void goToAboutApp() {
    // TODO: navigate to "Tentang Aplikasi" page
    // Get.toNamed(Routes.ABOUT_APP);
  }
}
