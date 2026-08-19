import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'freeze_account_screen.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController mobileController =
      TextEditingController();

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController otpController =
      TextEditingController();

  final TextEditingController pinController =
      TextEditingController();

  final TextEditingController emailOtpController =
      TextEditingController();

  String riskLevel = "";

  bool loading = false;

  @override
  void dispose() {
    mobileController.dispose();
    amountController.dispose();
    otpController.dispose();
    pinController.dispose();
    emailOtpController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND MONEY
  // ============================================================

  Future<void> sendMoney() async {
    final mobile = mobileController.text.trim();
    final amountText = amountController.text.trim();

    if (mobile.isEmpty) {
      showMessage("Enter mobile number");
      return;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      showMessage("Enter valid 10-digit mobile number");
      return;
    }

    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      showMessage("Enter valid amount");
      return;
    }

    setState(() {
      loading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final risk = classifyRisk(
      mobile: mobile,
      amount: amount,
    );

    if (!mounted) return;

    setState(() {
      loading = false;
      riskLevel = risk;
    });

    showRiskResult(risk);
  }

  // ============================================================
  // RISK CLASSIFICATION
  // ============================================================

  String classifyRisk({
    required String mobile,
    required double amount,
  }) {
    // ----------------------------------------------------------
    // HIGH RISK
    // ----------------------------------------------------------

    if (amount >= 60000) {
      return "HIGH";
    }

    // Demo mobile number classification
    //
    // 1,2,6 -> HIGH

    final firstDigit = mobile.substring(0, 1);

    if (firstDigit == "1" ||
        firstDigit == "2" ||
        firstDigit == "6") {
      return "HIGH";
    }

    // ----------------------------------------------------------
    // MEDIUM RISK
    // ----------------------------------------------------------

    if (amount >= 10000) {
      return "MEDIUM";
    }

    // 3,4,5 -> MEDIUM

    if (firstDigit == "3" ||
        firstDigit == "4" ||
        firstDigit == "5") {
      return "MEDIUM";
    }

    // ----------------------------------------------------------
    // LOW RISK
    // ----------------------------------------------------------

    return "LOW";
  }

  // ============================================================
  // RISK RESULT
  // ============================================================

  void showRiskResult(String risk) {
    Color riskColor;
    IconData riskIcon;
    String description;

    if (risk == "LOW") {
      riskColor = Colors.green;
      riskIcon = Icons.check_circle;

      description =
          "Transaction appears normal. No unusual activity detected.";
    } else if (risk == "MEDIUM") {
      riskColor = Colors.orange;
      riskIcon = Icons.warning;

      description =
          "Some unusual transaction patterns were detected. "
          "Additional verification is required.";
    } else {
      riskColor = Colors.red;
      riskIcon = Icons.dangerous;

      description =
          "Multiple high-risk indicators were detected. "
          "Additional security protection is required.";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                riskIcon,
                color: riskColor,
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$risk RISK",
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                riskIcon,
                size: 80,
                color: riskColor,
              ),

              const SizedBox(height: 15),

              Text(
                description,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              Text(
                "Amount: ₹${amountController.text}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "To: ${mobileController.text}",
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("CANCEL"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                startSecurityFlow(risk);
              },
              child: const Text("CONTINUE"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SECURITY FLOW
  // ============================================================

  Future<void> startSecurityFlow(String risk) async {
    final prefs = await SharedPreferences.getInstance();

    final isRegistered =
        prefs.getBool('is_registered') ?? false;

    if (!isRegistered) {
      showMessage(
        "Please register your VaultPay account first.",
      );
      return;
    }

    // ----------------------------------------------------------
    // LOW
    // PIN -> CONFIRMATION
    // ----------------------------------------------------------

    if (risk == "LOW") {
      showPinVerification(
        title: "Payment PIN",
        nextStep: () {
          showPaymentConfirmation();
        },
      );
    }

    // ----------------------------------------------------------
    // MEDIUM
    // OTP -> FINGERPRINT -> PIN -> CONFIRMATION
    // ----------------------------------------------------------

    else if (risk == "MEDIUM") {
      showOtpVerification(
        title: "OTP Verification",
        nextStep: () {
          showDemoFingerprint(
            nextStep: () {
              showPinVerification(
                title: "Payment PIN",
                nextStep: () {
                  showPaymentConfirmation();
                },
              );
            },
          );
        },
      );
    }

    // ----------------------------------------------------------
    // HIGH
    //
    // ONE-TAP FREEZE
    // OR
    // CONTINUE
    // ----------------------------------------------------------

    else {
      showHighRiskOptions();
    }
  }

  // ============================================================
  // PIN VERIFICATION
  // ============================================================

  void showPinVerification({
    required String title,
    required VoidCallback nextStep,
  }) {
    pinController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.lock,
                color: Colors.blue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title),
              ),
            ],
          ),

          content: TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: "4-Digit Payment PIN",
              hintText: "Enter registration PIN",
              prefixIcon: Icon(Icons.pin),
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("CANCEL"),
            ),

            ElevatedButton(
              onPressed: () async {
                final enteredPin =
                    pinController.text.trim();

                if (enteredPin.length != 4) {
                  showMessage(
                    "Enter 4-digit PIN",
                  );
                  return;
                }

                final prefs =
                    await SharedPreferences.getInstance();

                final registeredPin =
                    prefs.getString(
                          'registered_pin',
                        ) ??
                        "";

                final isRegistered =
                    prefs.getBool(
                          'is_registered',
                        ) ??
                        false;

                if (!isRegistered) {
                  Navigator.pop(dialogContext);

                  showMessage(
                    "Please register your account first.",
                  );

                  return;
                }

                if (registeredPin.isEmpty) {
                  showMessage(
                    "Registered PIN not found. Please register again.",
                  );
                  return;
                }

                if (enteredPin != registeredPin) {
                  showMessage(
                    "Incorrect payment PIN",
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                nextStep();
              },
              child: const Text("VERIFY PIN"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // OTP VERIFICATION
  // ============================================================

  void showOtpVerification({
    required String title,
    required VoidCallback nextStep,
  }) {
    otpController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.sms,
                color: Colors.blue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user,
                size: 70,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              const Text(
                "OTP sent to your registered mobile number.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                  prefixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Demo OTP: 123456",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("CANCEL"),
            ),

            ElevatedButton(
              onPressed: () {
                if (otpController.text.trim() !=
                    "123456") {
                  showMessage(
                    "Invalid OTP. Use 123456 for demo.",
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                nextStep();
              },
              child: const Text("VERIFY OTP"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DEMO FINGERPRINT
  // ============================================================

  void showDemoFingerprint({
    required VoidCallback nextStep,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.fingerprint,
                color: Colors.blue,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Fingerprint Verification",
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.fingerprint,
                size: 110,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              const Text(
                "DEMO BIOMETRIC",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Fingerprint verified successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Hackathon demo only. "
                "No real biometric authentication is performed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                nextStep();
              },
              child: const Text("CONTINUE"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HIGH RISK OPTIONS
  //
  // HIGH RISK ->
  // ONE-TAP FREEZE
  // OR
  // CONTINUE
  // ============================================================

  void showHighRiskOptions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "HIGH RISK DETECTED",
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.security,
                size: 80,
                color: Colors.red,
              ),

              const SizedBox(height: 15),

              const Text(
                "VaultPay detected a potentially fraudulent transaction.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              Text(
                "Amount: ₹${amountController.text}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: const Text(
                  "Choose how you want to proceed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            // ==================================================
            // ONE-TAP FREEZE
            // ==================================================

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(
                  color: Colors.red,
                ),
              ),

              onPressed: () {
                Navigator.pop(dialogContext);

                oneTapFreeze();
              },

              icon: const Icon(
                Icons.lock,
              ),

              label: const Text(
                "ONE-TAP FREEZE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ==================================================
            // CONTINUE PAYMENT
            // ==================================================

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              onPressed: () {
                Navigator.pop(dialogContext);

                startHighRiskPayment();
              },

              child: const Text(
                "CONTINUE",
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ONE-TAP FREEZE
  // ============================================================

  Future<void> oneTapFreeze() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'account_frozen',
      true,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.lock,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Account Frozen",
                ),
              ),
            ],
          ),

          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock,
                size: 90,
                color: Colors.red,
              ),

              SizedBox(height: 15),

              Text(
                "Your VaultPay account has been frozen using One-Tap Freeze.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "Suspicious transactions are temporarily blocked.",
                textAlign: TextAlign.center,
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const FreezeAccountScreen(),
                  ),
                );
              },
              child: const Text(
                "VIEW FREEZE STATUS",
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HIGH RISK PAYMENT
  // ============================================================

  void startHighRiskPayment() {
    showDelayScreen();
  }

  // ============================================================
  // 20 MINUTE SECURITY DELAY
  // ============================================================

  void showDelayScreen() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.timer,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "20-Minute Security Delay",
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule,
                size: 90,
                color: Colors.red,
              ),

              const SizedBox(height: 15),

              const Text(
                "This high-risk payment has been placed under a 20-minute security delay.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: const Text(
                  "DEMO: The delay is simulated for the hackathon.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("CANCEL"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                showEmailApproval();
              },
              child: const Text(
                "CONTINUE DEMO",
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // EMAIL APPROVAL
  // ============================================================

  void showEmailApproval() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.email,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Email Approval",
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mark_email_read,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              const Text(
                "A payment approval request has been sent to your registered email.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              const Text(
                "Approve the transaction to continue.",
                textAlign: TextAlign.center,
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                showMessage(
                  "High-risk payment rejected.",
                );
              },
              child: const Text("REJECT"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                showEmailOtp();
              },
              child: const Text(
                "ACCEPT PAYMENT",
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // EMAIL OTP
  // ============================================================

  void showEmailOtp() {
    emailOtpController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.mark_email_read,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Email OTP Verification",
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.email,
                size: 75,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              const Text(
                "Enter the OTP received in your email.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              TextField(
                controller: emailOtpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: "Email OTP",
                  prefixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Demo Email OTP: 654321",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("CANCEL"),
            ),

            ElevatedButton(
              onPressed: () {
                if (emailOtpController.text.trim() !=
                    "654321") {
                  showMessage(
                    "Invalid email OTP. Use 654321 for demo.",
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                showDemoFaceVerification();
              },
              child: const Text(
                "VERIFY EMAIL OTP",
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DEMO FACE VERIFICATION
  // ============================================================

  void showDemoFaceVerification() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.face,
                color: Colors.blue,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Face Verification",
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.face,
                size: 110,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              const Text(
                "DEMO FACE VERIFICATION",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Face verified successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Hackathon demo only. "
                "No real face recognition is performed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // HIGH:
                // Face -> PIN -> Confirmation

                showPinVerification(
                  title: "Final Payment PIN",
                  nextStep: () {
                    showPaymentConfirmation();
                  },
                );
              },
              child: const Text(
                "CONTINUE",
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PAYMENT CONFIRMATION
  // ============================================================

  void showPaymentConfirmation() {
    final amount =
        amountController.text.trim();

    final mobile =
        mobileController.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.payment,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Confirm Payment",
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              Text(
                "Pay ₹$amount?",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "To Mobile: $mobile",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(10),
                  color: riskLevel == "LOW"
                      ? Colors.green.shade50
                      : riskLevel == "MEDIUM"
                          ? Colors.orange.shade50
                          : Colors.red.shade50,
                ),
                child: Text(
                  "Risk Level: $riskLevel",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: riskLevel == "LOW"
                        ? Colors.green
                        : riskLevel == "MEDIUM"
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("CANCEL"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                showPaymentSuccess();
              },
              child: const Text(
                "CONFIRM PAYMENT",
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PAYMENT SUCCESS
  // ============================================================

  void showPaymentSuccess() {
    showDialog(
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
                  "Payment Successful",
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),

              const SizedBox(height: 15),

              Text(
                "₹${amountController.text} sent successfully.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "To: ${mobileController.text}",
              ),

              const SizedBox(height: 10),

              Text(
                "Risk: $riskLevel",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                resetScreen();
              },
              child: const Text("DONE"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  void resetScreen() {
    mobileController.clear();
    amountController.clear();
    otpController.clear();
    pinController.clear();
    emailOtpController.clear();

    setState(() {
      riskLevel = "";
    });
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
    TextInputType keyboardType =
        TextInputType.text,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          counterText:
              maxLength != null ? null : "",
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
          "Send Money",
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.send,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 15),

            const Text(
              "Send Money",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Secure payment with VaultPay AI protection",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 35),

            // MOBILE NUMBER

            inputField(
              controller: mobileController,
              label: "Receiver Mobile Number",
              icon: Icons.phone,
              keyboardType:
                  TextInputType.phone,
              maxLength: 10,
            ),

            // AMOUNT

            inputField(
              controller: amountController,
              label: "Amount",
              icon: Icons.currency_rupee,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 10),

            // SECURITY INFO

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blue.shade100,
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "VaultPay automatically checks transaction "
                      "patterns before payment and applies the "
                      "appropriate security verification.",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // SEND BUTTON

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed:
                    loading ? null : sendMoney,
                icon: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),
                label: Text(
                  loading
                      ? "ANALYZING..."
                      : "SEND MONEY",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (riskLevel.isNotEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(15),
                  border: Border.all(
                    color: riskLevel == "LOW"
                        ? Colors.green
                        : riskLevel == "MEDIUM"
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
                child: Text(
                  "Current Risk: $riskLevel",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color: riskLevel == "LOW"
                        ? Colors.green
                        : riskLevel == "MEDIUM"
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ),

            const SizedBox(height: 25),

            const Text(
              "VaultPay Fraud Protection",
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