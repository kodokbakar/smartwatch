import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Sesuaikan path import dengan struktur project kamu.
import 'package:smartwatch/app/modules/login/controllers/login_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginController.login', () {
    late List<Map<String, dynamic>> snackbarLog;
    late bool navigatedToHome;

    setUp(() {
      // Menyimpan semua event snackbar agar bisa di-assert.
      snackbarLog = <Map<String, dynamic>>[];

      // Flag untuk memastikan navigasi benar-benar terpanggil.
      navigatedToHome = false;
    });

    LoginController makeController({
      Future<void> Function({
      required String email,
      required String password,
      })? signIn,
    }) {
      return LoginController(
        signIn: signIn,
        showSnackbar: ({
          required String title,
          required String message,
          required bool isError,
        }) {
          snackbarLog.add({
            'title': title,
            'message': message,
            'isError': isError,
          });
        },
        navigateToHome: () {
          navigatedToHome = true;
        },
      );
    }

    test('menolak login jika ada field kosong (tidak memanggil signIn)', () async {
      var signInCalled = 0;

      final c = makeController(
        signIn: ({required email, required password}) async {
          signInCalled++;
        },
      );

      // Sengaja kosongkan password.
      c.emailController.text = 'a@mail.com';
      c.passwordController.text = '';

      await c.login();

      expect(signInCalled, 0, reason: 'signIn tidak boleh dipanggil saat validasi gagal');
      expect(c.isLoading.value, false, reason: 'loading harus tetap false bila return lebih awal');

      expect(snackbarLog.isNotEmpty, true);
      expect(snackbarLog.last['title'], 'Error');
      expect(snackbarLog.last['message'], 'Please fill all fields');
      expect(snackbarLog.last['isError'], true);

      c.onClose();
    });

    test('sukses: memanggil signIn, navigasi ke home, dan snackbar sukses', () async {
      var signInCalled = 0;
      Map<String, dynamic>? signInArgs;

      final c = makeController(
        signIn: ({required email, required password}) async {
          signInCalled++;
          signInArgs = {'email': email, 'password': password};
        },
      );

      c.emailController.text = 'a@mail.com';
      c.passwordController.text = '123456';

      await c.login();

      expect(c.isLoading.value, false, reason: 'loading harus reset setelah selesai');
      expect(signInCalled, 1);
      expect(signInArgs?['email'], 'a@mail.com');
      expect(navigatedToHome, true, reason: 'harus navigasi saat login sukses');

      expect(snackbarLog.isNotEmpty, true);
      expect(snackbarLog.last['title'], 'Sukses!');
      expect(snackbarLog.last['message'], 'Berhasil Login');
      expect(snackbarLog.last['isError'], false);

      c.onClose();
    });

    test('AuthException: tampilkan pesan dari Supabase dan tidak navigasi', () async {
      final c = makeController(
        signIn: ({required email, required password}) async {
          // Simulasikan kegagalan auth (mis. kredensial salah).
          throw AuthException('Invalid login credentials');
        },
      );

      c.emailController.text = 'a@mail.com';
      c.passwordController.text = 'wrongpass';

      await c.login();

      expect(c.isLoading.value, false);
      expect(navigatedToHome, false, reason: 'tidak boleh navigasi jika auth gagal');

      expect(snackbarLog.isNotEmpty, true);
      expect(snackbarLog.last['title'], 'Error');
      expect(snackbarLog.last['message'], 'Invalid login credentials');
      expect(snackbarLog.last['isError'], true);

      c.onClose();
    });

    test('Generic exception: tampilkan pesan umum dan tidak navigasi', () async {
      final c = makeController(
        signIn: ({required email, required password}) async {
          throw Exception('boom');
        },
      );

      c.emailController.text = 'a@mail.com';
      c.passwordController.text = '123456';

      await c.login();

      expect(c.isLoading.value, false);
      expect(navigatedToHome, false);

      expect(snackbarLog.isNotEmpty, true);
      expect(snackbarLog.last['title'], 'Error');
      expect(snackbarLog.last['message'], 'Something went wrong');
      expect(snackbarLog.last['isError'], true);

      c.onClose();
    });

    test('isLoading true selama proses signIn berjalan (pakai Completer)', () async {
      final gate = Completer<void>();

      final c = makeController(
        signIn: ({required email, required password}) async {
          // Tahan proses login agar kita bisa cek state loading.
          await gate.future;
        },
      );

      c.emailController.text = 'a@mail.com';
      c.passwordController.text = '123456';

      final future = c.login();

      // Beri kesempatan event loop memproses isLoading = true.
      await Future<void>.delayed(Duration.zero);
      expect(c.isLoading.value, true, reason: 'loading harus true saat proses berjalan');

      // Lepaskan gate agar login selesai.
      gate.complete();
      await future;

      expect(c.isLoading.value, false, reason: 'loading harus false setelah selesai');

      c.onClose();
    });
  });
}
