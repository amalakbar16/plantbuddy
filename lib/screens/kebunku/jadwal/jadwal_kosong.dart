import 'package:flutter/material.dart';
import 'tambah_jadwal.dart';

class JadwalKosong extends StatelessWidget {
  const JadwalKosong({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_note, size: 85, color: const Color(0xFF01B14E).withOpacity(0.17)),
          const SizedBox(height: 28),
          Text(
            'Ayo Buat Jadwalmu',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 23,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 13),
          // Split text so "tanaman kamu" ada di baris bawah
          Column(
            children: const [
              Text(
                'Ini akan membantu jadwal penyiraman',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'tanaman kamu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 175,
            height: 48,
            child: OutlinedButton(
              onPressed: () => _showTambahJadwalModal(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 1.3, color: Color(0xFF01B14E)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Tambah Jadwal',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: Color(0xFF01B14E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTambahJadwalModal(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: const TambahJadwal(),
            ),
          );
        },
      ),
    );
  }
}
