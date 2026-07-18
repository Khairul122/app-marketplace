import 'package:flutter/material.dart';
import 'package:ootday_owner/login.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F2),

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 10),

            // === TOP BAR ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  // Tombol Back
                  InkWell(
                    onTap: () => Navigator.pop(context),

                    child: const Icon(
                      Icons.arrow_back,
                      size: 26,
                    ),
                  ),

                  // Tombol Skip
                  TextButton(
                    onPressed: () {

                      // Langsung ke Login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },

                    child: const Text(
                      "Skip",

                      style: TextStyle(
                        color: Color(0xFF5F1D1D),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // === GAMBAR ===
            Image.asset(
              "assets/onboarding2.png",
              width: 260,
            ),

            const SizedBox(height: 30),

            // === TITLE ===
            const Text(
              "Smart Shopping",

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5F1D1D),
              ),
            ),

            const SizedBox(height: 12),

            // === DESCRIPTION ===
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 35),

              child: Text(
                "Nikmati pengalaman belanja pakaian yang mudah, aman, dan menyenangkan. Semua kebutuhan fashion ada di Ootday.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Color(0xFF5F1D1D),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // === INDICATOR ===
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Container(
                  width: 8,
                  height: 8,

                  margin: const EdgeInsets.symmetric(horizontal: 4),

                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),

                Container(
                  width: 8,
                  height: 8,

                  margin: const EdgeInsets.symmetric(horizontal: 4),

                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),

                Container(
                  width: 8,
                  height: 8,

                  margin: const EdgeInsets.symmetric(horizontal: 4),

                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // === TOMBOL MULAI ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),

              child: ElevatedButton(
                onPressed: () {

                  // Pindah ke halaman Login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6C7C7),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  minimumSize: const Size(
                    double.infinity,
                    45,
                  ),
                ),

                child: const Text(
                  "Mulai",

                  style: TextStyle(
                    color: Color(0xFF5F1D1D),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}