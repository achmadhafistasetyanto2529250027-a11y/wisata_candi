import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisata_candi/data/candi_data.dart';
import 'package:wisata_candi/widgets/profile_info_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isSignedIn = false;
  String fullName = '';
  String userName = '';
  int favoriteCandiCount = 0;

  // initState(): dijalankan sekali saat layar dibuat.
  // Dipakai untuk memuat data pengguna dari SharedPreferences.
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // _loadUserData(): membaca status sign in, mendekripsi nama dan nama
  // pengguna, serta menghitung jumlah candi favorit.
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final bool signedIn = prefs.getBool('isSignedIn') ?? false;

    String name = '';
    String user = '';

    final keyString = prefs.getString('key') ?? '';
    final ivString = prefs.getString('iv') ?? '';
    final encryptedName = prefs.getString('fulname') ?? '';
    final encryptedUser = prefs.getString('username') ?? '';

    // Data hanya didekripsi jika sudah sign in dan data lengkap
    if (signedIn &&
        keyString.isNotEmpty &&
        ivString.isNotEmpty &&
        encryptedName.isNotEmpty &&
        encryptedUser.isNotEmpty) {
      try {
        final key = encrypt.Key.fromBase64(keyString);
        final iv = encrypt.IV.fromBase64(ivString);
        final encrypter = encrypt.Encrypter(encrypt.AES(key));
        name = encrypter.decrypt64(encryptedName, iv: iv);
        user = encrypter.decrypt64(encryptedUser, iv: iv);
      } catch (e) {
        debugPrint('Gagal mendekripsi data pengguna: $e');
      }
    }

    // Jumlah candi yang statusnya favorit (disimpan oleh DetailScreen)
    final int count = signedIn
        ? candiList
            .where((c) => prefs.getBool('favorite_${c.name}') ?? false)
            .length
        : 0;

    if (!mounted) return;
    setState(() {
      isSignedIn = signedIn;
      fullName = name;
      userName = user;
      favoriteCandiCount = count;
    });
  }

  // signIn(): membuka layar Sign In lewat rute bernama.
  // Proses sign in sebenarnya dilakukan di SignInScreen.
  void signIn() {
    Navigator.pushNamed(context, '/signin');
  }

  // signOut(): mengubah isSignedIn menjadi false dan mengosongkan nama,
  // nama pengguna, dan kata sandi di SharedPreferences (sesuai tugas).
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedIn', false);
    await prefs.setString('fulname', '');
    await prefs.setString('username', '');
    await prefs.setString('password', '');

    if (!mounted) return;
    setState(() {
      isSignedIn = false;
      fullName = '';
      userName = '';
      favoriteCandiCount = 0;
    });
  }

  // editFullName(): menampilkan dialog untuk mengubah nama lengkap.
  // Nama baru dienkripsi dengan key dan iv yang sama, lalu disimpan.
  Future<void> editFullName() async {
    final prefs = await SharedPreferences.getInstance();
    final keyString = prefs.getString('key') ?? '';
    final ivString = prefs.getString('iv') ?? '';
    if (keyString.isEmpty || ivString.isEmpty) return;
    if (!mounted) return;

    final controller = TextEditingController(text: fullName);
    // showDialog mengembalikan nilai yang dikirim lewat Navigator.pop
    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nama lengkap'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    // Dibatalkan atau dikosongkan: tidak ada yang diubah
    if (newName == null || newName.isEmpty) return;

    final key = encrypt.Key.fromBase64(keyString);
    final iv = encrypt.IV.fromBase64(ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encryptedName = encrypter.encrypt(newName, iv: iv);

    await prefs.setString('fulname', encryptedName.base64);

    if (!mounted) return;
    setState(() {
      fullName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.deepPurple,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // ===== ProfileHeader =====
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 200 - 50),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.deepPurple,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('images/placeholder_image.png'),
                          ),
                        ),
                        if (isSignedIn)
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.deepPurple[50],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ===== ProfileInfo =====
                const SizedBox(height: 20),
                Divider(color: Colors.deepPurple[100]),
                const SizedBox(height: 4),
                ProfileInfoItem(
                  icon: Icons.lock,
                  label: 'Pengguna',
                  value: userName,
                  iconColor: Colors.amber,
                ),
                const SizedBox(height: 4),
                Divider(color: Colors.deepPurple[100]),
                const SizedBox(height: 4),
                ProfileInfoItem(
                  icon: Icons.person,
                  label: 'Nama',
                  value: fullName,
                  showEditIcon: isSignedIn,
                  onEditPressed: editFullName,
                  iconColor: Colors.blue,
                ),
                const SizedBox(height: 4),
                Divider(color: Colors.deepPurple[100]),
                const SizedBox(height: 4),
                ProfileInfoItem(
                  icon: Icons.favorite,
                  label: 'Favorit',
                  value: favoriteCandiCount > 0 ? '$favoriteCandiCount' : '',
                  iconColor: Colors.red,
                ),

                // ===== ProfileAction =====
                const SizedBox(height: 4),
                Divider(color: Colors.deepPurple[100]),
                const SizedBox(height: 20),
                isSignedIn
                    ? TextButton(
                        onPressed: signOut,
                        child: const Text('Sign Out'),
                      )
                    : TextButton(
                        onPressed: signIn,
                        child: const Text('Sign In'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
