
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;
  bool loading = false;

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN USER
  // ============================================================

  Future<void> loginUser() async {
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();

    // ------------------------------------------------------------
    // EMPTY FIELD VALIDATION
    // ------------------------------------------------------------

    if (mobile.isEmpty) {
      showMessage("Enter your mobile number");
      return;
    }

    if (password.isEmpty) {
      showMessage("Enter your password");
      return;
    }

    // ------------------------------------------------------------
    // MOBILE VALIDATION
    // ------------------------------------------------------------

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      showMessage("Enter valid 10-digit mobile number");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // ----------------------------------------------------------
      // CHECK WHETHER USER REGISTERED
      // ----------------------------------------------------------

      final isRegistered =
          prefs.getBool('is_registered') ?? false;

      if (!isRegistered) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        showMessage(
          "No account found. Please register first.",
        );

        return;
      }

      // ----------------------------------------------------------
      // GET REGISTERED MOBILE AND PASSWORD
      // ----------------------------------------------------------

      final registeredMobile =
          prefs.getString('registered_mobile') ?? "";

      final registeredPassword =
          prefs.getString('registered_password') ?? "";

      // ----------------------------------------------------------
      // CHECK MOBILE
      // ----------------------------------------------------------

      if (mobile != registeredMobile) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        showMessage("Incorrect mobile number");
        return;
      }

      // ----------------------------------------------------------
      // CHECK PASSWORD
      // ----------------------------------------------------------

      if (password != registeredPassword) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        showMessage("Incorrect password");
        return;
      }

      // ----------------------------------------------------------
      // LOGIN SUCCESS
      // ----------------------------------------------------------

      await prefs.setBool('is_logged_in', true);

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      // ----------------------------------------------------------
      // GO TO HOME SCREEN
      // ----------------------------------------------------------

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        "Login failed. Please try again.",
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
          counterText: "",
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "VaultPay Login",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 35),

            // ----------------------------------------------------
            // LOGO
            // ----------------------------------------------------

            const Icon(
              Icons.account_balance_wallet,
              size: 85,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            const Text(
              "Welcome Back",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Login to your VaultPay account",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 35),

            // ----------------------------------------------------
            // MOBILE NUMBER
            // ----------------------------------------------------

            inputField(
              controller: mobileController,
              label: "Mobile Number",
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),

            // ----------------------------------------------------
            // PASSWORD
            // ----------------------------------------------------

            inputField(
              controller: passwordController,
              label: "Password",
              icon: Icons.lock,
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obscurePassword =
                        !obscurePassword;
                  });
                },
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ----------------------------------------------------
            // LOGIN BUTTON
            // ----------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed:
                    loading ? null : loginUser,

                child: loading
                    ? const SizedBox(
                        width: 25,
                        height: 25,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // ----------------------------------------------------
            // INFORMATION
            // ----------------------------------------------------

            const Text(
              "Use the mobile number and password\n"
              "created during registration.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "PIN is used separately for payment\n"
              "and balance verification.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}