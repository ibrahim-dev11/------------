import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax/iconsax.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import '../services/app_localizations.dart';
import '../models/post.dart';

class CreatePostScreen extends StatefulWidget {
  final int institutionId;
  final Post? post;

  const CreatePostScreen({super.key, required this.institutionId, this.post});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _imageFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final Map<String, dynamic> res;
      if (widget.post != null) {
        res = await ApiService.updatePost(
          postId: widget.post!.id,
          title: _titleController.text,
          content: _contentController.text,
        );
      } else {
        res = await ApiService.createPost(
          institutionId: widget.institutionId,
          title: _titleController.text,
          content: _contentController.text,
          imageFile: _imageFile,
        );
      }

      if (res['success'] == true) {
        if (mounted) {
          AppSnackbar.success(
            context,
            widget.post != null
                ? S.of(context, 'postUpdatedSuccess')
                : S.of(context, 'postCreatedSuccess'),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          AppSnackbar.error(context, res['message'] ?? S.of(context, 'error'));
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.post != null
              ? S.of(context, 'editPost')
              : S.of(context, 'createPost'),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Card
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.image, size: 40, color: AppTheme.primary),
                            const SizedBox(height: 12),
                            Text(
                              S.of(context, 'addPostImage'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
              if (widget.post != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'تێبینی: وێنەی پۆست لە کاتی ئیدیت کردن ناگۆڕدرێت',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 24),

              // Title Field
              Text(
                S.of(context, 'postTitle'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: S.of(context, 'postTitleHint'),
                  prefixIcon: const Icon(Iconsax.text),
                ),
              ),
              const SizedBox(height: 20),

              // Content Field
              Text(
                S.of(context, 'postContent'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 6,
                validator: (v) => (v == null || v.isEmpty) ? S.of(context, 'required') : null,
                decoration: InputDecoration(
                  hintText: S.of(context, 'postContentHint'),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.post != null
                              ? S.of(context, 'saveChanges')
                              : S.of(context, 'publishPost'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
