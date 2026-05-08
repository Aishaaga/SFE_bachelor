import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _profileService = ProfileService();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _profileService.getProfile();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _user = result['user'];
          _nameController.text = _user?.name ?? '';
          _bioController.text = _user?.bio ?? '';
          _locationController.text = _user?.location ?? '';
        }
      });

      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors du chargement du profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _profileService.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      location: _locationController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _user = result['user'];
          _isEditing = false;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Profil mis à jour'),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (_user != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateProfile,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nameController.text = _user?.name ?? '';
                  _bioController.text = _user?.bio ?? '';
                  _locationController.text = _user?.location ?? '';
                });
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Erreur lors du chargement du profil'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.green.shade100,
                                backgroundImage: _user!.profileImage.isNotEmpty
                                    ? NetworkImage(_user!.profileImage)
                                    : null,
                                child: _user!.profileImage.isEmpty
                                    ? Text(
                                        _user!.name.isNotEmpty 
                                            ? _user!.name[0].toUpperCase()
                                            : _user!.email[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              if (!_isEditing)
                                Text(
                                  _user!.name.isNotEmpty ? _user!.name : _user!.email,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (!_isEditing)
                                Text(
                                  _user!.email,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (_user!.role == 'admin')
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Profile Information
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Informations personnelles',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                if (_isEditing)
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nom',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                    validator: (value) {
                                      if (value != null && value.trim().length > 50) {
                                        return 'Le nom ne peut pas dépasser 50 caractères';
                                      }
                                      return null;
                                    },
                                  )
                                else if (_user!.name.isNotEmpty)
                                  _buildInfoRow('Nom', _user!.name, Icons.person),
                                
                                const SizedBox(height: 12),
                                
                                if (_isEditing)
                                  TextFormField(
                                    controller: _locationController,
                                    decoration: const InputDecoration(
                                      labelText: 'Localisation',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.location_on),
                                    ),
                                    validator: (value) {
                                      if (value != null && value.trim().length > 100) {
                                        return 'La localisation ne peut pas dépasser 100 caractères';
                                      }
                                      return null;
                                    },
                                  )
                                else if (_user!.location.isNotEmpty)
                                  _buildInfoRow('Localisation', _user!.location, Icons.location_on),
                                
                                const SizedBox(height: 12),
                                
                                if (_isEditing)
                                  TextFormField(
                                    controller: _bioController,
                                    decoration: const InputDecoration(
                                      labelText: 'Bio',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.info),
                                    ),
                                    maxLines: 3,
                                    validator: (value) {
                                      if (value != null && value.trim().length > 500) {
                                        return 'La bio ne peut pas dépasser 500 caractères';
                                      }
                                      return null;
                                    },
                                  )
                                else if (_user!.bio.isNotEmpty)
                                  _buildInfoRow('Bio', _user!.bio, Icons.info),
                                
                                if (!_isEditing && _user!.name.isEmpty && 
                                    _user!.location.isEmpty && _user!.bio.isEmpty)
                                  const Text(
                                    'Aucune information personnelle ajoutée',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // Statistics
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Statistiques',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildStatRow('Contributions', _user!.contributionsCount, Icons.post_add),
                                const SizedBox(height: 12),
                                _buildStatRow('Identifications', _user!.identificationsCount, Icons.search),
                                const SizedBox(height: 12),
                                _buildStatRow('Suggestions de traduction', _user!.translationSuggestionsCount, Icons.translate),
                                const SizedBox(height: 12),
                                _buildStatRow('Membre depuis', DateFormat('dd MMMM yyyy').format(_user!.createdAt), Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, dynamic value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green.shade600),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value is int ? value.toString() : value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
