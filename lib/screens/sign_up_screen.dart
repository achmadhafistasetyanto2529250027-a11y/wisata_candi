import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Layar pendaftaran. StatefulWidget karena memiliki pesan error
// dan status tampil/sembunyi kata sandi yang berubah.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorText = '';
  bool _obscurePassword = true;

  // _signUp(): memvalidasi masukan, mengenkripsi data dengan AES,
  // menyimpannya ke SharedPreferences, lalu membuka layar Sign In.
  // async karena akses SharedPreferences bersifat asinkron.
  Future<void> _signUp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // trim() membuang spasi di awal dan akhir teks
    final String name = _nameController.text.trim();
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // Validasi kata sandi dengan RegExp. Tanda ! berarti "tidak mengandung".
    // Jika salah satu syarat gagal, tampilkan pesan error lalu berhenti.
    if (password.length < 8 ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[a-z]')) ||
        !password.contains(RegExp(r'[0-9]')) ||
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      setState(() {
        _errorText =
            'Minimal 8 karakter, kombinasi [A-Z], [a-z], [0-9], [!@#\\\$%^&*(),.?":{}|<>]';
      });
      return;
    }

    if (name.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
      // Key (kunci) dan IV (vektor inisialisasi) untuk AES
      final encrypt.Key key = encrypt.Key.fromLength(32);
      final encrypt.IV iv = encrypt.IV.fromLength(16);

      // Encrypter melakukan enkripsi dengan algoritma AES dan key di atas
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encryptedName = encrypter.encrypt(name, iv: iv);
      final encryptedUsername = encrypter.encrypt(username, iv: iv);
      final encryptedPassword = encrypter.encrypt(password, iv: iv);

      // Simpan hasil enkripsi sebagai String (.base64).
      // key dan iv ikut disimpan agar bisa dipakai saat dekripsi.
      // (penulisan 'fulname' mengikuti slide)
      await prefs.setString('fulname', encryptedName.base64);
      await prefs.setString('username', encryptedUsername.base64);
      await prefs.setString('password', encryptedPassword.base64);
      await prefs.setString('key', key.base64);
      await prefs.setString('iv', iv.base64);

      // mounted: memastikan layar masih ada setelah proses await
      if (!mounted) return;
      // Ganti layar ini dengan Sign In (Sign Up tidak bisa dikembalikan)
      Navigator.pushReplacementNamed(context, '/signin');
    } else {
      setState(() {
        _errorText = 'Nama, nama pengguna, dan kata sandi harus diisi.';
      });
    }
  }

  // dispose(): dijalankan otomatis saat layar dibuang.
  // Controller harus dibebaskan dari memori agar tidak bocor.
  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      // Jika _errorText tidak kosong tampilkan, jika kosong null
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
                    onPressed: _signUp,
                    child: const Text('Sign Up'),
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
