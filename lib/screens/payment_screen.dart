import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PaymentScreen extends StatefulWidget {
  final String slotId;
  final int slotNumber;
  final String name;
  final String vehicleNo;
  final DateTime startTime;
  final DateTime endTime;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.slotId,
    required this.slotNumber,
    required this.name,
    required this.vehicleNo,
    required this.startTime,
    required this.endTime,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String method = 'UPI';
  bool paying = false;
  bool done = false;

  double get amount => widget.amount;

  Future<void> _pay() async {
    setState(() => paying = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate

    // mark slot booked
    await FirebaseFirestore.instance
        .collection('slots')
        .doc(widget.slotId)
        .update({'isBooked': true});

    // save booking
    await FirebaseFirestore.instance.collection('bookings').add({
      'slotId': widget.slotId,
      'slotNumber': widget.slotNumber,
      'name': widget.name,
      'vehicleNo': widget.vehicleNo,
      'startTime': widget.startTime,
      'endTime': widget.endTime,
      'amount': amount,
      'method': method,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // generate receipt pdf
    try {
      await _generateReceiptPdf();
    } catch (_) {
      // ignore if pdf fails
    }

    setState(() {
      paying = false;
      done = true;
    });

    // Return true to BookingScreen
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _generateReceiptPdf() async {
    final pdf = pw.Document();
    final f = DateFormat('dd MMM yyyy, hh:mm a');

    pdf.addPage(
      pw.Page(
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Parking Receipt',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text('Name: ${widget.name}'),
                pw.Text('Vehicle: ${widget.vehicleNo}'),
                pw.Text('Slot: ${widget.slotNumber}'),
                pw.Text('Start: ${f.format(widget.startTime)}'),
                pw.Text('End: ${f.format(widget.endTime)}'),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Amount: ₹${amount.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 12),
                pw.Text('Payment method: $method'),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/receipt_slot${widget.slotNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('hh:mm a, dd MMM yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Slot ${widget.slotNumber}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Name: ${widget.name}'),
                  Text('Vehicle: ${widget.vehicleNo}'),
                  Text(
                    'Time: ${dateFmt.format(widget.startTime)} - ${dateFmt.format(widget.endTime)}',
                  ),
                  const Divider(height: 20),
                  Text(
                    'Total: ₹${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: method,
                    items: ['UPI', 'Card', 'Netbanking']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => method = v ?? 'UPI'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Payment method',
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: paying ? null : _pay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: paying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Pay Now'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
