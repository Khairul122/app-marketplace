import 'package:flutter/material.dart';
import 'package:ootday_owner/onboarding2.dart';
import 'package:ootday_owner/login.dart';

class OnBoarding1 extends StatelessWidget {
  const OnBoarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            // Tombol Skip kanan atas
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  GestureDetector(
                    onTap: () {

                      // Pindah ke halaman login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(30),
                      ),

                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Gambar
            Expanded(
              child: Center(
                child: Image.asset(
                  "assets/onboarding1.png",
                  height: 260,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Judul
            const Text(
              "Be your style",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF7A3E3E),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            // Deskripsi
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Tampil percaya diri dengan koleksi busana pilihan. "
                "Temukan outfit casual, formal, hingga trendy "
                "yang bikin kamu makin kece setiap hari.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7A3E3E),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                dot(true),
                dot(false),
              ],
            ),

            const SizedBox(height: 30),

            // Tombol Selanjutnya
            Padding(
              padding: const EdgeInsets.only(bottom: 40),

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A3E3E),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                onPressed: () {

                  // Pindah ke onboarding 2
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Onboarding2(),
                    ),
                  );
                },

                child: const Text(
                  "Selanjutnya",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Dot Indicator
  Widget dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      margin: const EdgeInsets.symmetric(horizontal: 5),

      width: active ? 12 : 8,
      height: active ? 12 : 8,

      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF7A3E3E)
            : Colors.grey,

        shape: BoxShape.circle,
      ),
    );
  }
}