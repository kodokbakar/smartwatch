import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:your_app/app/modules/register/controllers/register_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RegisterController.register', () {
    late List<Map<String, dynamic>> snackbarLog;
    late bool navigatedToLogin;

    setUp(() {
      // Menyimpan semua snackbar yang dipanggil agar bisa di-assert.
      snackbarLog = <Map<String, dynamic>>[];

      // Flag untuk memastikan navigasi benar-benar terpanggil.
      navigatedToLogin = false;
    });

    RegisterController makeController({
      Future<String?> Function({
      required String email,
      required String password,
      required String fullName,
      required String username,
      })? signUp,
      Future<void> Function({
      required String userId,
      required String email,
      required String username,
      required String fullName,
      })? insertUser,
    }) {
      return RegisterController(
        signUp: signUp,
        insertUser: insertUser,
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
        navigateToLogin: () {
          navigatedToLogin = true;
        },
      );
    }

    tearDown(() {
      // Bersihkan resource TextEditingController yang dibuat controller.
      // Ini penting supaya test tidak menghasilkan warning memory leak.
      // ignore: invalid_use_of_protected_member
      // (kita sengaja dispose lewat lifecycle controller)
    });

    test('menolak register jika ada field kosong (tidak memanggil signUp)', () async {
      var signUpCalled = 0;
      var insertCalled = 0;

      final c = makeController(
        signUp: ({
          required email,
          required password,
          required fullName,
          required username,
        }) async {
          signUpCalled++;
          return 'uid';
        },
        insertUser: ({
          required userId,
          required email,
          required username,
          required fullName,
        }) async {
          insertCalled++;
        },
      );

      // Sengaja hanya isi sebagian field.
      c.nameController.text = 'A';
      c.usernameController.text = '';
      c.emailController.text = 'a@mail.com';
      c.passwordController.text = '123456';
      c.confirmPasswordController.text = '123456';

      await c.register();

      expect(signUpCalled, 0, reason: 'signUp tidak boleh terpanggil saat validasi gagal');
      expect(insertCalled, 0, reason: 'insert tidak boleh terpanggil saat validasi gagal');
      expect(c.isLoading.value, false);

      expect(snackbarLog.isNotEmpty, true);
      expect(snackbarLog.last['isError'], true);
      expect(snackbarLog.last['message'], 'Please fill all fields');

      c.onClose();
    });

    test('menolak register jika password dan konfirmasi tidak sama', () async {
      var signUpCalled = 0;

      final c = makeController(
        signUp: ({
          required email,
          required password,
          required fullName,
          required username,
        }) async {
          signUpCalled++;
          return 'uid';
        },
      );

      c.nameController.text = 'User A';
      c.usernameController.text = 'usera';
      c.emailController.text = 'a@mail.com';
      c.passwordController.text = '123456';
      c.confirmPasswordController.text = '654321';

      await c.register();

      expect(signUpCalled, 0);
      expect(snackbarLog.last['message'], 'Passwords do not match');
      expect(snackbarLog.last['isError'], true);

      c.onClose();
    });

    test('menolak register jika password kurang dari 6 karakter', () async {
      var signUpCalled = 0;

      final c = makeController(
        signUp: ({
          required email,
          required password,
          required fullName,
          required username,
        }) async {
          signUpCalled++;
          return 'uid';
        },
      );

      c.nameController.text = 'User A';
      c.usernameController.text = 'usera';
      c.emailController.text = 'a@mail.com';
      c.passwordController.text = '12345';
      c.confirmPasswordController.text = '12345';

      await c.register();

      expect(signUpCalled, 0);
      expect(snackbarLog.last['message'], 'Password must be at least 6 characters');
      expect(snackbarLog.last['isError'], true);

      c.onClose();
    });

    test('sukses: memanggil signUp, insert user, dan navigasi ke login', () async {
      var signUpCalled = 0;
      var insertCalled = 0;

      Map<String, dynamic>? signUpArgs;
      Map<String, dynamic>? insertArgs;

      final c = makeController(
        signUp: ({
          required email,
          required password,
          required fullName,
          required username,
        }) async {
          // Simulasikan signup berhasil dan mengembalikan userId.
          signUpCalled++;
          signUpArgs = {
            'email': email,
            'password': password,
            'fullName': fullName,
            'username': username,
          };
          return 'uid-123';
        },
        insertUser: ({
          required userId,
          required email,
          required username,
          required fullName,
        }) async {
          // Simulasikan insert ke table aplikasi berhasil.
          insertCalled++;
          insertArgs = {
            'userId': userId,
            'email': email,
            'username': username,
            'fullName': fullName,
          };
        },
      );

      c.nameController.text = 'User A';
      c.usernameController.text = 'usera';
      c.emailController.text = 'a@mail.com';
      c.passwordController.text = '123456';
      c.confirmPasswordController.text = '123456';

      await c.register();

      expect(c.isLoading.value, false, reason: 'loading harus reset setelah proses selesai');
      expect(signUpCalled, 1);
      expect(insertCalled, 1);
      expect(navigatedToLogin, true, reason: 'harus navigasi ke login saat sukses');

      // Verifikasi argumen penting agar tidak ada field yang “ketuker”.
      expect(signUpArgs?['email'], 'a@mail.com');
      expect(signUpArgs?['username'], 'usera');
      expect(insertArgs?['userId'], 'uid-123');

      expect(snackbarLog.last['isError'], false);
      expect(snackbarLog.last['message'], 'Registration successful!');

      c.onClose();
    });

    test('AuthException: menampilkan pesan error dari Supabase dan tidak navigasi', () async {
      var insertCalled = 0;

      final c = makeController(
        signUp: ({
          required email,
          required password,
          required fullName,
          required username,
        }) async {
          // Simulasikan error auth (mis. email sudah terpakai).
          throw const AuthException('Email already registered', statusCode: '400');
        },
        insertUser: ({
          required userId,
          required email,
          required username,
          required fullName,
        }) async {
          insertCalled++;
        },
      );

      c.nameController.text = 'User A';
      c.usernameController.text = 'usera';
      c.emailController.text = 'a@mail.com';
      c.passwordController.text = '123456';
      c.confirmPasswordController.text = '123456';

      await c.register();

      expect(c.isLoading.value, false);
      expect(insertCalled, 0, reason: 'insert tidak boleh terpanggil jika signup gagal');
      expect(navigatedToLogin, false);

      expect(snackbarLog.last['isError'], true);
      expect(snackbarLog.last['message'], 'Email already registered');

      c.onClose();
    });

    test('Generic exception: menampilkan error umum dan tidak navigasi', () async {
      final c = makeController(
        signUp: ({
          required email,
          required password,
          required fullName,
          required username,
        }) async {
          throw Exception('boom');
        },
      );

      c.nameController.text = 'User A';
      c.usernameController.text = 'usera';
      c.emailController.text = 'a@mail.com';
      c.passwordController.text = '123456';
      c.confirmPasswordController.text = '123456';

      await c.register();

      expect(c.isLoading.value, false);
      expect(navigatedToLogin, false);

      expect(snackbarLog.last['isError'], true);
      expect(snackbarLog.last['message'], 'Something went wrong');

      c.onClose();
    });

    test('isLoading true selama proses berjalan (menggunakan Completer)', () async {
      final gate = Completer<void>();

      final c = makeController(
        signUp: ({
          required email,
          required password,
          required fullName,
          required username,
        }) async {
          // Tahan proses signup sampai test membuka gate.
          await gate.future;
          return 'uid-123';
        },
        insertUser: ({
          required userId,
          required email,
          required username,
          required fullName,
        }) async {},
      );

      c.nameController.text = 'User A';
      c.usernameController.text = 'usera';
      c.emailController.text = 'a@mail.com';
      c.passwordController.text = '123456';
      c.confirmPasswordController.text = '123456';

      final future = c.register();

      // Beri kesempatan event loop memproses isLoading = true.
      await Future<void>.delayed(Duration.zero);
      expect(c.isLoading.value, true, reason: 'loading harus true saat proses sedang berjalan');

      // Lanjutkan proses.
      gate.complete();
      await future;

      expect(c.isLoading.value, false, reason: 'loading harus false setelah selesai');

      c.onClose();
    });
  });
}
