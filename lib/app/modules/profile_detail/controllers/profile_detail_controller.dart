import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/user_model.dart';

class ProfileDetailController extends GetxController {
  // ---------------------------------------------------------------------------
  // Supabase client untuk operasi read/update profil user.
  // Pastikan Supabase.initialize sudah dilakukan di main.dart.
  // ---------------------------------------------------------------------------
  final SupabaseClient _supabase = Supabase.instance.client;

  // State utama untuk UI (GetX reactive).
  final user = Rxn<AppUser>();
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final errorMessage = RxnString();

  // Controller untuk input TextField (nama & username).
  // Dispose di onClose untuk mencegah memory leak.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // -----------------------------------------------------------------------
      // Validasi sesi login. Jika null, berarti user belum login.
      // -----------------------------------------------------------------------
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        errorMessage.value = 'User belum login';
        return;
      }

      // -----------------------------------------------------------------------
      // Mengambil data profil dari tabel `user` berdasarkan id auth.
      // Gunakan maybeSingle agar aman ketika data tidak ditemukan.
      // -----------------------------------------------------------------------
      final data = await _supabase
          .from('user')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (data == null) {
        errorMessage.value = 'Data profil tidak ditemukan';
      } else {
        final appUser = AppUser.fromJson(data);
        user.value = appUser;

        // Sinkronisasi nilai awal ke text field.
        nameController.text = appUser.fullName ?? '';
        usernameController.text = appUser.username;
      }
    } catch (e) {
      // Error message disimpan agar UI bisa menampilkan feedback yang jelas.
      errorMessage.value = 'Gagal memuat profil: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    final currentUser = user.value;
    if (currentUser == null) return;

    final fullName = nameController.text.trim();
    final username = usernameController.text.trim();

    // -------------------------------------------------------------------------
    // Validasi ringan di sisi client.
    // Validasi unik username sebaiknya juga dilakukan di DB (unique constraint).
    // -------------------------------------------------------------------------
    if (username.isEmpty) {
      Get.snackbar('Validasi', 'Username tidak boleh kosong.');
      return;
    }

    try {
      isUpdating.value = true;

      // -----------------------------------------------------------------------
      // Update ke tabel `user` sesuai id.
      // `full_name` diset null jika input kosong agar data tetap bersih.
      // -----------------------------------------------------------------------
      await _supabase.from('user').update({
        'full_name': fullName.isEmpty ? null : fullName,
        'username': username,
      }).eq('id', currentUser.id);

      // Perbarui state lokal agar UI langsung ter-update tanpa reload.
      user.value = AppUser(
        id: currentUser.id,
        email: currentUser.email,
        username: username,
        fullName: fullName.isEmpty ? null : fullName,
        createdAt: currentUser.createdAt,
      );

      Get.snackbar('Berhasil', 'Profil berhasil diperbarui.');
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak dapat memperbarui profil: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose untuk menghindari kebocoran memori dari TextEditingController.
    nameController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}
