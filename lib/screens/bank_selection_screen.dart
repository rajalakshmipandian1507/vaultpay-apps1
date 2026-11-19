import 'package:flutter/material.dart';

class BankAccount {
  final String bankName;
  final String accountNumber;
  final String balance;

  BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.balance,
  });
}

class BankSelectionScreen extends StatefulWidget {
  const BankSelectionScreen({super.key});

  @override
  State<BankSelectionScreen> createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  int selectedIndex = 0;

  final List<BankAccount> bankAccounts = [
    BankAccount(
      bankName: "HDFC Bank",
      accountNumber: "•••• 4582",
      balance: "₹18,500",
    ),
    BankAccount(
      bankName: "SBI",
      accountNumber: "•••• 7214",
      balance: "₹42,000",
    ),
    BankAccount(
      bankName: "ICICI Bank",
      accountNumber: "•••• 9031",
      balance: "₹12,750",
    ),
    BankAccount(
      bankName: "Axis Bank",
      accountNumber: "•••• 6148",
      balance: "₹25,600",
    ),
    BankAccount(
      bankName: "Indian Bank",
      accountNumber: "•••• 3321",
      balance: "₹31,400",
    ),
  ];

  void continueWithBank() {
    final selectedBank = bankAccounts[selectedIndex];

    Navigator.pop(context, selectedBank);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Bank Account"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pay From",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choose the bank account you want to use for this payment.",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: bankAccounts.length,
              itemBuilder: (context, index) {
                final bank = bankAccounts[index];
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected
                          ? Colors.blue.withOpacity(0.06)
                          : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                bank.bankName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                bank.accountNumber,
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                "Available: ${bank.balance}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Radio<int>(
                          value: index,
                          groupValue: selectedIndex,
                          onChanged: (value) {
                            setState(() {
                              selectedIndex = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: continueWithBank,
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}