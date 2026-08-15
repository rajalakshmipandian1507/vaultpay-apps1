import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final aadhaarController = TextEditingController();
  final pinController = TextEditingController();
  final bankController = TextEditingController();
  final accountController = TextEditingController();
  final ifscController = TextEditingController();

  bool loading = false;

  // CHANGE THIS to your laptop IPv4 address
  final String backendUrl = "http://YOUR_IP_ADDRESS:5000";

  Future<void> registerUser() async {
    if (nameController.text.isEmpty ||
        mobileController.text.isEmpty ||
        aadhaarController.text.isEmpty ||
        pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$backendUrl/api/auth/register"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": nameController.text.trim(),
          "mobile": mobileController.text.trim(),
          "aadhaar": aadhaarController.text.trim(),
          "pin": pinController.text.trim(),
          "bankName": bankController.text.trim(),
          "accountNumber": accountController.text.trim(),
          "ifsc": ifscController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully!"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Registration failed"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot connect to server"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Widget buildField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VaultPay"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Create Your Account",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Secure Payments",
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            buildField(
              "Full Name",
              nameController,
            ),

            buildField(
              "Mobile Number",
              mobileController,
              keyboardType: TextInputType.phone,
            ),

            buildField(
              "Aadhaar Number",
              aadhaarController,
              keyboardType: TextInputType.number,
            ),

            buildField(
              "Create PIN",
              pinController,
              obscure: true,
              keyboardType: TextInputType.number,
            ),

            buildField(
              "Bank Name",
              bankController,
            ),

            buildField(
              "Account Number",
              accountController,
              keyboardType: TextInputType.number,
            ),

            buildField(
              "IFSC Code",
              ifscController,
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : registerUser,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Create Account",
                        style: TextStyle(fontSize: 17),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}