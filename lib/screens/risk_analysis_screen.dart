import 'package:flutter/material.dart';

class RiskAnalysisScreen extends StatelessWidget {
  final String qrData;

  const RiskAnalysisScreen({
    super.key,
    required this.qrData,
  });

  String get risk {
    // Temporary demo risk logic.
    // Later we will connect this with the real AI/backend.
    if (qrData.length < 20) {
      return "LOW";
    } else if (qrData.length < 50) {
      return "MEDIUM";
    } else {
      return "HIGH";
    }
  }

  Color get riskColor {
    switch (risk) {
      case "LOW":
        return Colors.green;
      case "MEDIUM":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  IconData get riskIcon {
    switch (risk) {
      case "LOW":
        return Icons.check_circle;
      case "MEDIUM":
        return Icons.warning;
      default:
        return Icons.dangerous;
    }
  }

  String get riskMessage {
    switch (risk) {
      case "LOW":
        return "This QR code appears safe. You can continue the transaction.";

      case "MEDIUM":
        return "This QR code needs additional verification before payment.";

      default:
        return "Suspicious QR code detected. Payment is blocked for your safety.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Security Check"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // =====================================================
            // AI ICON
            // =====================================================

            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                riskIcon,
                size: 55,
                color: riskColor,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "VaultPay AI Analysis",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // =====================================================
            // RISK CARD
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: riskColor,
                  width: 2,
                ),
              ),

              child: Column(
                children: [
                  const Text(
                    "TRANSACTION RISK",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "$risk RISK",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    riskMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =====================================================
            // QR DATA
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey.shade100,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "QR Information",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    qrData,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // HIGH RISK
            // =====================================================

            if (risk == "HIGH")
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Transaction blocked for your safety.",
                        ),
                      ),
                    );
                  },

                  icon: const Icon(Icons.lock),

                  label: const Text(
                    "Block Transaction",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // =====================================================
            // LOW / MEDIUM
            // =====================================================

            if (risk != "HIGH")
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: () {
                    if (risk == "MEDIUM") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Additional verification required.",
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Transaction approved.",
                          ),
                        ),
                      );
                    }
                  },

                  child: Text(
                    risk == "MEDIUM"
                        ? "Verify & Continue"
                        : "Continue Payment",

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 15),

            // =====================================================
            // CANCEL
            // =====================================================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // SECURITY FOOTER
            // =====================================================

            const Text(
              "Protected by VaultPay Security",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}