import 'dart:io';

import 'package:Agragami/auth/widgets/text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/screen/login_screen.dart';
import '../../../cachehelper/chechehelper.dart';
import '../../../cachehelper/toast.dart';
import '../../../user/profile/service/userprofile_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  final _profileService = UserProfileService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _adminIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _userIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _nidController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _nomineeNameController = TextEditingController();
  final _nomineeRelationController = TextEditingController();
  bool _isLoading = false;
  String? _profileImageUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _profileService.getUserById(widget.userId);
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
        _userIdController.text = user.userId;
        _nomineeNameController.text = user.nomineeName;
        _nomineeRelationController.text = user.nomineeRelation;
        _nidController.text = user.nid;
        _birthdateController.text = user.birthdate;
        _profileImageUrl = user.profileImage; // 🔹 Add this field in your user model
      });
    }
  }
  Future<void> _logout(BuildContext context) async {
    try {
      // Firebase logout
      await FirebaseAuth.instance.signOut();

      // Local data clear
      await CacheHelper().clear();

      if (!context.mounted) return;

      // Login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      debugPrint('Logout Error: $e');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 800,
      maxHeight: 800,);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${widget.userId}.jpg');

      await ref.putFile(imageFile);

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String? imageUrl = _profileImageUrl;

      if (_selectedImage != null) {
        final uploadedUrl = await _uploadImage(_selectedImage!);
        if (uploadedUrl != null) imageUrl = uploadedUrl;
      }

      await _profileService.updateUser(
          widget.userId, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'user_id': _userIdController.text.trim(),
        'nomineeName': _nomineeNameController.text.trim(),
        'nid': _nidController.text.trim(),
        'birthdate': _birthdateController.text.trim(),
        'profileImage': imageUrl ?? '',
      });

      setState(() {
        _isEditing = false;
        _isLoading = false;
        _profileImageUrl = imageUrl;
      });

      CustomToast().showToast(context, 'Profile updated successfully', Colors.green);
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _userIdController.dispose();
    _nomineeNameController.dispose();
    _nidController.dispose();
    _birthdateController.dispose();
    _nomineeRelationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body:Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 90,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (_profileImageUrl?.isNotEmpty ?? false)
                            ? CachedNetworkImageProvider(
                          _profileImageUrl!,
                        )
                            : const AssetImage(
                          'assets/images/image_profile.png',
                        ) as ImageProvider,
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Name',
                      enabled:_isEditing ,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 12),
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        enabled:  false,
                      ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _adminIdController,
                      labelText: 'Admin Id',
                      enabled:  false,
                    ),

                    const SizedBox(height: 12),
                    CustomTextField(
                      controller:_phoneController,
                      labelText: 'Cell Number',
                      enabled:  _isEditing,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter your phone number' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller:_nidController,
                      labelText: 'NID',
                      enabled:  false,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller:_addressController,
                      labelText: 'Address',
                      enabled:  _isEditing,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter your address' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller:_birthdateController,
                      labelText: 'Date of Birth',
                      enabled:  _isEditing,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter your birthdate' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller:_nomineeNameController,
                      labelText: 'Nominee Name',
                      enabled:  false,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller:_nomineeRelationController,
                      labelText: ' Relation with Applicant',
                      enabled:  false,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Uploading Image...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
