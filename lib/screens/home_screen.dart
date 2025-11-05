import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'booking_list_screen.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // header
            Container(
              width: double.infinity,
              height: size.height * 0.34,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF001F3F), Color(0xFF007BFF)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // lottie animation with fallback
                  SizedBox(
                    height: 140,
                    child: Lottie.asset(
                      'assets/animations/parking_animation.json',
                      repeat: true,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.local_parking,
                        color: Colors.white,
                        size: 90,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Smart Parking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Book slots & pay securely',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _featureCard(
                    context,
                    'View Slots',
                    'Check availability and book',
                    Icons.map,
                    Colors.blueAccent,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MapScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _featureCard(
                    context,
                    'My Bookings',
                    'Your active and past bookings',
                    Icons.receipt_long,
                    Colors.deepPurple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _featureCard(
                    context,
                    'Profile',
                    'Manage your profile',
                    Icons.person,
                    Colors.teal,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(
    BuildContext context,
    String t,
    String s,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          title: Text(
            t,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          subtitle: Text(s),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        ),
      ),
    );
  }
}
