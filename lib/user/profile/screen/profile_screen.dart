import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../cachehelper/toast.dart';
import '../../../user/profile/service/userprofile_service.dart';
import 'package:agragami/auth/widgets/text_field.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  final _profileService = UserProfileService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _userIdController = TextEditingController();
  final _nomineeNameController = TextEditingController();
  final _nidController = TextEditingController();
  final _birthdateController = TextEditingController();

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
        _nidController.text = user.nid;
        _birthdateController.text = user.birthdate;
        _profileImageUrl = user.profileImage; // 🔹 Add this field in your user model
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

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
        /*final uploadedUrl = await _uploadImage(_selectedImage!);
        if (uploadedUrl != null) imageUrl = uploadedUrl;*/
      }

      await _profileService.updateUser(widget.userId, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'user_id': _userIdController.text.trim(),
        'nomineeName': _nomineeNameController.text.trim(),
        'nid': _nidController.text.trim(),
        'birthdate': _birthdateController.text.trim(),
        //'profileImage': imageUrl ?? '',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.red,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // 🔹 Profile Image
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                            ? NetworkImage(_profileImageUrl!) as ImageProvider
                            : const AssetImage('assets/images/agrogami_logo.png'),
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
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Text Fields
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Name',
                  enabled: _isEditing,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  enabled: false,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _userIdController,
                  labelText: 'User_id',
                  enabled: false,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone',
                  enabled: _isEditing,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Address',
                  maxLine: 2,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _nidController,
                  labelText: 'Nid',
                  enabled: _isEditing,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _nomineeNameController,
                  labelText: 'NomineeName',
                  enabled: false,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _birthdateController,
                  labelText: 'BirthDate',
                  enabled: _isEditing,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
