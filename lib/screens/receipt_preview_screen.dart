import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/receipt_model.dart';
import '../services/receipt_ocr_service.dart';
import '../services/receipt_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_3d_card.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final String imagePath;

  const ReceiptPreviewScreen({super.key, required this.imagePath});

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  bool _isScanning = true;
  bool _isSaving = false;
  String _rawText = '';

  final _vendorController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Other';

  static const _categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Other'];

  @override
  void initState() {
    super.initState();
    _scanReceipt();
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _scanReceipt() async {
    final text = await ReceiptOCRService.scanReceipt(widget.imagePath);
    final parsed = ReceiptOCRService.parseReceiptText(text);

    if (!mounted) return;
    setState(() {
      _rawText = text;
      _vendorController.text = parsed.vendor;
      _amountController.text = parsed.amount > 0 ? parsed.amount.toStringAsFixed(2) : '';
      _selectedDate = parsed.date;
      _selectedCategory = parsed.category;
      _isScanning = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveReceipt() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (_vendorController.text.trim().isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a valid vendor and amount')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final imageUrl = await ReceiptService.uploadReceiptImage(user.uid, File(widget.imagePath));

      final receipt = ReceiptModel(
        id: '',
        userId: user.uid,
        vendor: _vendorController.text.trim(),
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory,
        rawText: _rawText,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await ReceiptService.saveReceipt(receipt);

      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save receipt: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Receipt')),
      body: _isScanning
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Reading receipt…', style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(widget.imagePath), height: 220, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),
                  _buildField('Vendor', _vendorController, Icons.store),
                  const SizedBox(height: 14),
                  _buildField('Amount', _amountController, Icons.attach_money,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 14),
                  _buildDateField(),
                  const SizedBox(height: 14),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 26),
                  Button3D(
                    label: _isSaving ? 'Saving…' : 'Save Receipt',
                    icon: Icons.save,
                    loading: _isSaving,
                    onPressed: _saveReceipt,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
        ),
      ),
    );
  }
}
