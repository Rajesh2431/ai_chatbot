import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/user_profile_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _locationController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  
  String _selectedGender = '';
  String _selectedRelationshipStatus = '';
  String? _userAvatarPath;
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Other',
  ];

  final List<String> _relationshipOptions = [
    'Single',
    'In relationship',
    'Married',
    'Divorced',
    'Widowed',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _hobbiesController.dispose();
    _locationController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final profile = await UserProfileService.getUserProfile();
      
      if (mounted) {
        setState(() {
          _nameController.text = profile['name'] ?? '';
          _ageController.text = profile['age'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _phoneController.text = profile['phone'] ?? '';
          _hobbiesController.text = profile['hobbies'] ?? '';
          _locationController.text = profile['location'] ?? '';
          _emergencyContactController.text = profile['emergencyContact'] ?? '';
          _selectedGender = profile['gender'] ?? '';
          _selectedRelationshipStatus = profile['relationshipStatus'] ?? '';
          _userAvatarPath = profile['avatarPath'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error loading profile: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await UserProfileService.saveUserProfile(
        name: _nameController.text.trim(),
        age: _ageController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _selectedGender,
        hobbies: _hobbiesController.text.trim(),
        location: _locationController.text.trim(),
        relationshipStatus: _selectedRelationshipStatus,
        emergencyContact: _emergencyContactController.text.trim(),
        avatarPath: _userAvatarPath,
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });
        _showSuccessSnackBar('Profile updated successfully!');
        Navigator.pop(context, true); // Return true to indicate profile was updated
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error saving profile: $e');
      }
    }
  }

  Future<void> _pickAvatar() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Get app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final avatarsDir = Directory('${appDir.path}/avatars');
        
        // Create avatars directory if it doesn't exist
        if (!await avatarsDir.exists()) {
          await avatarsDir.create(recursive: true);
        }
        
        // Generate unique filename
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.${result.files.single.extension}';
        final newPath = '${avatarsDir.path}/$fileName';
        
        // Copy file to app directory
        await file.copy(newPath);
        
        setState(() {
          _userAvatarPath = newPath;
          _isEditing = true;
        });
        
        _showSuccessSnackBar('Avatar updated! Don\'t forget to save your changes.');
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting avatar: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                    // Avatar Section
                    _buildAvatarSection(),
                    const SizedBox(height: 30),
                    
                    // Personal Information Card
                    _buildInfoCard(
                      title: 'Personal Information',
                      icon: Icons.person,
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 400) {
                              // Stack vertically on smaller screens
                              return Column(
                                children: [
                                  _buildTextField(
                                    controller: _ageController,
                                    label: 'Age',
                                    icon: Icons.cake_outlined,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        final age = int.tryParse(value);
                                        if (age == null || age < 1 || age > 120) {
                                          return 'Enter valid age';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDropdownField(
                                    value: _selectedGender.isEmpty ? null : _selectedGender,
                                    label: 'Gender',
                                    icon: Icons.wc_outlined,
                                    items: _genderOptions,
                                    onChanged: _isEditing ? (value) {
                                      setState(() => _selectedGender = value ?? '');
                                    } : null,
                                  ),
                                ],
                              );
                            } else {
                              // Side by side on larger screens
                              return Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: _buildTextField(
                                      controller: _ageController,
                                      label: 'Age',
                                      icon: Icons.cake_outlined,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          final age = int.tryParse(value);
                                          if (age == null || age < 1 || age > 120) {
                                            return 'Enter valid age';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: _buildDropdownField(
                                      value: _selectedGender.isEmpty ? null : _selectedGender,
                                      label: 'Gender',
                                      icon: Icons.wc_outlined,
                                      items: _genderOptions,
                                      onChanged: _isEditing ? (value) {
                                        setState(() => _selectedGender = value ?? '');
                                      } : null,
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Contact Information Card
                    _buildInfoCard(
                      title: 'Contact Information',
                      icon: Icons.contact_phone,
                      children: [
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              // Basic email format validation
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              
                              // Check for common email domains
                              final commonDomains = [
                                '@gmail.com',
                                '@outlook.com',
                                '@hotmail.com',
                                '@yahoo.com',
                                '@icloud.com',
                                '@protonmail.com',
                                '@aol.com',
                                '@live.com',
                                '@msn.com',
                                '@yandex.com',
                                '@mail.com',
                                '@zoho.com',
                              ];
                              
                              final email = value.toLowerCase();
                              bool hasValidDomain = commonDomains.any((domain) => email.endsWith(domain));
                              
                              if (!hasValidDomain) {
                                return 'Please use a common email provider\n(Gmail, Outlook, Yahoo, etc.)';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Additional Information Card
                    _buildInfoCard(
                      title: 'Additional Information',
                      icon: Icons.info_outline,
                      children: [
                        _buildTextField(
                          controller: _locationController,
                          label: 'Location',
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          value: _selectedRelationshipStatus.isEmpty ? null : _selectedRelationshipStatus,
                          label: 'Relationship Status',
                          icon: Icons.people_outline,
                          items: _relationshipOptions,
                          onChanged: _isEditing ? (value) {
                            setState(() => _selectedRelationshipStatus = value ?? '');
                          } : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _hobbiesController,
                          label: 'Hobbies & Interests',
                          icon: Icons.interests_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emergencyContactController,
                          label: 'Emergency Contact',
                          icon: Icons.emergency_outlined,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // Save Button
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                  border: Border.all(
                    color: const Color(0xFF4A90E2),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _userAvatarPath != null
                      ? (_userAvatarPath!.startsWith('lib/assets/'))
                          ? Image.asset(
                              _userAvatarPath!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                            )
                          : Image.file(
                              File(_userAvatarPath!),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                            )
                      : _buildDefaultAvatar(),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text.isNotEmpty ? _nameController.text : 'Your Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          if (_isEditing)
            TextButton.icon(
              onPressed: _pickAvatar,
              icon: const Icon(Icons.photo_camera, size: 18),
              label: const Text('Change Avatar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A90E2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Color(0xFF4A90E2),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF4A90E2), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: _isEditing,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4A90E2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4A90E2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}