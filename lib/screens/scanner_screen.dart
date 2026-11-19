
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController scannerController =
      MobileScannerController();

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController pinController =
      TextEditingController();

  final TextEditingController otpController =
      TextEditingController();

  String scannedText = "";
  String riskLevel = "";

  bool scanCompleted = false;

  // Demo risk factors
  bool nearby = true;
  bool knownContact = true;
  bool unusualTime = false;
  bool audioCall = false;
  bool muleAccount = false;
  bool liveVideo = false;
  bool scamSms = false;
  bool suspiciousApk = false;

  // Risk reasons for demo
  List<String> riskReasons = [];

  // Registered user details
  String registeredPin = "";
  String registeredMobile = "";
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    loadRegisteredUser();
  }

  @override
  void dispose() {
    scannerController.dispose();
    amountController.dispose();
    pinController.dispose();
    otpController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD REGISTERED USER
  // ============================================================

  Future<void> loadRegisteredUser() async {
    final prefs = await SharedPreferences.getInstance();

    final registered = prefs.getBool('is_registered') ?? false;

    final pin = prefs.getString('registered_pin') ?? "";
    final mobile = prefs.getString('registered_mobile') ?? "";

    if (!mounted) return;

    setState(() {
      isRegistered = registered;
      registeredPin = pin;
      registeredMobile = mobile;
    });
  }

  // ============================================================
  // QR DETECT
  // ============================================================

  void onQrDetected(BarcodeCapture capture) {
    if (scanCompleted) {
      return;
    }

    if (capture.barcodes.isEmpty) {
      return;
    }

    final String? value = capture.barcodes.first.rawValue;

    if (value == null || value.trim().isEmpty) {
      return;
    }

    setState(() {
      scannedText = value.trim();
      scanCompleted = true;
    });

    scannerController.stop();

    _showScanResult();
  }

  // ============================================================
  // QR RESULT
  // ============================================================

  void _showScanResult() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 25,
            bottom:
                MediaQuery.of(bottomSheetContext).viewInsets.bottom + 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "QR Code Scanned",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  scannedText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Enter Amount",
                  hintText: "Example: 500",
                  prefixText: "₹ ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                    analyzeRisk();
                  },
                  icon: const Icon(Icons.security),
                  label: const Text(
                    "CONTINUE",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // NORMAL RISK CLASSIFICATION
  // ============================================================

  String classifyRisk() {
    final double amount =
        double.tryParse(amountController.text.trim()) ?? 0;

    // HIGH RISK
    if (muleAccount ||
        liveVideo ||
        scamSms ||
        suspiciousApk ||
        amount >= 60000) {
      return "HIGH";
    }

    // MEDIUM RISK
    if (!nearby ||
        !knownContact ||
        unusualTime ||
        audioCall ||
        amount >= 10000) {
      return "MEDIUM";
    }

    // LOW RISK
    return "LOW";
  }

  // ============================================================
  // DEMO QR RISK
  // ============================================================

  String demoQrRisk(String text) {
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return "";
    }

    final firstCharacter = cleanText.substring(0, 1);

    if (firstCharacter == "9") {
      return "LOW";
    }

    if (["3", "4", "5"].contains(firstCharacter)) {
      return "MEDIUM";
    }

    if (["1", "2", "6"].contains(firstCharacter)) {
      return "HIGH";
    }

    return "";
  }

  // ============================================================
  // FINAL RISK
  // ============================================================

  String getFinalRisk() {
    final normalRisk = classifyRisk();
    final demoRisk = demoQrRisk(scannedText);

    if (demoRisk == "HIGH") {
      return "HIGH";
    }

    if (demoRisk == "MEDIUM") {
      return "MEDIUM";
    }

    if (demoRisk == "LOW") {
      return "LOW";
    }

    return normalRisk;
  }

  // ============================================================
  // GET DEMO RISK REASONS
  // ============================================================

  List<String> getRiskReasons(String risk) {
    final List<String> reasons = [];

    final double amount =
        double.tryParse(amountController.text.trim()) ?? 0;

    final demoRisk = demoQrRisk(scannedText);

    // QR DEMO CLASSIFICATION HAS PRIORITY
    if (demoRisk.isNotEmpty && demoRisk == risk) {
      final firstCharacter = scannedText.trim().substring(0, 1);

      reasons.add(
        "Demo QR pattern: QR starts with $firstCharacter",
      );

      if (risk == "HIGH") {
        reasons.add("QR demo classification: HIGH RISK");
      } else if (risk == "MEDIUM") {
        reasons.add("QR demo classification: MEDIUM RISK");
      } else {
        reasons.add("QR demo classification: LOW RISK");
      }

      return reasons;
    }

    // HIGH RISK REASONS
    if (risk == "HIGH") {
      if (liveVideo) {
        reasons.add("Live video call detected");
      }

      if (muleAccount) {
        reasons.add("Mule account detected");
      }

      if (scamSms) {
        reasons.add("Scam SMS detected");
      }

      if (suspiciousApk) {
        reasons.add("Suspicious APK detected");
      }

      if (amount >= 60000) {
        reasons.add("Large transaction amount detected");
      }
    }

    // MEDIUM RISK REASONS
    else if (risk == "MEDIUM") {
      if (unusualTime) {
        reasons.add("Unusual transaction time");
      }

      if (audioCall) {
        reasons.add("Audio call detected");
      }

      if (!knownContact) {
        reasons.add("Unknown contact");
      }

      if (!nearby) {
        reasons.add("Outside usual location");
      }

      if (amount >= 10000) {
        reasons.add("Transaction amount requires extra verification");
      }
    }

    // LOW RISK REASON
    else {
      reasons.add("No suspicious demo factors detected");
      reasons.add("Known contact and normal location");
      reasons.add("Normal transaction pattern");
    }

    if (reasons.isEmpty) {
      reasons.add("Demo risk classification");
    }

    return reasons;
  }

  // ============================================================
  // ANALYZE
  // ============================================================

  void analyzeRisk() {
    final amount =
        double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      showMessage("Enter a valid amount");
      return;
    }

    final risk = getFinalRisk();

    setState(() {
      riskLevel = risk;
      riskReasons = getRiskReasons(risk);
    });

    _showRiskResult(risk);
  }

  // ============================================================
  // RISK RESULT
  // ============================================================

  void _showRiskResult(String risk) {
    Color riskColor;
    IconData riskIcon;
    String description;

    if (risk == "LOW") {
      riskColor = Colors.green;
      riskIcon = Icons.check_circle;
      description =
          "Transaction appears normal. Basic payment verification is required.";
    } else if (risk == "MEDIUM") {
      riskColor = Colors.orange;
      riskIcon = Icons.warning;
      description =
          "Unusual transaction pattern detected. Additional verification is required.";
    } else {
      riskColor = Colors.red;
      riskIcon = Icons.dangerous;
      description =
          "High-risk transaction detected. Strong security verification is required.";
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
              Text(
                "$risk RISK",
                style: TextStyle(
                  color: riskColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  riskIcon,
                  size: 75,
                  color: riskColor,
                ),

                const SizedBox(height: 15),

                Text(
                  description,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 15),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Risk Reasons:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                ...riskReasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info,
                          color: riskColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(reason),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  "Amount: ₹${amountController.text}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 10),

                
              ],
            ),
          ),

          actions: [
            if (risk != "HIGH")
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text("CANCEL"),
              ),

            if (risk == "HIGH")
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  oneTapFreeze();
                },
                icon: const Icon(
                  Icons.lock,
                  color: Colors.red,
                ),
                label: const Text(
                  "ONE-TAP FREEZE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            ElevatedButton(
              style: risk == "HIGH"
                  ? ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    )
                  : null,
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
  // ONE-TAP FREEZE
  // ============================================================

  Future<void> oneTapFreeze() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('account_frozen', true);

    await prefs.setString(
      'freeze_reason',
      riskReasons.join(", "),
    );

    await prefs.setString(
      'frozen_receiver',
      scannedText,
    );

    await prefs.setString(
      'frozen_amount',
      amountController.text.trim(),
    );

    if (!mounted) return;

    scannerController.stop();

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
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text("Account Frozen"),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock,
                size: 90,
                color: Colors.red,
              ),

              const SizedBox(height: 15),

              const Text(
                "ONE-TAP FREEZE ACTIVATED",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Your account has been temporarily frozen to protect your money.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Blocked Amount: ₹${amountController.text}\n"
                  "Receiver: $scannedText",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                resetScanner();
              },
              child: const Text("DONE"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SECURITY FLOW
  // ============================================================

  void startSecurityFlow(String risk) {
    if (!isRegistered || registeredPin.isEmpty) {
      showMessage(
        "Please complete VaultPay registration first.",
      );
      return;
    }

    if (risk == "LOW") {
      showPinVerification(
        nextStep: () {
          showPaymentConfirmation();
        },
      );
    } else if (risk == "MEDIUM") {
      showOtpVerification(
        nextStep: () {
          showDemoFingerprint(
            nextStep: () {
              showPinVerification(
                nextStep: () {
                  showPaymentConfirmation();
                },
              );
            },
          );
        },
      );
    } else {
      showHighRiskFlow();
    }
  }

  // ============================================================
  // PIN VERIFICATION
  // ============================================================

  void showPinVerification({
    required VoidCallback nextStep,
  }) {
    pinController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.lock,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Text("Enter Payment PIN"),
            ],
          ),

          content: TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: "4-Digit PIN",
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
              onPressed: () {
                final enteredPin =
                    pinController.text.trim();

                if (enteredPin != registeredPin) {
                  showMessage(
                    "Incorrect payment PIN",
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                nextStep();
              },
              child: const Text("VERIFY"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // OTP
  // ============================================================

  void showOtpVerification({
    required VoidCallback nextStep,
  }) {
    otpController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.sms,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Text("OTP Verification"),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "OTP sent to registered mobile number\n"
                "******${registeredMobile.length >= 4 ? registeredMobile.substring(registeredMobile.length - 4) : registeredMobile}",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Demo OTP: 123456",
                style: TextStyle(
                  color: Colors.grey,
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
    VoidCallback? nextStep,
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
                size: 100,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              const Text(
                "DEMO BIOMETRIC",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
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

              const SizedBox(height: 8),

              const Text(
                "Hackathon demo verification.",
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

                if (nextStep != null) {
                  nextStep();
                } else {
                  showPaymentConfirmation();
                }
              },
              child: const Text("CONTINUE"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HIGH RISK FLOW
  // ============================================================

  void showHighRiskFlow() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.dangerous,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "HIGH RISK TRANSACTION",
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer,
                size: 75,
                color: Colors.red,
              ),

              const SizedBox(height: 15),

              const Text(
                "VaultPay has detected a high-risk transaction.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Payment will be delayed for 20 minutes as a security measure.",
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
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
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

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                showEmailApproval();
              },
              child: const Text("CONTINUE"),
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
              Text("Email Approval"),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mark_email_read,
                size: 75,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              const Text(
                "A payment approval request has been sent to your registered email.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              const Text(
                "Demo Email Approval",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("REJECT"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                showOtpVerification(
                  nextStep: () {
                    showDemoFaceVerification();
                  },
                );
              },
              child: const Text("ACCEPT PAYMENT"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // FACE VERIFICATION
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
                child: Text("Face Verification"),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.face,
                size: 100,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              const Text(
                "DEMO FACE VERIFICATION",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
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
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                showPinVerification(
                  nextStep: () {
                    showPaymentConfirmation();
                  },
                );
              },
              child: const Text("CONTINUE"),
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
    final amount = amountController.text.trim();

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
              Text("Confirm Payment"),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 75,
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

              const SizedBox(height: 10),

              Text(
                "To: $scannedText",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              Text(
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
              child: const Text("CONFIRM PAYMENT"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SUCCESS
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
              Text("Payment Successful"),
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

              Text("Risk: $riskLevel"),
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                resetScanner();
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

  void resetScanner() {
    amountController.clear();
    pinController.clear();
    otpController.clear();

    setState(() {
      scannedText = "";
      riskLevel = "";
      scanCompleted = false;

      riskReasons.clear();

      nearby = true;
      knownContact = true;
      unusualTime = false;
      audioCall = false;
      muleAccount = false;
      liveVideo = false;
      scamSms = false;
      suspiciousApk = false;
    });

    scannerController.start();
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan & Pay"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              scannerController.toggleTorch();
            },
            icon: const Icon(Icons.flash_on),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                MobileScanner(
                  controller: scannerController,
                  onDetect: onQrDetected,
                ),

                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                ),

                const Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Scan QR Code",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.security,
                    color: Colors.blue,
                    size: 35,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "VaultPay Risk Analyzer",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Scan a payment QR to analyze transaction risk before payment.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (riskLevel.isNotEmpty)
                    Text(
                      "Current Risk: $riskLevel",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: riskLevel == "LOW"
                            ? Colors.green
                            : riskLevel == "MEDIUM"
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
