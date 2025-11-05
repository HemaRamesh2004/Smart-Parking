import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _ensureSlotsExist();
  }

  Future<void> _ensureSlotsExist() async {
    final col = _firestore.collection('slots');
    final snap = await col.get();
    if (snap.docs.isEmpty) {
      for (int i = 1; i <= 10; i++) {
        await col.doc('slot$i').set({'slotNumber': i, 'isBooked': false});
      }
    }
  }

  void _showAdminLoginDialog() {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Admin Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (userCtrl.text == 'admin' && passCtrl.text == '1234') {
                setState(() => isAdmin = true);
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin logged in')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid credentials')),
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSlotStatus(String slotId, bool status) async {
    await _firestore.collection('slots').doc(slotId).update({
      'isBooked': status,
    });
  }

  Future<void> _onSlotTap(DocumentSnapshot slot) async {
    final slotId = slot.id;
    final slotNumber = slot['slotNumber'] as int;
    final isBooked = slot['isBooked'] as bool? ?? false;

    if (isBooked) {
      if (isAdmin) {
        await _updateSlotStatus(slotId, false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Slot $slotNumber freed')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Slot $slotNumber already booked')),
        );
      }
      return;
    }

    // Navigate to booking; booking_screen will handle payment and return true if success
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(slotNumber: slotNumber, slotId: slotId),
      ),
    );

    if (result == true) {
      // booking confirmed -> mark booked
      await _updateSlotStatus(slotId, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Slot $slotNumber booked')));
    } else {
      // user cancelled booking -> no change
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Slots'),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (!isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: _showAdminLoginDialog,
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                setState(() => isAdmin = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin logged out')),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('slots')
            .orderBy('slotNumber')
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          // Grid with smaller tiles
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  4, // small tiles: 4 across (adjust for responsiveness)
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: docs.length,
            itemBuilder: (c, i) {
              final slot = docs[i];
              final isBooked = (slot['isBooked'] as bool?) ?? false;
              final slotNumber = slot['slotNumber'];
              return GestureDetector(
                onTap: () => _onSlotTap(slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isBooked ? Colors.redAccent : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isBooked ? Icons.local_parking : Icons.directions_car,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Slot $slotNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBooked ? 'Booked' : 'Available',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
