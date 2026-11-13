import 'package:flutter/material.dart';
import 'package:wisata_candi/models/candi.dart';
import 'package:wisata_candi/screens/detail_screen.dart';

// Widget kartu untuk satu candi (gambar, nama, tipe).
// StatelessWidget karena tampilannya tidak berubah.
class ItemCard extends StatelessWidget {
  final Candi candi; // data candi yang ditampilkan

  const ItemCard({super.key, required this.candi});

  @override
  Widget build(BuildContext context) {
    // InkWell membuat kartu bisa ditekan dengan efek percikan.
    return InkWell(
      // Navigator.push membuka DetailScreen di atas layar saat ini
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(candi: candi),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(4),
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded: gambar mengisi sisa tinggi kartu
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  candi.imageAsset,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Text(
                candi.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(candi.type, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
