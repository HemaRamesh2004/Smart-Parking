import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_screen.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatefulWidget {
  final int slotNumber;
  final String slotId; // document id in Firestore

  const BookingScreen({
    super.key,
    required this.slotNumber,
    required this.slotId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final vehicleCtrl = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  double totalPrice = 0.0;

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          startTime = picked;
        else
          endTime = picked;
      });
      _calcPrice();
    }
  }

  void _calcPrice() {
    if (startTime != null && endTime != null) {
      final s = startTime!.hour + startTime!.minute / 60.0;
      final e = endTime!.hour + endTime!.minute / 60.0;
      final dur = max(0, e - s);
      setState(() => totalPrice = dur * 50); // ₹50/hr
    }
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate() ||
        startTime == null ||
        endTime == null ||
        totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all details and choose times')),
      );
      return;
    }

    final paid = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          slotId: widget.slotId,
          slotNumber: widget.slotNumber,
          name: nameCtrl.text.trim(),
          vehicleNo: vehicleCtrl.text.trim(),
          startTime: DateTime.now().copyWith(
            hour: startTime!.hour,
            minute: startTime!.minute,
          ),
          endTime: DateTime.now().copyWith(
            hour: endTime!.hour,
            minute: endTime!.minute,
          ),
          amount: totalPrice,
        ),
      ),
    );

    // PaymentScreen returns true on successful payment
    if (paid == true) {
      // Save booking record (PaymentScreen already saved booking and updated slot; but in case PaymentScreen didn't)
      // We return true to MapScreen so it can also mark slot booked (redundant safe).
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Slot ${widget.slotNumber}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F3F), Color(0xFF007BFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Colors.white),
                  labelText: 'Full name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: vehicleCtrl,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter vehicle number' : null,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                  ),
                  labelText: 'Vehicle number',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _timeTile('Start Time', startTime, () => _pickTime(true)),
              const SizedBox(height: 8),
              _timeTile('End Time', endTime, () => _pickTime(false)),
              const SizedBox(height: 16),
              if (totalPrice > 0)
                Center(
                  child: Text(
                    'Total: ₹${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _proceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Proceed to Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeTile(String label, TimeOfDay? t, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              t == null ? label : '$label: ${t.format(context)}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
