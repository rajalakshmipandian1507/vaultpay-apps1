import 'package:flutter/material.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final TextEditingController pinController =
      TextEditingController();

  bool obscurePin = true;

  final List<Map<String, dynamic>> banks = [
    {
      "name": "SBI",
      "icon": Icons.account_balance,
      "balance": "₹25,000.00",
    },
    {
      "name": "Bank of Baroda",
      "icon": Icons.account_balance,
      "balance": "₹18,500.00",
    },
    {
      "name": "HDFC Bank",
      "icon": Icons.account_balance,
      "balance": "₹32,750.00",
    },
    {
      "name": "ICICI Bank",
      "icon": Icons.account_balance,
      "balance": "₹21,300.00",
    },
    {
      "name": "Axis Bank",
      "icon": Icons.account_balance,
      "balance": "₹15,750.00",
    },
  ];

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  // ============================================================
  // SELECT BANK
  // ============================================================

  void selectBank(Map<String, dynamic> bank) {
    showPinDialog(bank);
  }

  // ============================================================
  // PIN DIALOG
  // ============================================================

  void showPinDialog(Map<String, dynamic> bank) {
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
                child: Text(
                  "${bank["name"]} Balance",
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter your 4-digit VaultPay PIN to securely check your balance.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              TextField(
                controller: pinController,
                obscureText: obscurePin,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: "Enter 4-digit PIN",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(
                    Icons.lock,
                  ),
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
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "CANCEL",
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (pinController.text.length != 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Enter a valid 4-digit PIN",
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                showBalance(bank);
              },
              child: const Text(
                "VERIFY",
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SHOW BALANCE
  // ============================================================

  void showBalance(Map<String, dynamic> bank) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  bank["name"],
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 70,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              const Text(
                "Available Balance",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                bank["balance"],
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Balance checked successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "DONE",
              ),
            ),
          ],
        );
      },
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
          "Check Balance",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Bank Account",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Choose a bank account to securely check your balance.",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView.builder(
                itemCount: banks.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> bank =
                      banks[index];

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 15,
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),

                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            Colors.blue.shade50,
                        child: Icon(
                          bank["icon"],
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),

                      title: Text(
                        bank["name"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          "Secure balance check",
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                      ),

                      onTap: () {
                        selectBank(bank);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}