import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class PaymentSecurityScreen extends StatefulWidget {
  final String paymentType;
  final String receiver;
  final String amount;
  final String riskLevel;

  const PaymentSecurityScreen({
    super.key,
    required this.paymentType,
    required this.receiver,
    required this.amount,
    required this.riskLevel,
  });

  @override
  State<PaymentSecurityScreen> createState() =>
      _PaymentSecurityScreenState();
}

class _PaymentSecurityScreenState
    extends State<PaymentSecurityScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  final TextEditingController pinController =
      TextEditingController();

  final TextEditingController otpController =
      TextEditingController();

  bool obscurePin = true;

  Timer? timer;

  int remainingSeconds = 0;

  @override
  void dispose() {
    pinController.dispose();
    otpController.dispose();
    timer?.cancel();
    super.dispose();
  }

  // ============================================================
  // START PAYMENT
  // ============================================================

  void startPayment() {
    final String risk =
        widget.riskLevel.toUpperCase();

    if (risk == "LOW") {
      showPinPage(
        nextAction: () {
          showFinalConfirmation();
        },
      );
    } else if (risk == "MEDIUM") {
      showOtpPage();
    } else {
      showHighRiskPage();
    }
  }

  // ============================================================
  // PIN PAGE
  // ============================================================

  void showPinPage({
    required VoidCallback nextAction,
  }) {
    pinController.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinVerificationPage(
          controller: pinController,
          obscurePin: obscurePin,
          onToggleVisibility: () {
            setState(() {
              obscurePin = !obscurePin;
            });
          },
          onVerify: () {
            if (pinController.text.length != 4) {
              showMessage(
                "Please enter your 4-digit PIN",
              );
              return;
            }

            Navigator.pop(context);

            nextAction();
          },
        ),
      ),
    );
  }

  // ============================================================
  // MEDIUM RISK OTP
  // ============================================================

  void showOtpPage() {
    otpController.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationPage(
          controller: otpController,
          onVerify: () {
            if (otpController.text != "123456") {
              showMessage(
                "Invalid OTP. Demo OTP is 123456",
              );
              return;
            }

            Navigator.pop(context);

            showBiometricVerification(
              nextAction: () {
                showPinPage(
                  nextAction: () {
                    showFinalConfirmation();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // DEVICE BIOMETRIC
  // ============================================================

  Future<void> showBiometricVerification({
    required VoidCallback nextAction,
  }) async {
    try {
      final bool canAuthenticate =
          await auth.canCheckBiometrics ||
              await auth.isDeviceSupported();

      if (!canAuthenticate) {
        showMessage(
          "Device fingerprint or face verification is not available.",
        );
        return;
      }

      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        showMessage(
          "No fingerprint or face is enrolled on this device.",
        );
        return;
      }

      final bool authenticated =
          await auth.authenticate(
        localizedReason:
            "Verify your identity to continue this payment",
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (!mounted) return;

      if (authenticated) {
        nextAction();
      } else {
        showMessage(
          "Biometric verification cancelled or failed.",
        );
      }
    } catch (e) {
      if (!mounted) return;

      showMessage(
        "Biometric verification failed.",
      );
    }
  }

  // ============================================================
  // HIGH RISK PAGE
  // ============================================================

  void showHighRiskPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HighRiskPage(
          amount: widget.amount,
          receiver: widget.receiver,
          onContinue: () {
            Navigator.pop(context);

            startHighRiskVerification();
          },
          onFreeze: () {
            Navigator.pop(context);

            freezeAccount();
          },
        ),
      ),
    );
  }

  // ============================================================
  // HIGH RISK SECURITY FLOW
  // ============================================================

  void startHighRiskVerification() {
    startSecurityDelay();
  }

  // ============================================================
  // 10 MINUTE DELAY
  // ============================================================

  void startSecurityDelay() {
    timer?.cancel();

    setState(() {
      remainingSeconds = 600;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecurityDelayPage(
          getRemainingTime: () => remainingSeconds,
        ),
      ),
    );

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;
          });
        } else {
          timer.cancel();

          Navigator.pop(context);

          showEmailOtpPage();
        }
      },
    );
  }

  // ============================================================
  // EMAIL OTP
  // ============================================================

  void showEmailOtpPage() {
    otpController.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmailOtpPage(
          controller: otpController,
          onVerify: () {
            if (otpController.text != "123456") {
              showMessage(
                "Invalid Email OTP. Demo OTP is 123456",
              );
              return;
            }

            Navigator.pop(context);

            showBiometricVerification(
              nextAction: () {
                showPinPage(
                  nextAction: () {
                    showFinalConfirmation();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // FINAL CONFIRMATION
  // ============================================================

  void showFinalConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentConfirmationPage(
          paymentType: widget.paymentType,
          receiver: widget.receiver,
          amount: widget.amount,
          onConfirm: () {
            Navigator.pop(context);

            showPaymentSuccess();
          },
        ),
      ),
    );
  }

  // ============================================================
  // FREEZE ACCOUNT
  // ============================================================

  void freezeAccount() {
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
          content: const Text(
            "Your account has been frozen successfully.\n\n"
            "The high-risk payment has been blocked.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text("DONE"),
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
                Icons.verified,
                color: Colors.green,
                size: 75,
              ),

              const SizedBox(height: 15),

              Text(
                "₹${widget.amount}",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Payment sent to\n${widget.receiver}",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text("DONE"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final String risk =
        widget.riskLevel.toUpperCase();

    Color riskColor;

    if (risk == "LOW") {
      riskColor = Colors.green;
    } else if (risk == "MEDIUM") {
      riskColor = Colors.orange;
    } else {
      riskColor = Colors.red;
    }

    IconData riskIcon;

    if (risk == "LOW") {
      riskIcon = Icons.check_circle;
    } else if (risk == "MEDIUM") {
      riskIcon = Icons.warning;
    } else {
      riskIcon = Icons.dangerous;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment Security",
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Icon(
              riskIcon,
              size: 90,
              color: riskColor,
            ),

            const SizedBox(height: 20),

            Text(
              "$risk RISK",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: riskColor,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(15),
                border: Border.all(
                  color: riskColor,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.paymentType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Receiver\n${widget.receiver}",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "₹${widget.amount}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (risk == "LOW")
              const Text(
                "Normal transaction detected.",
                textAlign: TextAlign.center,
              ),

            if (risk == "MEDIUM")
              const Text(
                "Additional OTP, device biometric and PIN verification are required.",
                textAlign: TextAlign.center,
              ),

            if (risk == "HIGH")
              const Text(
                "Suspicious transaction detected. "
                "Additional security verification is required.",
                textAlign: TextAlign.center,
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: startPayment,
                child: const Text(
                  "CONTINUE PAYMENT",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// PIN VERIFICATION PAGE
// =================================================================

class PinVerificationPage extends StatelessWidget {
  final TextEditingController controller;
  final bool obscurePin;
  final VoidCallback onToggleVisibility;
  final VoidCallback onVerify;

  const PinVerificationPage({
    super.key,
    required this.controller,
    required this.obscurePin,
    required this.onToggleVisibility,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PIN Verification",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 50),

            const Icon(
              Icons.lock,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 25),

            const Text(
              "Enter VaultPay PIN",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: controller,
              obscureText: obscurePin,
              keyboardType:
                  TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: "4-digit PIN",
                border:
                    const OutlineInputBorder(),
                prefixIcon: const Icon(
                  Icons.lock,
                ),
                suffixIcon: IconButton(
                  onPressed:
                      onToggleVisibility,
                  icon: Icon(
                    obscurePin
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onVerify,
                child: const Text(
                  "VERIFY PIN",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// OTP PAGE
// =================================================================

class OtpVerificationPage extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onVerify;

  const OtpVerificationPage({
    super.key,
    required this.controller,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "OTP Verification",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 50),

            const Icon(
              Icons.sms,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 25),

            const Text(
              "Enter OTP",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "OTP has been sent to your registered mobile number.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: controller,
              keyboardType:
                  TextInputType.number,
              maxLength: 6,
              decoration:
                  const InputDecoration(
                labelText: "6-digit OTP",
                border:
                    OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.password),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onVerify,
                child: const Text(
                  "VERIFY OTP",
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Demo OTP: 123456",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// HIGH RISK PAGE
// =================================================================

class HighRiskPage extends StatelessWidget {
  final String amount;
  final String receiver;
  final VoidCallback onContinue;
  final VoidCallback onFreeze;

  const HighRiskPage({
    super.key,
    required this.amount,
    required this.receiver,
    required this.onContinue,
    required this.onFreeze,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "High Risk Alert",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 35),

            const Icon(
              Icons.warning_amber,
              color: Colors.red,
              size: 90,
            ),

            const SizedBox(height: 20),

            const Text(
              "HIGH RISK PAYMENT",
              style: TextStyle(
                color: Colors.red,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "₹$amount → $receiver",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "VaultPay AI detected suspicious activity.\n\n"
              "Choose an action to continue.",
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onContinue,
                child: const Text(
                  "CONTINUE PAYMENT",
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: onFreeze,
                child: const Text(
                  "ONE-TAP FREEZE",
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// SECURITY DELAY PAGE
// =================================================================

class SecurityDelayPage extends StatefulWidget {
  final int Function() getRemainingTime;

  const SecurityDelayPage({
    super.key,
    required this.getRemainingTime,
  });

  @override
  State<SecurityDelayPage> createState() =>
      _SecurityDelayPageState();
}

class _SecurityDelayPageState
    extends State<SecurityDelayPage> {
  Timer? timer;

  int seconds = 600;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          seconds =
              widget.getRemainingTime();
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:"
        "${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Security Delay",
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer,
                size: 90,
                color: Colors.orange,
              ),

              const SizedBox(height: 25),

              const Text(
                "Payment Temporarily Delayed",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "For your security, this high-risk payment "
                "has been placed under a 10-minute delay.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "VaultPay security verification is in progress.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// EMAIL OTP PAGE
// =================================================================

class EmailOtpPage extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onVerify;

  const EmailOtpPage({
    super.key,
    required this.controller,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Email Verification",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 45),

            const Icon(
              Icons.email,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 25),

            const Text(
              "Email OTP Verification",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "A security OTP has been sent to your registered email.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: controller,
              keyboardType:
                  TextInputType.number,
              maxLength: 6,
              decoration:
                  const InputDecoration(
                labelText:
                    "Enter Email OTP",
                border:
                    OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onVerify,
                child: const Text(
                  "VERIFY EMAIL OTP",
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Demo OTP: 123456",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// PAYMENT CONFIRMATION PAGE
// =================================================================

class PaymentConfirmationPage
    extends StatelessWidget {
  final String paymentType;
  final String receiver;
  final String amount;
  final VoidCallback onConfirm;

  const PaymentConfirmationPage({
    super.key,
    required this.paymentType,
    required this.receiver,
    required this.amount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Confirm Payment",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 25),

            const Text(
              "Review Payment",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            _detail(
              "Payment Type",
              paymentType,
            ),

            _detail(
              "Receiver",
              receiver,
            ),

            _detail(
              "Amount",
              "₹$amount",
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onConfirm,
                child: const Text(
                  "CONFIRM & PAY",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _detail(
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin:
          const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),

          const Spacer(),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}