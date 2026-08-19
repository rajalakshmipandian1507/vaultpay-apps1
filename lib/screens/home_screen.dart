import 'package:flutter/material.dart';

import 'scanner_screen.dart';
import 'send_money_screen.dart';
import 'transaction_history_screen.dart';
import 'freeze_account_screen.dart';
import 'auto_debit_screen.dart';
import 'balance_screen.dart';
import 'recharge_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  void onBottomNavigationTap(int index) {
    if (index == 0) {
      setState(() {
        currentIndex = 0;
      });
      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AutoDebitScreen(),
        ),
      ).then((_) {
        if (!mounted) return;

        setState(() {
          currentIndex = 0;
        });
      });

      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FreezeAccountScreen(),
        ),
      ).then((_) {
        if (!mounted) return;

        setState(() {
          currentIndex = 0;
        });
      });

      return;
    }
  }

  // ============================================================
  // CHECK BALANCE
  // ============================================================

  void openBalanceScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BalanceScreen(),
      ),
    );
  }

  // ============================================================
  // SCAN QR
  // ============================================================

  void openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannerScreen(),
      ),
    );
  }

  // ============================================================
  // SEND MONEY
  // ============================================================

  void openSendMoney() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SendMoneyScreen(),
      ),
    );
  }

  // ============================================================
  // RECHARGE
  // ============================================================

  void openRecharge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RechargeScreen(),
      ),
    );
  }

  // ============================================================
  // TRANSACTION HISTORY
  // ============================================================

  void openTransactionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const TransactionHistoryScreen(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'VaultPay',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // ==================================================
            // WELCOME
            // ==================================================

            const Text(
              'Welcome to VaultPay',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Secure payments with AI protection',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // QUICK ACTIONS
            // ==================================================

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // ROW 1
            // ==================================================

            Row(
              children: [

                // SCAN QR
                Expanded(
                  child: _actionButton(
                    icon: Icons.qr_code_scanner,
                    title: 'Scan QR',
                    onTap: openScanner,
                  ),
                ),

                const SizedBox(width: 12),

                // SEND MONEY
                Expanded(
                  child: _actionButton(
                    icon: Icons.send,
                    title: 'Send Money',
                    onTap: openSendMoney,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // ROW 2
            // ==================================================

            Row(
              children: [

                // RECHARGE
                Expanded(
                  child: _actionButton(
                    icon: Icons.phone_android,
                    title: 'Recharge',
                    onTap: openRecharge,
                  ),
                ),

                const SizedBox(width: 12),

                // HISTORY
                Expanded(
                  child: _actionButton(
                    icon: Icons.history,
                    title: 'History',
                    onTap: openTransactionHistory,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // ROW 3 - CHECK BALANCE
            // ==================================================

            Row(
              children: [

                Expanded(
                  child: _actionButton(
                    icon: Icons.account_balance_wallet,
                    title: 'Check Balance',
                    onTap: openBalanceScreen,
                  ),
                ),

                const SizedBox(width: 12),

                // EMPTY SPACE
                const Expanded(
                  child: SizedBox(
                    height: 105,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==================================================
            // SECURITY STATUS
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green,
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Icon(
                    Icons.security,
                    color: Colors.green,
                    size: 35,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          'Security Status',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Your account is protected by VaultPay AI.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // FRAUD PROTECTION
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.shade200,
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 30,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          'Fraud Protection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'VaultPay AI analyzes transactions '
                          'and classifies them as LOW, MEDIUM '
                          'or HIGH risk.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Center(
              child: Text(
                'VaultPay Security',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onBottomNavigationTap,
        type: BottomNavigationBarType.fixed,
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.autorenew),
            label: 'Auto Debit',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Freeze',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 105,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 32,
              color: Colors.blue,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}