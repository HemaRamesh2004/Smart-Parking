import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _vehicle = TextEditingController();
  File? _file;
  String? _imageUrl;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    _email = u.email;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(u.uid)
        .get();
    if (doc.exists) {
      final d = doc.data()!;
      _name.text = d['name'] ?? '';
      _vehicle.text = d['vehicle'] ?? '';
      _imageUrl = d['imageUrl'];
    }
    setState(() {});
  }

  Future<void> _pick() async {
    final p = ImagePicker();
    final picked = await p.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _file = File(picked.path));
  }

  Future<void> _save() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    String? url = _imageUrl;
    if (_file != null) {
      final ref = FirebaseStorage.instance.ref('profile/${u.uid}.jpg');
      await ref.putFile(_file!);
      url = await ref.getDownloadURL();
    }
    await FirebaseFirestore.instance.collection('users').doc(u.uid).set({
      'name': _name.text.trim(),
      'vehicle': _vehicle.text.trim(),
      'email': _email,
      'imageUrl': url,
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    setState(() => _imageUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F3F), Color(0xFF007BFF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 120),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pick,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 66,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 62,
                        backgroundImage: _file != null
                            ? FileImage(_file!)
                            : (_imageUrl != null
                                  ? NetworkImage(_imageUrl!) as ImageProvider
                                  : const AssetImage(
                                      'assets/default_avatar.png',
                                    )),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _field(_name, 'Full name'),
                    const SizedBox(height: 12),
                    _field(_vehicle, 'Vehicle number'),
                    const SizedBox(height: 12),
                    if (_email != null)
                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.white70),
                          const SizedBox(width: 8),
                          Text(
                            _email!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person, color: Colors.white70),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
