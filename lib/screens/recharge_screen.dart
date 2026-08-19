import 'package:flutter/material.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final TextEditingController mobileController =
      TextEditingController();

  final TextEditingController amountController =
      TextEditingController();

  String selectedOperator = 'Jio';

  bool loading = false;

  @override
  void dispose() {
    mobileController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // ============================================================
  // CONFIRM RECHARGE
  // ============================================================

  void confirmRecharge() {
    final String mobile =
        mobileController.text.trim();

    final String amount =
        amountController.text.trim();

    if (mobile.length != 10) {
      _showMessage(
        'Enter a valid 10-digit mobile number.',
      );
      return;
    }

    if (amount.isEmpty ||
        double.tryParse(amount) == null ||
        double.parse(amount) <= 0) {
      _showMessage(
        'Enter a valid recharge amount.',
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.phone_android,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confirm Recharge',
                ),
              ),
            ],
          ),
          content: Text(
            'Mobile Number: $mobile\n\n'
            'Operator: $selectedOperator\n\n'
            'Amount: ₹${double.parse(amount).toStringAsFixed(2)}\n\n'
            'Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                processRecharge();
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
  // PROCESS RECHARGE
  // ============================================================

  Future<void> processRecharge() async {
    setState(() {
      loading = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    showRechargeSuccess();
  }

  // ============================================================
  // SUCCESS
  // ============================================================

  void showRechargeSuccess() {
    final String mobile =
        mobileController.text.trim();

    final String amount =
        amountController.text.trim();

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
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Recharge Successful',
                ),
              ),
            ],
          ),
          content: Text(
            'Mobile Number: $mobile\n\n'
            'Operator: $selectedOperator\n\n'
            'Amount: ₹${double.parse(amount).toStringAsFixed(2)}\n\n'
            'Your recharge has been completed successfully.',
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // QUICK AMOUNT
  // ============================================================

  Widget quickAmount(String amount) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          amountController.text = amount;
        });
      },
      child: Text('₹$amount'),
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
          'Mobile Recharge',
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 10),

            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(18),
                color: Colors.blue,
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.phone_android,
                    color: Colors.white,
                    size: 45,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Mobile Recharge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Recharge your mobile securely with VaultPay',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Mobile Number
            const Text(
              'Mobile Number',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: mobileController,
              keyboardType:
                  TextInputType.phone,
              maxLength: 10,

              decoration:
                  const InputDecoration(
                labelText:
                    'Enter mobile number',
                hintText:
                    '10-digit mobile number',
                border:
                    OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 15),

            // Operator
            const Text(
              'Select Operator',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedOperator,

              decoration:
                  const InputDecoration(
                border:
                    OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.sim_card),
              ),

              items: const [
                DropdownMenuItem(
                  value: 'Jio',
                  child: Text('Jio'),
                ),
                DropdownMenuItem(
                  value: 'Airtel',
                  child: Text('Airtel'),
                ),
                DropdownMenuItem(
                  value: 'Vi',
                  child: Text('Vi'),
                ),
                DropdownMenuItem(
                  value: 'BSNL',
                  child: Text('BSNL'),
                ),
              ],

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedOperator =
                      value;
                });
              },
            ),

            const SizedBox(height: 25),

            // Amount
            const Text(
              'Recharge Amount',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),

              decoration:
                  const InputDecoration(
                labelText:
                    'Enter amount',
                hintText:
                    'Example: 299',
                border:
                    OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.currency_rupee),
              ),
            ),

            const SizedBox(height: 15),

            // Quick amounts
            const Text(
              'Quick Select',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                quickAmount('199'),
                quickAmount('239'),
                quickAmount('299'),
                quickAmount('399'),
                quickAmount('499'),
                quickAmount('599'),
              ],
            ),

            const SizedBox(height: 30),

            // Security
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color:
                    Colors.green.shade50,
                borderRadius:
                    BorderRadius.circular(15),
                border: Border.all(
                  color:
                      Colors.green.shade200,
                ),
              ),

              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.security,
                    color: Colors.green,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'VaultPay security monitoring protects your recharge transaction.',
                      style: TextStyle(
                        color:
                            Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Recharge button
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed:
                    loading
                        ? null
                        : confirmRecharge,

                icon: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.flash_on,
                      ),

                label: Text(
                  loading
                      ? 'Processing...'
                      : 'RECHARGE NOW',

                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'VaultPay Secure Recharge',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}