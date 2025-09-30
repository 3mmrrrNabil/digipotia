import 'package:digipotia/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../cubit/comments_cubit.dart';
import 'comments_item.dart';

class CommentsSection extends StatefulWidget {
  final String reportId;
  const CommentsSection({super.key, required this.reportId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  late final CommentsCubit _cubit;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = serviceLocator<CommentsCubit>();
    _cubit.init(widget.reportId);

    // ✅ اللغة العربية لـ timeago
    timeago.setLocaleMessages('ar', timeago.ArMessages());
  }

  @override
  void dispose() {
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "";
    try {
      final date = DateTime.parse(createdAt).toLocal();
      return timeago.format(date, locale: 'ar');
    } catch (_) {
      return createdAt;
    }
  }

  void _sendComment() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _cubit.addComment(text);
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _editComment(String commentId, String oldText) {
    final editController = TextEditingController(text: oldText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تعديل التعليق"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: "أدخل النص الجديد...",
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("حفظ"),
            onPressed: () {
              final newText = editController.text.trim();
              if (newText.isNotEmpty && newText != oldText) {
                _cubit.editComment(commentId, newText); // ✅ تعديل
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _deleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حذف التعليق"),
        content: const Text("هل أنت متأكد من حذف هذا التعليق؟"),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("حذف"),
            onPressed: () {
              _cubit.removeComment(commentId); // ✅ مسح
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Column(
        children: [
          // ✅ عرض التعليقات
          Expanded(
            child: BlocBuilder<CommentsCubit, CommentsState>(
              builder: (context, state) {
                if (state.isLoading && state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.error != null) {
                  return const Center(child: Text("❌ فشل تحميل التعليقات"));
                }

                if (state.items.isEmpty) {
                  return const Center(child: Text("لا توجد تعليقات بعد"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final c = state.items[index];
                    return ListTile(
                      title: CommentItem(
                        userName: c.userDisplayName ?? "مستخدم",
                        content: c.content ?? "",
                        createdAt: _formatTime(c.createdAt),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editComment(c.id ?? "", c.content ?? "");
                          } else if (value == 'delete') {
                            _deleteComment(c.id ?? "");
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text("✏️ تعديل"),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text("🗑 حذف"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ✅ حقل الكتابة
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "أكتب تعليقك...",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
