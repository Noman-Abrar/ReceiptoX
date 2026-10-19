import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/receipt_model.dart';
import '../services/receipt_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_3d_card.dart';
import 'camera_screen.dart';
import 'receipt_details_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _openingCamera = false;

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ReceiptModel> _filterReceipts(List<ReceiptModel> receipts) {
    if (_searchQuery.isEmpty) return receipts;
    final q = _searchQuery.toLowerCase();
    return receipts
        .where((r) => r.vendor.toLowerCase().contains(q) || r.category.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _openCamera() async {
    if (_openingCamera) return;
    setState(() => _openingCamera = true);
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No camera found on this device')));
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CameraScreen(camera: cameras.first)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open camera: $e')));
    } finally {
      if (mounted) setState(() => _openingCamera = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: uid == null
          ? const Center(child: Text('No user logged in', style: TextStyle(color: Colors.white70)))
          : StreamBuilder<List<ReceiptModel>>(
              stream: ReceiptService.streamUserReceipts(uid),
              builder: (context, snapshot) {
                final receipts = snapshot.data ?? [];

                if (_currentIndex == 1) return const ProfileScreen();
                if (_currentIndex == 2) return StatsScreen(receipts: receipts);

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                return _buildReceiptsTab(receipts);
              },
            ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _openingCamera ? null : _openCamera,
              child: _openingCamera
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.camera_alt, color: Colors.black),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('ReceiptoX'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async => FirebaseAuth.instance.signOut(),
        ),
      ],
    );
  }

  Widget _buildReceiptsTab(List<ReceiptModel> receipts) {
    final filtered = _filterReceipts(receipts);

    return Column(
      children: [
        _buildSearchBar(),
        if (receipts.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No receipts yet.\nTap the camera button to scan one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 15),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final r = filtered[index];
                return ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Floating3DCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReceiptDetailsScreen(receipt: r)),
                      ),
                      child: _receiptCardContent(r),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search receipts...',
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: AppColors.surfaceLight,
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _receiptCardContent(ReceiptModel r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.18),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(_categoryIcon(r.category), color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.vendor,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${r.category} · ${r.date.toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          '\$${r.amount.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      case 'Entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Receipts'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
      ],
    );
  }
}