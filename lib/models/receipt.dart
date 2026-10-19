import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'receipt.dart'; // Your Hive model file

class ReceiptDetailsScreen extends StatefulWidget {
  final int receiptIndex; // Hive box index
  const ReceiptDetailsScreen({super.key, required this.receiptIndex});

  @override
  State<ReceiptDetailsScreen> createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends State<ReceiptDetailsScreen> {
  late Box<Receipt> receiptBox;
  late Receipt receipt;

  @override
  void initState() {
    super.initState();
    receiptBox = Hive.box<Receipt>('receiptsBox'); // Make sure box name matches main.dart
    receipt = receiptBox.getAt(widget.receiptIndex)!;
  }

  void _deleteReceipt() {
    receiptBox.deleteAt(widget.receiptIndex);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Receipt deleted successfully!"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _editReceipt() {
    final titleController = TextEditingController(text: receipt.title);
    final amountController = TextEditingController(text: receipt.amount);
    final dateController = TextEditingController(text: receipt.date);
    final merchantController = TextEditingController(text: receipt.vendor);
    final notesController = TextEditingController(text: receipt.notes);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF002744),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Edit Receipt",
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Title", titleController),
                const SizedBox(height: 10),
                _buildTextField("Amount", amountController, keyboard: TextInputType.number),
                const SizedBox(height: 10),
                _buildTextField("Date", dateController),
                const SizedBox(height: 10),
                _buildTextField("Merchant", merchantController),
                const SizedBox(height: 10),
                _buildTextField("Notes", notesController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                // Update Hive object
                receipt.title = titleController.text;
                receipt.amount = amountController.text;
                receipt.date = dateController.text;
                receipt.vendor = merchantController.text;
                receipt.notes = notesController.text;
                receipt.save();

                setState(() {}); // Refresh UI
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Receipt updated successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001323),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002744),
        elevation: 5,
        title: const Text("Receipt Details", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(onPressed: _editReceipt, icon: const Icon(Icons.edit, color: Colors.white)),
          IconButton(onPressed: _deleteReceipt, icon: const Icon(Icons.delete, color: Colors.red)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailCard("Title", receipt.title, Icons.receipt_long),
            _buildDetailCard("Amount", receipt.amount, Icons.attach_money),
            _buildDetailCard("Date", receipt.date, Icons.date_range),
            _buildDetailCard("Merchant", receipt.vendor, Icons.store),
            _buildDetailCard("Notes", receipt.notes, Icons.note),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004466), Color(0xFF001F33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00E5FF), size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
