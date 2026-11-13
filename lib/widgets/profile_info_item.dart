import 'package:flutter/material.dart';

// Hasil refaktor: satu baris info profil (ikon + label + nilai).
// Menggantikan tiga Row yang berulang di ProfileScreen.
class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showEditIcon;          // tampilkan ikon edit atau tidak
  final VoidCallback? onEditPressed; // aksi saat ikon edit ditekan
  final Color iconColor;

  const ProfileInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showEditIcon = false,
    this.onEditPressed,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Bagian kiri selebar 1/3 layar: ikon dan label
        SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        // Bagian kanan memenuhi sisa lebar: nilai teks
        Expanded(
          child: Text(': $value', style: const TextStyle(fontSize: 18)),
        ),
        if (showEditIcon)
          InkWell(
            onTap: onEditPressed,
            child: Icon(Icons.edit, color: iconColor),
          ),
      ],
    );
  }
}
