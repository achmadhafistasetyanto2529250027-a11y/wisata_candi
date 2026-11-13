// Model data: cetakan untuk satu objek candi.
// Bentuknya mengikuti isi data dummy.
class Candi {
  final String name;
  final String location;
  final String description;
  final String built;
  final String type;
  final String imageAsset;      // path gambar lokal (folder images/)
  final List<String> imageUrls; // daftar URL gambar untuk galeri
  bool isFavorite;              // tidak final karena nilainya bisa berubah

  // Konstruktor dengan named parameter.
  // Semua wajib diisi, kecuali isFavorite yang default-nya false.
  Candi({
    required this.name,
    required this.location,
    required this.description,
    required this.built,
    required this.type,
    required this.imageAsset,
    required this.imageUrls,
    this.isFavorite = false,
  });
}
