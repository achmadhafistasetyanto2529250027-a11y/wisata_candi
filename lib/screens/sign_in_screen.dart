import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorText = ''; // tidak lagi final karena nilainya berubah
  bool _isSignedIn = false;
  bool _obscurePassword = true;

  // _retrieveAndDecryptDataFromPrefs(): mengambil data terenkripsi beserta
  // key dan iv dari SharedPreferences, lalu mendekripsinya.
  // Mengembalikan Map berisi username dan password asli, atau Map kosong
  // jika belum ada pengguna yang terdaftar.
  Future<Map<String, String>> _retrieveAndDecryptDataFromPrefs(
    SharedPreferences prefs,
  ) async {
    // ?? '' berarti: jika data tidak ada (null), pakai teks kosong
    final encryptedUsername = prefs.getString('username') ?? '';
    final encryptedPassword = prefs.getString('password') ?? '';
    final keyString = prefs.getString('key') ?? '';
    final ivString = prefs.getString('iv') ?? '';

    // Belum ada data (belum sign up, atau data dikosongkan saat sign out)
    if (encryptedUsername.isEmpty ||
        encryptedPassword.isEmpty ||
        keyString.isEmpty ||
        ivString.isEmpty) {
      return {};
    }

    // Kembalikan key dan iv dari String base64 ke bentuk objek
    final encrypt.Key key = encrypt.Key.fromBase64(keyString);
    final encrypt.IV iv = encrypt.IV.fromBase64(ivString);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decryptedUsername = encrypter.decrypt64(encryptedUsername, iv: iv);
    final decryptedPassword = encrypter.decrypt64(encryptedPassword, iv: iv);

    return {'username': decryptedUsername, 'password': decryptedPassword};
  }

  // _signIn(): memeriksa masukan pengguna terhadap data tersimpan.
  // Jika cocok, status sign in disimpan lalu seluruh tumpukan layar
  // dibersihkan dan aplikasi kembali ke layar utama.
  Future<void> _signIn() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String enteredUsername = _usernameController.text.trim();
      final String enteredPassword = _passwordController.text.trim();

      // Masukan kosong
      if (enteredUsername.isEmpty || enteredPassword.isEmpty) {
        setState(() {
          _errorText = 'Nama pengguna dan kata sandi harus diisi.';
        });
        return;
      }

      final data = await _retrieveAndDecryptDataFromPrefs(prefs);

      // Belum ada pengguna terdaftar
      if (data.isEmpty) {
        setState(() {
          _errorText = 'Pengguna belum terdaftar. Silakan daftar terlebih dahulu.';
        });
        return;
      }

      final String savedUsername = data['username'] ?? '';
      final String savedPassword = data['password'] ?? '';

      if (enteredUsername == savedUsername &&
          enteredPassword == savedPassword) {
        setState(() {
          _errorText = '';
          _isSignedIn = true;
        });
        // Simpan status sign in agar layar lain bisa memeriksanya
        await prefs.setBool('isSignedIn', true);
        if (!mounted) return;

        // Menghapus semua halaman dalam tumpukan navigasi
        // sampai tersisa halaman pertama
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
        // Sign in berhasil, navigasi ke layar utama
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/');
        });
      } else {
        setState(() {
          _errorText = 'Nama pengguna atau kata sandi salah.';
        });
      }
    } catch (e) {
      // Menangkap kesalahan tak terduga, misalnya data rusak saat didekripsi
      debugPrint('Terjadi kesalahan saat sign in: $e');
      setState(() {
        _errorText = 'Terjadi kesalahan. Silakan coba lagi.';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pengguna',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      errorText: _errorText.isNotEmpty ? _errorText : null,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: 10),
                  // RichText: teks campuran, sebagian bisa diketuk
                  RichText(
                    text: TextSpan(
                      text: 'Belum punya akun? ',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Daftar di sini.',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                          // Saat diketuk, buka layar Sign Up lewat rute
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/signup');
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
