import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CardMate",
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  _buildClippedField(
                    controller.emailController,
                    "Email",
                    Icons.person,
                    false,
                    clipper: TopDiagonalClipper(),
                    isTop: true,
                  ),
                  _buildClippedField(
                    controller.passwordController,
                    "Password",
                    Icons.lock,
                    true,
                    clipper: BottomDiagonalClipper(),
                    isTop: false,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "LOGIN",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 7),
              Column(
                children: [
                  TextButton(
                    onPressed: () => Get.toNamed('/register'),
                    child: const Text(
                      "CREATE ACCOUNT",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 1,
                    color: Colors.black26,
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClippedField(
    TextEditingController controller,
    String hint,
    IconData icon,
    bool isPassword, {
    required CustomClipper<Path> clipper,
    required bool isTop,
  }) {
    return CustomPaint(
      painter: DiagonalBorderPainter(isTop: isTop),
      child: ClipPath(
        clipper: clipper,
        child: Container(
          height: 65,
          color: const Color(0xFFF9F9F9),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 48.0, right: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: controller,
                    obscureText: isPassword,
                    style: const TextStyle(color: Colors.black87),
                    cursorColor: const Color.fromARGB(255, 106, 105, 105),
                    decoration: const InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                      isDense: true,
                    ).copyWith(
                      hintText: hint,
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.only(top: 7),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 23,
                child: Icon(
                  icon,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────── Clipper / Painter ─────────

class DiagonalBorderPainter extends CustomPainter {
  final bool isTop;

  DiagonalBorderPainter({required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    if (isTop) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height - 20);
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(0, 20);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TopDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - 20)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 20)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
