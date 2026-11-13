import 'package:wisata_candi/models/candi.dart';

// Data dummy: List berisi objek Candi.
// Dipakai oleh HomeScreen, SearchScreen, dan DetailScreen.
var candiList = [
  Candi(
    name: 'Candi Borobudur',
    location: 'Magelang, Jawa Tengah',
    description:
        'Candi Borobudur, candi Buddha terbesar di dunia, dibangun oleh penganut Buddha Mahayana sekitar abad ke-9.',
    built: 'Abad ke-9',
    type: 'Candi Buddha',
    imageAsset: 'images/borobudur.jpeg',
    imageUrls: [
      'https://media-cdn.tripadvisor.com/media/photo-o/11/cd/4f/71/borobudur-and-the-sky.jpg',
      'https://media-cdn.tripadvisor.com/media/photo-o/11/cd/5d/36/borobudur-airial-view.jpg',
      'https://media-cdn.tripadvisor.com/media/photo-o/11/cd/4d/c7/borobudur-and-the-sky.jpg',
      'https://media-cdn.tripadvisor.com/media/photo-o/11/cd/47/0e/borobudur-sunset-moment.jpg',
    ],
    isFavorite: false,
  ),
  // Data berikut contoh buatan sendiri.
  // Ganti nama aset dan URL sesuai sumber daya dari dosen.
  Candi(
    name: 'Candi Prambanan',
    location: 'Sleman, DI Yogyakarta',
    description:
        'Candi Prambanan adalah kompleks candi Hindu terbesar di Indonesia yang dipersembahkan untuk Trimurti: Brahma, Wisnu, dan Siwa.',
    built: 'Abad ke-9',
    type: 'Candi Hindu',
    imageAsset: 'images/prambanan.jpeg',
    imageUrls: [
      'https://picsum.photos/id/10/300/200',
      'https://picsum.photos/id/11/300/200',
      'https://picsum.photos/id/12/300/200',
    ],
  ),
  Candi(
    name: 'Candi Mendut',
    location: 'Magelang, Jawa Tengah',
    description:
        'Candi Mendut adalah candi Buddha yang terletak tidak jauh dari Borobudur dan menyimpan tiga arca besar di dalam bilik utamanya.',
    built: 'Abad ke-8',
    type: 'Candi Buddha',
    imageAsset: 'images/mendut.jpeg',
    imageUrls: [
      'https://picsum.photos/id/20/300/200',
      'https://picsum.photos/id/21/300/200',
    ],
  ),
];
