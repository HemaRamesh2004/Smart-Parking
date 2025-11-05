import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewScreen extends StatefulWidget {
  final int slotNumber;
  const ReviewScreen({super.key, required this.slotNumber});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int stars = 0;
  bool submitting = false;

  Future<void> _submit() async {
    if (stars == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select stars')));
      return;
    }
    setState(() => submitting = true);
    await FirebaseFirestore.instance.collection('reviews').add({
      'slotNumber': widget.slotNumber,
      'rating': stars,
      'ts': FieldValue.serverTimestamp(),
    });
    setState(() => submitting = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Slot ${widget.slotNumber}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How was your experience?',
              style: TextStyle(fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => IconButton(
                  icon: Icon(
                    Icons.star,
                    color: i < stars ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => setState(() => stars = i + 1),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: submitting ? null : _submit,
              child: submitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
