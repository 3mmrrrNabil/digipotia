// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../core/di/service_locator.dart';
// import '../../../../core/network/retrofit/ain_api.dart';
// import '../cubit/report_details_cubit.dart';
// import '../cubit/comments_cubit.dart';
// import '../../domain/repositories/reports_repository.dart';
//
// class ReportDetailsPage extends StatefulWidget {
//   final String id;
//   const ReportDetailsPage({super.key, required this.id});
//
//   @override
//   State<ReportDetailsPage> createState() => _ReportDetailsPageState();
// }
//
// class _ReportDetailsPageState extends State<ReportDetailsPage> {
//   late final ReportDetailsCubit _detailsCubit;
//   late final CommentsCubit _commentsCubit;
//   late final ReportsRepository _repo;
//
//   @override
//   void initState() {
//     super.initState();
//     _detailsCubit = serviceLocator<ReportDetailsCubit>()..load(widget.id);
//     _commentsCubit = serviceLocator<CommentsCubit>()..init(widget.id);
//     _repo = serviceLocator<ReportsRepository>();
//   }
//
//   @override
//   void dispose() {
//     _detailsCubit.close();
//     _commentsCubit.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider.value(value: _detailsCubit),
//         BlocProvider.value(value: _commentsCubit),
//       ],
//       child: Scaffold(
//         appBar: AppBar(title: const Text('Report Details')),
//         body: BlocBuilder<ReportDetailsCubit, ReportDetailsState>(
//           builder: (context, state) {
//             if (state.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (state.data == null) {
//               return const Center(child: Text('Not found'));
//             }
//             final r = state.data!;
//             return ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 Text(r.title??"", style: Theme.of(context).textTheme.titleLarge),
//                 const SizedBox(height: 8),
//                 Text(r.description??""),
//                 const SizedBox(height: 12),
//                 Wrap(spacing: 8, children: [
//                   Chip(label: Text(r.category.toString())),
//                   Chip(label: Text(r.visibility.toString())),
//                   Chip(label: Text(r.status??"")),
//                 ]),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         try {
//                           await _repo.likeReport(r.id??"");
//                           _detailsCubit.load(widget.id);
//                         } catch (_) {}
//                       },
//                       icon: const Icon(Icons.thumb_up_alt_outlined),
//                       label: const Text('Like'),
//                     ),
//                     const SizedBox(width: 12),
//                     _StatusDropdown(
//                       current: r.status??"",
//                       onChanged: (val) async {
//                         if (val == null) return;
//                         try {
//                           await _repo.patchStatus(r.id??"", '"$val"');
//                           _detailsCubit.load(widget.id);
//                         } catch (_) {}
//                       },
//                     ),
//                     const Spacer(),
//                     PopupMenuButton<String>(
//                       onSelected: (v) async {
//                         if (v == 'edit') {
//                           // simple inline edit: reuse create form fields
//                           final title = TextEditingController(text: r.title);
//                           final desc = TextEditingController(text: r.description);
//                           final formKey = GlobalKey<FormState>();
//                           final result = await showDialog<bool>(
//                             context: context,
//                             builder: (ctx) => AlertDialog(
//                               title: const Text('Edit report'),
//                               content: Form(
//                                 key: formKey,
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     TextFormField(controller: title, validator: (v)=> v==null||v.isEmpty?'Required':null),
//                                     const SizedBox(height: 8),
//                                     TextFormField(controller: desc, maxLines: 3, validator: (v)=> v==null||v.isEmpty?'Required':null),
//                                   ],
//                                 ),
//                               ),
//                               actions: [
//                                 TextButton(onPressed: ()=> Navigator.pop(ctx, false), child: const Text('Cancel')),
//                                 ElevatedButton(onPressed: (){ if(formKey.currentState!.validate()) Navigator.pop(ctx, true); }, child: const Text('Save')),
//                               ],
//                             ),
//                           );
//                           if (result == true) {
//                             try {
//                               await _repo.updateReport(r.id??"", UpdateReportRequestDto(
//                                 title: title.text.trim(),
//                                 description: desc.text.trim(),
//                                 category: r.category??1,
//                                 visibility: r.visibility??1,
//                                 latitude: r.latitude??1,
//                                 longitude: r.longitude??1,
//                               ));
//                               _detailsCubit.load(widget.id);
//                             } catch (_) {}
//                           }
//                         } else if (v == 'delete') {
//                           try {
//                             await _repo.deleteReport(r.id??"");
//                             if (mounted) Navigator.of(context).pop();
//                           } catch (_) {}
//                         }
//                       },
//                       itemBuilder: (_) => const [
//                         PopupMenuItem(value: 'edit', child: Text('Edit report')),
//                         PopupMenuItem(value: 'delete', child: Text('Delete report')),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 const Text('Recent comments'),
//                 const SizedBox(height: 8),
//                 BlocBuilder<CommentsCubit, CommentsState>(
//                   builder: (context, cstate) {
//                     return Column(
//                       children: [
//                         for (final c in cstate.items)
//                           ListTile(
//                             title: Text(c.userDisplayName),
//                             subtitle: Text(c.content),
//                             trailing: PopupMenuButton<String>(
//                               onSelected: (v) async {
//                                 if (v == 'edit') {
//                                   final controller = TextEditingController(text: c.content);
//                                   final newText = await showDialog<String>(
//                                     context: context,
//                                     builder: (ctx) => AlertDialog(
//                                       title: const Text('Edit comment'),
//                                       content: TextField(controller: controller),
//                                       actions: [
//                                         TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
//                                         ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
//                                       ],
//                                     ),
//                                   );
//                                   if (newText != null && newText.isNotEmpty) {
//                                     await _commentsCubit.editComment(c.id, newText);
//                                   }
//                                 } else if (v == 'delete') {
//                                   await _commentsCubit.removeComment(c.id);
//                                 }
//                               },
//                               itemBuilder: (_) => const [
//                                 PopupMenuItem(value: 'edit', child: Text('Edit')),
//                                 PopupMenuItem(value: 'delete', child: Text('Delete')),
//                               ],
//                             ),
//                           ),
//                         if (cstate.hasMore)
//                           TextButton(
//                             onPressed: () => _commentsCubit.loadMore(),
//                             child: const Text('Load more'),
//                           ),
//                       ],
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 _AddCommentBar(onSubmit: (text) => _commentsCubit.addComment(text)),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class _AddCommentBar extends StatefulWidget {
//   final ValueChanged<String> onSubmit;
//   const _AddCommentBar({required this.onSubmit});
//   @override
//   State<_AddCommentBar> createState() => _AddCommentBarState();
// }
//
// class _AddCommentBarState extends State<_AddCommentBar> {
//   final controller = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: TextField(
//             controller: controller,
//             decoration: const InputDecoration(hintText: 'Write a comment...'),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.send),
//           onPressed: () {
//             final text = controller.text.trim();
//             if (text.isNotEmpty) {
//               widget.onSubmit(text);
//               controller.clear();
//             }
//           },
//         ),
//       ],
//     );
//   }
// }
//
// class _StatusDropdown extends StatelessWidget {
//   final String current;
//   final ValueChanged<String?> onChanged;
//   const _StatusDropdown({required this.current, required this.onChanged});
//
//   @override
//   Widget build(BuildContext context) {
//     const statuses = ['Pending', 'InReview', 'Dispatched', 'Resolved', 'Rejected'];
//     return DropdownButton<String>(
//       value: current,
//       items: statuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//       onChanged: onChanged,
//     );
//   }
// }
//
