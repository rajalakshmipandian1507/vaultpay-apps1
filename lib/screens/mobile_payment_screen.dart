import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MobilePaymentScreen extends StatefulWidget {
  const MobilePaymentScreen({super.key});

  @override
  State<MobilePaymentScreen> createState() =>
      _MobilePaymentScreenState();
}

class _MobilePaymentScreenState
    extends State<MobilePaymentScreen> {
  final TextEditingController mobileController =
      TextEditingController();

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController otpController =
      TextEditingController();

  final TextEditingController pinController =
      TextEditingController();

  bool isLoading = false;

  // Change this if your laptop IP changes.
  final String backendUrl =
      'http://192.168.129.73:5000';

  @override
  void dispose() {
    mobileController.dispose();
    amountController.dispose();
    otpController.dispose();
    pinController.dispose();
    super.dispose();
  }

  // ============================================================
  // AI RISK API
  // ============================================================

  Future<Map<String, dynamic>> getAIRisk({
    required String mobile,
    required double amount,
  }) async {
    final Uri url = Uri.parse(
      '$backendUrl/api/risk/classify',
    );

    final Map<String, dynamic> body = {
      'known_contact': 0,
      'distance_km': 50,
      'amount': amount,
      'new_account': 1,
      'unusual_time': 1,
      'city_risk': 0,
      'audio_call': 0,
      'video_call': 0,
      'mule_account': 0,
      'suspicious_apk': 0,
      'scam_message': 0,

      // Mobile payment information
      'receiver': mobile,
    };

    debugPrint('AI REQUEST: ${jsonEncode(body)}');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    debugPrint(
      'AI RESPONSE: ${response.statusCode}',
    );

    debugPrint(
      response.body,
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Backend error ${response.statusCode}: ${response.body}',
      );
    }

    final dynamic result =
        jsonDecode(response.body);

    if (result is! Map<String, dynamic>) {
      throw Exception(
        'Invalid AI response',
      );
    }

    return result;
  }

  // ============================================================
  // START PAYMENT
  // ============================================================

  Future<void> startPayment() async {
    final String mobile =
        mobileController.text.trim();

    final String amountText =
        amountController.text.trim();

    if (mobile.length != 10) {
      showMessage(
        'Enter a valid 10-digit mobile number',
      );
      return;
    }

    final double? amount =
        double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      showMessage(
        'Enter a valid amount',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await getAIRisk(
        mobile: mobile,
        amount: amount,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      final String risk =
          (result['risk'] ?? 'UNKNOWN')
              .toString()
              .toUpperCase();

      final int score =
          result['score'] is num
              ? (result['score'] as num).toInt()
              : 0;

      final List<String> reasons =
          result['reasons'] is List
              ? (result['reasons'] as List)
                  .map(
                    (e) => e.toString(),
                  )
                  .toList()
              : [];

      showRiskResult(
        risk: risk,
        score: score,
        reasons: reasons,
        mobile: mobile,
        amount: amount,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'AI connection failed\n\n$e',
      );
    }
  }

  // ============================================================
  // RISK RESULT
  // ============================================================

  void showRiskResult({
    required String risk,
    required int score,
    required List<String> reasons,
    required String mobile,
    required double amount,
  }) {
    Color color;

    IconData icon;

    if (risk == 'LOW') {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (risk == 'MEDIUM') {
      color = Colors.orange;
      icon = Icons.warning;
    } else if (risk == 'HIGH') {
      color = Colors.red;
      icon = Icons.dangerous;
    } else {
      color = Colors.grey;
      icon = Icons.help;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$risk RISK',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'AI Score: $score%',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Mobile Number',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(mobile),

                const SizedBox(height: 12),

                const Text(
                  'Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  '₹${amount.toStringAsFixed(2)}',
                ),

                const SizedBox(height: 15),

                const Text(
                  'Risk Factors',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                if (reasons.isEmpty)
                  const Text(
                    'No additional risk factors.',
                  ),

                ...reasons.map(
                  (reason) => Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 5,
                    ),
                    child: Text(
                      '• $reason',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCEL',
              ),
            ),

            if (risk == 'LOW')
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  showSuccess();
                },
                child: const Text(
                  'PAY NOW',
                ),
              ),

            if (risk == 'MEDIUM')
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.orange,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  showOtp();
                },
                child: const Text(
                  'VERIFY',
                ),
              ),

            if (risk == 'HIGH')
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  showFreeze();
                },
                child: const Text(
                  'FREEZE',
                ),
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MEDIUM RISK - OTP
  // ============================================================

  void showOtp() {
    otpController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'OTP Verification',
          ),
          content: TextField(
            controller: otpController,
            keyboardType:
                TextInputType.number,
            maxLength: 6,
            decoration:
                const InputDecoration(
              labelText: 'Enter OTP',
              border:
                  OutlineInputBorder(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (otpController.text.length < 4) {
                  showMessage(
                    'Enter valid OTP',
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                showPin();
              },
              child: const Text(
                'VERIFY OTP',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PIN
  // ============================================================

  void showPin() {
    pinController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'PIN Verification',
          ),
          content: TextField(
            controller: pinController,
            obscureText: true,
            keyboardType:
                TextInputType.number,
            maxLength: 4,
            decoration:
                const InputDecoration(
              labelText: 'Enter 4-digit PIN',
              border:
                  OutlineInputBorder(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (pinController.text.length != 4) {
                  showMessage(
                    'Enter 4-digit PIN',
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                showFingerprint();
              },
              child: const Text(
                'VERIFY PIN',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // FINGERPRINT DEMO
  // ============================================================

  void showFingerprint() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Fingerprint Verification',
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fingerprint,
                size: 90,
                color: Colors.blue,
              ),
              SizedBox(height: 15),
              Text(
                'Touch fingerprint sensor to verify.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                showSuccess();
              },
              child: const Text(
                'VERIFY',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HIGH RISK
  // ============================================================

  void showFreeze() {
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
              Text('HIGH RISK'),
            ],
          ),
          content: const Text(
            'Suspicious payment detected.\n\n'
            'For your safety, the account will be temporarily frozen.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCEL',
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                showSecurityAlert();
              },
              child: const Text(
                'ONE-TAP FREEZE',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SECURITY ALERT
  // ============================================================

  void showSecurityAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Security Alert',
          ),
          content: const Text(
            'Suspicious transaction detected.\n\n'
            'Review the payment before continuing.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'REJECT',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                showDelay();
              },
              child: const Text(
                'ACCEPT',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SECURITY DELAY
  // ============================================================

  void showDelay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            '20-Minute Security Delay',
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                size: 70,
                color: Colors.orange,
              ),
              SizedBox(height: 15),
              Text(
                'Payment has been temporarily delayed for security.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                showFace();
              },
              child: const Text(
                'CONTINUE DEMO',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // FACE DEMO
  // ============================================================

  void showFace() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Face Verification',
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.face,
                size: 90,
                color: Colors.blue,
              ),
              SizedBox(height: 15),
              Text(
                'Verify your identity using face recognition.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                showFinalPin();
              },
              child: const Text(
                'VERIFY FACE',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // FINAL PIN
  // ============================================================

  void showFinalPin() {
    pinController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Final PIN Verification',
          ),
          content: TextField(
            controller: pinController,
            obscureText: true,
            keyboardType:
                TextInputType.number,
            maxLength: 4,
            decoration:
                const InputDecoration(
              labelText: 'Enter 4-digit PIN',
              border:
                  OutlineInputBorder(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (pinController.text.length != 4) {
                  showMessage(
                    'Enter 4-digit PIN',
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                showSuccess();
              },
              child: const Text(
                'CONFIRM',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SUCCESS
  // ============================================================

  void showSuccess() {
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
              Text(
                'Payment Successful',
              ),
            ],
          ),
          content: Text(
            'Payment verified successfully.\n\n'
            'Mobile: ${mobileController.text}\n'
            'Amount: ₹${amountController.text}',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text(
                'DONE',
              ),
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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pay to Mobile Number',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Center(
              child: Icon(
                Icons.phone_android,
                size: 80,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Mobile Number',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: mobileController,
              keyboardType:
                  TextInputType.phone,
              maxLength: 10,
              decoration:
                  const InputDecoration(
                prefixIcon:
                    Icon(Icons.phone),
                prefixText: '+91 ',
                hintText: 'Enter mobile number',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(
                prefixIcon:
                    Icon(Icons.currency_rupee),
                hintText: 'Enter amount',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : startPayment,
                child: isLoading
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child:
                            CircularProgressIndicator(),
                      )
                    : const Text(
                        'CONTINUE',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'VaultPay AI will analyze the transaction before payment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}