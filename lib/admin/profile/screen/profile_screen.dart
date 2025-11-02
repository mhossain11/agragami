import 'dart:io';

import 'package:Agragami/auth/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final _addressController = TextEditingController();
  final _nidController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _nomineeNameController = TextEditingController();
  final _nomineeRelationController = TextEditingController();

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
        _adminIdController.text = user.userId;
        _phoneController.text = user.phone;
       // _addressController.text = user.address;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await _profileService.updateUser(widget.userId, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        //'address': _addressController.text.trim(),
      });

      setState(() => _isEditing = false);
      CustomToast().showToast(context, 'Profile updated successfully', Colors.green);
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
      body: SingleChildScrollView(
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
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                      ? NetworkImage(_profileImageUrl!) as ImageProvider
                      : const AssetImage('assets/images/image_profile.png'),
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
                  labelText: 'Phone',
                  enabled:  _isEditing,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter your phone number' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller:_nidController,
                  labelText: 'Nid',
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
                  labelText: 'Birthdate',
                  enabled:  _isEditing,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter your birthdate' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller:_nomineeNameController,
                  labelText: 'NomineeName',
                  enabled:  false,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller:_nomineeRelationController,
                  labelText: 'NomineeRelation',
                  enabled:  false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
