import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> transactions = [
      {
        'type': 'QR Payment',
        'receiver': 'Rahul',
        'amount': 500.0,
        'risk': 'LOW',
        'status': 'Successful',
        'date': '18 Aug 2026, 10:30 AM',
      },
      {
        'type': 'Send Money',
        'receiver': 'Unknown Contact',
        'amount': 15000.0,
        'risk': 'MEDIUM',
        'status': 'Verified',
        'date': '17 Aug 2026, 07:45 PM',
      },
      {
        'type': 'QR Payment',
        'receiver': 'Suspicious Account',
        'amount': 50000.0,
        'risk': 'HIGH',
        'status': 'Blocked',
        'date': '16 Aug 2026, 11:20 PM',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                final String risk =
                    transaction['risk'] as String;

                final String status =
                    transaction['status'] as String;

                final Color riskColor =
                    _getRiskColor(risk);

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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  riskColor.withOpacity(0.12),
                              child: Icon(
                                _getTransactionIcon(
                                  transaction['type']
                                      as String,
                                ),
                                color: riskColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction['type']
                                        as String,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    transaction['receiver']
                                        as String,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${(transaction['amount'] as double).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            _statusChip(
                              label: '$risk RISK',
                              color: riskColor,
                            ),
                            const SizedBox(width: 8),
                            _statusChip(
                              label: status,
                              color:
                                  _getStatusColor(status),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.black45,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              transaction['date']
                                  as String,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
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
    );
  }

  Color _getRiskColor(String risk) {
    if (risk == 'LOW') {
      return Colors.green;
    }

    if (risk == 'MEDIUM') {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _getStatusColor(String status) {
    if (status == 'Successful' ||
        status == 'Verified') {
      return Colors.green;
    }

    if (status == 'Blocked') {
      return Colors.red;
    }

    return Colors.orange;
  }

  IconData _getTransactionIcon(String type) {
    if (type == 'QR Payment') {
      return Icons.qr_code;
    }

    if (type == 'Send Money') {
      return Icons.send;
    }

    return Icons.account_balance_wallet;
  }

  Widget _statusChip({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}