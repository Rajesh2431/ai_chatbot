import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'avatar_selection_screen.dart';
import '../services/user_profile_service.dart';
import '../services/avatar_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _locationController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  
  String _selectedGender = 'Prefer not to say';
  String _selectedRelationshipStatus = 'Prefer not to say';
  bool _isLoading = true;
  bool _isEditing = false;
  
  // Avatar information
  String _avatarName = 'Saira';
  String _avatarImage = 'lib/assets/avatar/saira.png';

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say'
  ];

  final List<String> _relationshipOptions = [
    'Single',
    'In a relationship',
    'Married',
    'Divorced',
    'Widowed',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadAvatar();
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
    try {
      final profile = await UserProfileService.getUserProfile();
      
      setState(() {
        _nameController.text = profile['name'] ?? '';
        _ageController.text = profile['age'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _hobbiesController.text = profile['hobbies'] ?? '';
        _locationController.text = profile['location'] ?? '';
        _emergencyContactController.text = profile['emergencyContact'] ?? '';
        _selectedGender = profile['gender'] ?? 'Prefer not to say';
        _selectedRelationshipStatus = profile['relationshipStatus'] ?? 'Prefer not to say';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvatar() async {
    try {
      final avatarData = await AvatarService.getSelectedAvatar();
      if (avatarData != null) {
        setState(() {
          _avatarName = avatarData['name'] ?? 'Saira';
          _avatarImage = avatarData['image'] ?? 'lib/assets/avatar/saira.png';
        });
      }
    } catch (e) {
      // Keep default values if loading fails
    }
  }

  Future<void> _saveUserProfile() async {
    if (!_formKey.currentState!.validate()) return;

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
      );

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Blue Header Section
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Header with back button and title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Spacer(),
                              const Text(
                                'My Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  _isEditing ? Icons.save : Icons.edit,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () {
                                  if (_isEditing) {
                                    _saveUserProfile();
                                  } else {
                                    setState(() => _isEditing = true);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        // Profile Info Card
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              // Profile Avatar
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    _avatarImage,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      'assets/icons/profile.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Color(0xFF4A90E2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Name and basic info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _nameController.text.isEmpty ? 'Your Name' : _nameController.text,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _ageController.text.isEmpty 
                                          ? 'Age not specified' 
                                          : 'Age: ${_ageController.text}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Profile Details List
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildProfileDetailCard(),
                          const SizedBox(height: 20),
                          // Change Avatar Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AvatarSelectionScreen(),
                                  ),
                                );
                                // Reload avatar if user made a selection
                                if (result == true) {
                                  _loadAvatar();
                                }
                              },
                              icon: const Icon(Icons.face, size: 20),
                              label: const Text(
                                'Change Avatar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileDetailCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Full Name', _nameController.text.isEmpty ? 'Not specified' : _nameController.text, Icons.person_outline, 
            isEditable: true, controller: _nameController),
          _buildDivider(),
          
          _buildDetailRow('Age', _ageController.text.isEmpty ? 'Not specified' : _ageController.text, Icons.cake_outlined,
            isEditable: true, controller: _ageController, keyboardType: TextInputType.number),
          _buildDivider(),
          
          _buildDetailRow('Gender', _selectedGender.isEmpty ? 'Not specified' : _selectedGender, Icons.wc_outlined,
            isDropdown: true, dropdownValue: _selectedGender, dropdownItems: _genderOptions,
            onDropdownChanged: (value) => setState(() => _selectedGender = value!)),
          _buildDivider(),
          
          _buildDetailRow('Email', _emailController.text.isEmpty ? 'Not specified' : _emailController.text, Icons.email_outlined,
            isEditable: true, controller: _emailController, keyboardType: TextInputType.emailAddress),
          _buildDivider(),
          
          _buildDetailRow('Phone Number', _phoneController.text.isEmpty ? 'Not specified' : _phoneController.text, Icons.phone_outlined,
            isEditable: true, controller: _phoneController, keyboardType: TextInputType.phone),
          _buildDivider(),
          
          _buildDetailRow('Hobbies', _hobbiesController.text.isEmpty ? 'Not specified' : _hobbiesController.text, Icons.favorite_outline,
            isEditable: true, controller: _hobbiesController, maxLines: 2),
          _buildDivider(),
          
          _buildDetailRow('Location', _locationController.text.isEmpty ? 'Not specified' : _locationController.text, Icons.location_on_outlined,
            isEditable: true, controller: _locationController),
          _buildDivider(),
          
          _buildDetailRow('Relationship Status', _selectedRelationshipStatus.isEmpty ? 'Not specified' : _selectedRelationshipStatus, Icons.people_outline,
            isDropdown: true, dropdownValue: _selectedRelationshipStatus, dropdownItems: _relationshipOptions,
            onDropdownChanged: (value) => setState(() => _selectedRelationshipStatus = value!)),
          _buildDivider(),
          
          _buildDetailRow('Emergency Contact', _emergencyContactController.text.isEmpty ? 'Not specified' : _emergencyContactController.text, Icons.emergency_outlined,
            isEditable: true, controller: _emergencyContactController, isLast: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label, 
    String value, 
    IconData icon, {
    bool isEditable = false,
    bool isDropdown = false,
    bool isLast = false,
    TextEditingController? controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? dropdownValue,
    List<String>? dropdownItems,
    void Function(String?)? onDropdownChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                
                if (_isEditing && isEditable && controller != null)
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                  )
                else if (_isEditing && isDropdown && dropdownItems != null)
                  DropdownButtonFormField<String>(
                    value: dropdownValue?.isEmpty == true ? null : dropdownValue,
                    onChanged: onDropdownChanged,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: dropdownItems.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                  )
                else
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          
          // Lock icon for non-editable fields
          if (!_isEditing)
            Icon(
              Icons.lock_outline,
              color: Colors.grey[400],
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 72,
    );
  }
}