import 'package:flutter/material.dart';

class RecommendationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double textSize;

  const RecommendationCard({
    super.key,
    required this.icon,
    required this.title,
    this.textSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white, // Warna background putih untuk card
            borderRadius:
                BorderRadius.circular(15), // Membuat sudut lebih bulat
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Shadow lembut
                blurRadius: 8,
                offset: Offset(2, 4), // Posisi shadow
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 40,
            color: Colors.blueAccent, // Mengganti warna icon lebih cerah
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.w600, // Bold text untuk judul
            color: Colors.grey.shade800, // Warna teks lebih gelap
          ),
        ),
      ],
    );
  }
}
