import 'package:flutter/material.dart';

class PilihTanaman extends StatelessWidget {
  final List<Map<String, dynamic>> tanamanList;
  final Function(Map<String, dynamic>) onSelected;

  const PilihTanaman({
    super.key,
    required this.tanamanList,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Drag Indicator dan Title (kiri) ---
          Padding(
            padding: const EdgeInsets.only(top: 14, left: 0, right: 0, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Pilih Tanaman',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
              ],
            ),
          ),
          // --- List Tanaman ---
          Expanded(
            child: tanamanList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Text(
                        'Belum ada tanaman disimpan.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    itemCount: tanamanList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final tanaman = tanamanList[index];
                      return ListTile(
                        leading: const Icon(Icons.eco, color: Color(0xFF01B14E)),
                        title: Text(
                          tanaman['name'] ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                          ),
                        ),
                        subtitle: tanaman['species'] != null
                            ? Text(
                                tanaman['species'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                ),
                              )
                            : null,
                        onTap: () {
                          onSelected(tanaman);
                          Navigator.pop(context);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hoverColor: Colors.green[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minLeadingWidth: 32,
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFBFBFBF)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
