import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PayFeesScreen extends StatelessWidget {
  final String studentId;

  PayFeesScreen({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay Fees"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('students').doc(studentId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var studentData = snapshot.data?.data() as Map<String, dynamic>?;
          var totalFees = (studentData?['total_fees'] ?? 0).toInt();
          var dueFees = (studentData?['due_fees'] ?? 0).toInt();
          var totalFeesPaid = (studentData?['total_fees_paid'] ?? 0).toInt();

          final _amountController = TextEditingController();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Fees: ₹${totalFees.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Fees Paid: ₹${totalFeesPaid.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Due Fees: ₹${dueFees.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter Amount to Pay:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Amount',
                    hintText: 'Enter amount to pay',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    var paymentAmount = double.tryParse(_amountController.text);
                    if (paymentAmount != null && paymentAmount > 0) {
                      if (paymentAmount > dueFees) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Payment amount exceeds due fees.")),
                        );
                        return;
                      }

                      // Update fees
                      await FirebaseFirestore.instance.collection('students').doc(studentId).update({
                        'due_fees': dueFees - paymentAmount,
                        'total_fees_paid': totalFeesPaid + paymentAmount,
                        'last_payment_date': DateTime.now(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Payment successful.")),
                      );

                      // Clear the text field
                      _amountController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a valid amount.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
