import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ai_knowledge_service.dart';

class AIKnowledgeBaseScreen extends StatefulWidget {
  const AIKnowledgeBaseScreen({super.key});

  @override
  State<AIKnowledgeBaseScreen> createState() => _AIKnowledgeBaseScreenState();
}

class _AIKnowledgeBaseScreenState extends State<AIKnowledgeBaseScreen> {
  List<Map<String, dynamic>> _uploadedFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUploadedFiles();
  }

  Future<void> _loadUploadedFiles() async {
    final files = await AIKnowledgeService.getUploadedFiles();
    setState(() {
      _uploadedFiles = files;
      _isLoading = false;
    });
  }

  Future<bool> _requestStoragePermission() async {
    try {
      // For Android 13+ (API 33+), we need different permissions
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Try to request storage permission
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // For Android 13+, try media permissions
      final mediaStatus = await [
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ].request();

      return mediaStatus.values.any((status) => status.isGranted);
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> _pickAndUploadPDF() async {
    try {
      // Request storage permissions first
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to upload files. Please grant permission in app settings.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // Try different file picker approaches for better compatibility
      FilePickerResult? result;

      try {
        // First try with custom type
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false,
          allowCompression: false,
        );
      } catch (e) {
        // Fallback to any file type if custom fails
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
          allowCompression: false,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        // Check if file has a path
        if (file.path == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Unable to access the selected file. Please try a different file.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        // Check if it's a PDF file
        if (!file.name.toLowerCase().endsWith('.pdf')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a PDF file only.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        setState(() {
          _isLoading = true;
        });

        // Check file size (limit to 10MB)
        try {
          final fileSize = File(file.path!).lengthSync();
          if (fileSize > 10 * 1024 * 1024) {
            setState(() {
              _isLoading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'File too large. Please select a PDF under 10MB.',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
        } catch (e) {
          // If we can't check file size, proceed anyway
          print('Could not check file size: $e');
        }

        final success = await AIKnowledgeService.uploadPDF(
          filePath: file.path!,
          fileName: file.name,
        );

        if (success) {
          await _loadUploadedFiles();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${file.name} uploaded successfully! 📚\nYour AI assistant can now reference this document.',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to upload PDF. Please check the file and try again.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // User cancelled file selection
        print('File selection cancelled by user');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error in file picker: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error accessing files. Please check app permissions and try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteFile(String fileName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete PDF'),
        content: Text(
          'Are you sure you want to remove "$fileName" from the AI knowledge base?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await AIKnowledgeService.deleteFile(fileName);
      if (success) {
        await _loadUploadedFiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$fileName removed from knowledge base'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Knowledge Base',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF7043), Color(0xFFE64A19)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'AI Knowledge Base',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Upload PDF documents (research papers, guides, articles) to enhance your AI assistant\'s knowledge. The AI will reference these documents to provide more personalized responses.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickAndUploadPDF,
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: const Text(
                        'Upload PDF Document',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Uploaded Files Section
                  if (_uploadedFiles.isNotEmpty) ...[
                    const Text(
                      'Uploaded Documents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(_uploadedFiles.map((file) => _buildFileCard(file))),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
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
                      child: const Column(
                        children: [
                          Icon(Icons.folder_open, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No Documents Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Upload your first PDF document to start building your AI\'s knowledge base!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Information Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'How It Works',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Upload PDF documents (research papers, articles, guides)\n'
                          '• AI references these documents when relevant to your questions\n'
                          '• Enhanced responses based on your uploaded materials\n'
                          '• Documents are stored securely on your device\n'
                          '• You can remove documents anytime\n'
                          '• Best results with text-based PDFs (not scanned images)',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file) {
    final fileName = file['name'] as String;
    final uploadDate = file['uploadDate'] as String;
    final fileSize = file['size'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              color: Colors.red.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Uploaded: $uploadDate • $fileSize',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteFile(fileName);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remove'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
