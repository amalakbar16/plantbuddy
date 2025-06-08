import 'package:flutter/material.dart';

class Tanggal extends StatelessWidget {
  const Tanggal({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'Sn', 'Sl', 'Rb', 'K', 'J', 'Sb'];
    final dates = ['31', '1', '2', '3', '4', '5', '6'];
    final int selectedIndex = 2; // tanggal yang di-highlight (index ke-2 = '2')
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withAlpha(51),
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Bulan dan tahun
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
            child: const Text(
              'April 2025',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Hari (Row)
          Row(
            children: List.generate(days.length, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    days[i],
                    style: TextStyle(
                      color: i == selectedIndex
                          ? const Color(0xFF01B14E)
                          : Colors.black.withAlpha(102),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 2),
          // Tanggal (Row)
          Row(
            children: List.generate(dates.length, (i) {
              final isSelected = i == selectedIndex;
              return Expanded(
                child: Center(
                  child: isSelected
                      ? Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF01B14E),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            dates[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Text(
                          dates[i],
                          style: TextStyle(
                            color: i == 0
                                ? const Color(0xFFBFBFBF)
                                : const Color(0xFF444444),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
