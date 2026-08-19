
import 'package:flutter/material.dart';

class AutoDebitScreen extends StatefulWidget {
  const AutoDebitScreen({super.key});

  @override
  State<AutoDebitScreen> createState() => _AutoDebitScreenState();
}

class _AutoDebitScreenState extends State<AutoDebitScreen> {
  final List<Map<String, dynamic>> autoDebits = [
    {
      'merchant': 'Netflix',
      'amount': 499.0,
      'date': '25 Aug 2026',
      'active': true,
      'suspicious': false,
    },
    {
      'merchant': 'Electricity Bill',
      'amount': 1200.0,
      'date': '28 Aug 2026',
      'active': true,
      'suspicious': false,
    },
    {
      'merchant': 'Unknown Merchant',
      'amount': 8500.0,
      'date': '30 Aug 2026',
      'active': true,
      'suspicious': true,
    },
  ];

  void toggleAutoDebit(int index) {
    setState(() {
      autoDebits[index]['active'] =
          !(autoDebits[index]['active'] as bool);
    });

    final bool active =
        autoDebits[index]['active'] as bool;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          active
              ? '${autoDebits[index]['merchant']} auto debit resumed'
              : '${autoDebits[index]['merchant']} auto debit paused',
        ),
      ),
    );
  }

  void blockAutoDebit(int index) {
    final String merchant =
        autoDebits[index]['merchant'] as String;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text('Block Auto Debit'),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to block the auto debit from $merchant?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  autoDebits[index]['active'] = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$merchant auto debit blocked',
                    ),
                  ),
                );
              },
              child: const Text('BLOCK'),
            ),
          ],
        );
      },
    );
  }

  void showAddAutoDebitDialog() {
    final merchantController =
        TextEditingController();
    final amountController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Auto Debit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: merchantController,
                decoration: const InputDecoration(
                  labelText: 'Merchant Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                merchantController.dispose();
                amountController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String merchant =
                    merchantController.text.trim();

                final double? amount =
                    double.tryParse(
                  amountController.text.trim(),
                );

                if (merchant.isEmpty ||
                    amount == null ||
                    amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter valid merchant and amount',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  autoDebits.add({
                    'merchant': merchant,
                    'amount': amount,
                    'date': 'Next scheduled date',
                    'active': true,
                    'suspicious': false,
                  });
                });

                merchantController.dispose();
                amountController.dispose();

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Auto debit added successfully',
                    ),
                  ),
                );
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Debit'),
        centerTitle: true,
      ),
      body: autoDebits.isEmpty
          ? const Center(
              child: Text(
                'No active auto debits',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.autorenew,
                        color: Colors.blue,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Manage your recurring payments and monitor suspicious auto debits.',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Active Auto Debits',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...List.generate(
                  autoDebits.length,
                  (index) {
                    final item =
                        autoDebits[index];

                    final String merchant =
                        item['merchant'] as String;

                    final double amount =
                        item['amount'] as double;

                    final String date =
                        item['date'] as String;

                    final bool active =
                        item['active'] as bool;

                    final bool suspicious =
                        item['suspicious'] as bool;

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      suspicious
                                          ? Colors.red
                                              .shade50
                                          : Colors.blue
                                              .shade50,
                                  child: Icon(
                                    suspicious
                                        ? Icons.warning
                                        : Icons.autorenew,
                                    color: suspicious
                                        ? Colors.red
                                        : Colors.blue,
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        merchant,
                                        style:
                                            const TextStyle(
                                          fontSize: 17,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        'Next debit: $date',
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${amount.toStringAsFixed(0)}',
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            if (suspicious)
                              Container(
                                width:
                                    double.infinity,
                                padding:
                                    const EdgeInsets.all(
                                  12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red
                                      .shade50,
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Suspicious auto debit detected. Review before the next payment.',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.red,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        () {
                                      toggleAutoDebit(
                                        index,
                                      );
                                    },
                                    icon: Icon(
                                      active
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    label: Text(
                                      active
                                          ? 'Pause'
                                          : 'Resume',
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                if (suspicious)
                                  Expanded(
                                    child:
                                        ElevatedButton.icon(
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red,
                                        foregroundColor:
                                            Colors.white,
                                      ),
                                      onPressed:
                                          () {
                                        blockAutoDebit(
                                          index,
                                        );
                                      },
                                      icon:
                                          const Icon(
                                        Icons.block,
                                      ),
                                      label:
                                          const Text(
                                        'Block',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed:
                        showAddAutoDebitDialog,
                    icon: const Icon(
                      Icons.add,
                    ),
                    label: const Text(
                      'Add Auto Debit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          Colors.grey.shade300,
                    ),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'VaultPay monitors recurring payments for unusual activity.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

