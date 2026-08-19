import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vaultpay_user_data.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final aadhaarController = TextEditingController();
  final accountController = TextEditingController();
  final bankController = TextEditingController();
  final ifscController = TextEditingController();
  final pinController = TextEditingController();

  bool obscurePassword = true;
  bool obscurePin = true;
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    aadhaarController.dispose();
    accountController.dispose();
    bankController.dispose();
    ifscController.dispose();
    pinController.dispose();

    super.dispose();
  }

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();
    final aadhaar = aadhaarController.text.trim();
    final account = accountController.text.trim();
    final bank = bankController.text.trim();
    final ifsc = ifscController.text.trim();
    final pin = pinController.text.trim();

    // ---------------- VALIDATION ----------------

    if (name.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty ||
        aadhaar.isEmpty ||
        account.isEmpty ||
        bank.isEmpty ||
        ifsc.isEmpty ||
        pin.isEmpty) {
      showMessage("Please fill all fields");
      return;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      showMessage("Enter valid 10-digit mobile number");
      return;
    }

    if (!RegExp(r'^[0-9]{12}$').hasMatch(aadhaar)) {
      showMessage("Enter valid 12-digit Aadhaar number");
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(account) ||
        account.length < 8) {
      showMessage("Enter valid bank account number");
      return;
    }

    if (password.length < 6) {
      showMessage("Password must contain at least 6 characters");
      return;
    }

    if (!RegExp(r'^[0-9]{4}$').hasMatch(pin)) {
      showMessage("PIN must contain exactly 4 digits");
      return;
    }

    if (ifsc.length < 4) {
      showMessage("Enter valid IFSC code");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // ---------------- SAVE USER DATA ----------------

      await prefs.setString(
        'registered_name',
        name,
      );

      await prefs.setString(
        'registered_mobile',
        mobile,
      );

      await prefs.setString(
        'registered_password',
        password,
      );

      await prefs.setString(
        'registered_aadhaar',
        aadhaar,
      );

      await prefs.setString(
        'registered_account',
        account,
      );

      await prefs.setString(
        'registered_bank',
        bank,
      );

      await prefs.setString(
        'registered_ifsc',
        ifsc,
      );

      await prefs.setString(
        'registered_pin',
        pin,
      );

      // Mark user as registered
      await prefs.setBool(
        'is_registered',
        true,
      );

      // After registration user must login
      await prefs.setBool(
        'is_logged_in',
        false,
      );

      // ---------------- UPDATE GLOBAL USER DATA ----------------

      VaultPayUserData.name = name;
      VaultPayUserData.mobile = mobile;
      VaultPayUserData.password = password;
      VaultPayUserData.aadhaar = aadhaar;
      VaultPayUserData.accountNumber = account;
      VaultPayUserData.bankName = bank;
      VaultPayUserData.ifsc = ifsc;
      VaultPayUserData.pin = pin;
      VaultPayUserData.isRegistered = true;

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      // ---------------- SUCCESS DIALOG ----------------

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Registration Successful",
                  ),
                ),
              ],
            ),
            content: const Text(
              "Your VaultPay account has been created successfully.\n\n"
              "Now use your mobile number and password to login.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text("CONTINUE"),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // ---------------- GO TO LOGIN SCREEN ----------------

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        "Registration failed. Please try again.",
      );
    }
  }

  // ---------------- SHOW MESSAGE ----------------

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ---------------- INPUT FIELD ----------------

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
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLength: maxLength,
        textCapitalization: label == "IFSC Code"
            ? TextCapitalization.characters
            : TextCapitalization.none,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
          counterText: maxLength != null ? null : "",
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create VaultPay Account",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Icon(
              Icons.account_balance_wallet,
              size: 75,
              color: Colors.blue,
            ),

            const SizedBox(height: 15),

            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Register your VaultPay account",
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- NAME ----------------

            inputField(
              controller: nameController,
              label: "Full Name",
              icon: Icons.person,
            ),

            // ---------------- MOBILE ----------------

            inputField(
              controller: mobileController,
              label: "Mobile Number",
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),

            // ---------------- PASSWORD ----------------

            inputField(
              controller: passwordController,
              label: "Create Login Password",
              icon: Icons.lock,
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              ),
            ),

            // ---------------- AADHAAR ----------------

            inputField(
              controller: aadhaarController,
              label: "Aadhaar Number",
              icon: Icons.badge,
              keyboardType: TextInputType.number,
              maxLength: 12,
            ),

            // ---------------- ACCOUNT ----------------

            inputField(
              controller: accountController,
              label: "Bank Account Number",
              icon: Icons.account_balance,
              keyboardType: TextInputType.number,
            ),

            // ---------------- BANK ----------------

            inputField(
              controller: bankController,
              label: "Bank Name",
              icon: Icons.account_balance_wallet,
            ),

            // ---------------- IFSC ----------------

            inputField(
              controller: ifscController,
              label: "IFSC Code",
              icon: Icons.code,
            ),

            // ---------------- PIN ----------------

            inputField(
              controller: pinController,
              label: "Create 4-Digit Payment PIN",
              icon: Icons.pin,
              keyboardType: TextInputType.number,
              obscureText: obscurePin,
              maxLength: 4,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obscurePin = !obscurePin;
                  });
                },
                icon: Icon(
                  obscurePin
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ---------------- INFORMATION CARD ----------------

            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock,
                          size: 20,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Password is used for Login",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.pin,
                          size: 20,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "PIN is used for Payment and "
                            "Balance verification",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- CREATE ACCOUNT BUTTON ----------------

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: loading ? null : registerUser,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.person_add,
                      ),
                label: Text(
                  loading
                      ? "CREATING..."
                      : "CREATE ACCOUNT",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- FOOTER ----------------

            const Text(
              "Your password is used for login.\n"
              "Your 4-digit PIN is used to verify payments.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}