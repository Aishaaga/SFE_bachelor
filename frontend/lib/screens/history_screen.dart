import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<dynamic> _identifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    final result = await _apiService.getHistory();

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _identifications = result['identifications'];
        print('DEBUG: Loaded ${_identifications.length} identifications');
        for (var ident in _identifications) {
          print(
              'DEBUG: Plant: ${ident['plant']['name']}, photoUrl: ${ident['photoUrl']}');
        }
      } else {
        _error = result['message'];
      }
    });
  }

  Future<void> _deleteIdentification(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer cette identification ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await _apiService.deleteIdentification(id);

    if (result['success']) {
      await _loadHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Identification supprimée'),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
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
        title: const Text('Mon historique'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHistory,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _identifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Aucune identification',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          Text('Prenez une photo pour commencer'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _identifications.length,
                      itemBuilder: (context, index) {
                        final ident = _identifications[index];
                        final plant = ident['plant'];
                        final date = DateTime.parse(ident['date']);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: ident['photoUrl'] != null &&
                                        ident['photoUrl'].isNotEmpty
                                    ? Builder(
                                        builder: (context) {
                                          final imageUrl =
                                              '${Constants.apiUrl.substring(0, Constants.apiUrl.indexOf('/api'))}${ident['photoUrl']}';
                                          print(
                                              'DEBUG: Loading image: $imageUrl');
                                          print(
                                              'DEBUG: photoUrl from API: ${ident['photoUrl']}');
                                          return Image.network(
                                            imageUrl,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  'DEBUG: Image failed to load: $error');
                                              return const Icon(Icons.eco,
                                                  color: Colors.green);
                                            },
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.green),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      )
                                    : const Icon(Icons.eco,
                                        color: Colors.green),
                              ),
                            ),
                            title: Text(
                              plant['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (plant['scientificName'] != null &&
                                    plant['scientificName'].isNotEmpty)
                                  Text(
                                    plant['scientificName'],
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                                Text(
                                  '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteIdentification(ident['id']),
                            ),
                            isThreeLine: true,
                            onTap: () {
                              // Optionnel : voir le détail
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
