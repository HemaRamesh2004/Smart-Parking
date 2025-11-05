import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F3F), Color(0xFF007BFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('userEmail', isEqualTo: userEmail)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No bookings yet!',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              );
            }

            final bookings = snapshot.data!.docs;

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index].data() as Map<String, dynamic>;

                return Card(
                  color: Colors.white.withOpacity(0.15),
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_parking,
                      color: Colors.white,
                      size: 30,
                    ),
                    title: Text(
                      'Slot ${booking['slotNumber']} - ${booking['vehicle']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Name: ${booking['name']}\n'
                      'Start: ${booking['startTime']}\n'
                      'End: ${booking['endTime']}\n'
                      'Price: ₹${booking['price']}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
