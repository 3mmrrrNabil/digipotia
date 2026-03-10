import 'dart:async';
import 'dart:ui';
import 'package:digipotia/core/constants/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/media_query_extensions.dart';
import '../../../../core/network/retrofit/ain_api.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/network/remote/api_constants.dart';
import '../../../../core/storage_helper/app_shared_preference_helper.dart';
import '../../domain/repositories/reports_repository.dart';
import '../cubit/feed_cubit.dart';
import 'comments/comments_section.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final FeedCubit _cubit;
  late final ReportsRepository _repo;
  Map<String, bool> favorites = {};
  Map<String, bool> _expandedPosts = {};
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final List<Map<String, dynamic>> categories = [
    {"name": "الكل", "icon": "assets/svg/الكل.svg", "color": const Color(0xFF5E5E5E)},
    {"name": "امني", "icon": "assets/svg/امني.svg", "color": const Color(0xFFFF3131)},
    {"name": "سلامة", "icon": "assets/svg/سلامه.svg", "color": const Color(0xFF2563EB)},
    {"name": "بيئي", "icon": "assets/svg/بيئي.svg", "color": const Color(0xFF0DA036)},
    {"name": "مروري", "icon": "assets/svg/مروري.svg", "color": const Color(0xFFE6DF03)},
  ];

  String selectedCategory = "الكل";
  late final currentUserId;
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLogin();
    _cubit = serviceLocator<FeedCubit>();
    _cubit.loadFirstPage();
    _repo = serviceLocator<ReportsRepository>();
    _loadCurrentUser();



  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
  Future<void> _checkLogin() async {
    final token = await SharedPreferencesHelper.getString(AppValues.token);

    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login'); // أو المسار الفعلي لشاشة تسجيل الدخول
      }
    }
  }
  Future<void> _loadCurrentUser() async {
    currentUserId = await SharedPreferencesHelper.getData(key: AppValues.userId);
    setState(() {}); // لإعادة بناء الشاشة بعد تحميل الـ userId
  }
  String buildMediaUrl2(String? path) {
    if (path == null || path.isEmpty) return "";
    return "${ApiConstants.baseUrl2}$path";
  }

  Uri _buildThumbnailUri(Uri videoUri) {
    final segments = List<String>.from(videoUri.pathSegments);
    if (segments.isNotEmpty) {
      final last = segments.removeLast();
      final newLast = last.replaceAll(RegExp(r'\.(mp4|mov|avi|qt)$', caseSensitive: false), '.jpg');
      segments.add(newLast);
    }
    return videoUri.replace(pathSegments: segments);
  }

  Future<bool> _thumbnailExists(Uri thumbUri) async {
    try {
      final res = await http.head(thumbUri).timeout(const Duration(seconds: 6));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Widget buildMediaWidget(BuildContext context, String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        height: 140,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      );
    }

    final url = buildMediaUrl2(path);
    final uri = Uri.parse(url.trim());
    final isVideo = RegExp(r'\.(mp4|mov|avi|qt)$', caseSensitive: false).hasMatch(uri.path);

    if (isVideo) {
      final thumbUri = _buildThumbnailUri(uri);
      return FutureBuilder<bool>(
        future: _thumbnailExists(thumbUri),
        builder: (context, snapshot) {
          final exists = snapshot.data == true;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 140,
              width: double.infinity,
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 1,
                  child: exists
                      ? Image.network(thumbUri.toString(), width: double.infinity, fit: BoxFit.cover)
                      : Image.asset('assets/images/3en(2).png', width: double.infinity, fit: BoxFit.cover),
                ),
              ),
              const Icon(Icons.play_circle_outline, size: 60, color: Colors.white70),
            ],
          );
        },
      );
    }

    return Image.network(
      url,
      height: 140,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 140,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, size: 40),
      ),
    );
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _cubit.searchByDisplayName(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80, // علشان نسيب مساحة تحت
        title: Padding(
          padding: const EdgeInsets.only(top: 15), // تبعده عن الشايي بار
          child:TextField(
            controller: _searchController,
            onChanged: _onSearchChanged, // دي أهم حاجة
            decoration: InputDecoration(
              hintText: "ابحث هنا...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: SizedBox(
                height: context.hp(5),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat["name"] == selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat["name"]),
                      child: Container(
                        width: context.wp(18.5),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: Colors.grey.shade400, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 0.5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${cat["name"]}",
                                style: GoogleFonts.cairo(
                                    color: isSelected ? Colors.white : const Color(0xFF5E5E5E),
                                    fontWeight: FontWeight.normal)),
                            SizedBox(width: context.wp(1)),
                            SvgPicture.asset(
                              cat["icon"],
                              width: context.wp(2.5),
                              height: context.hp(2.5),
                              colorFilter: ColorFilter.mode(
                                isSelected ? Colors.white : cat["color"],
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<FeedCubit, FeedState>(
                bloc: _cubit,
                builder: (context, state) {
                  if (state.isLoading)
                  {
                    return Center(child: CircularProgressIndicator());
                }
                  if (!state.isSuccess && state.error != null) return Center(child: Text("حدث خطأ: ${state.error}"));

                  List<ReportDto> filteredReports;
                  switch (selectedCategory) {
                    case "امني":
                      filteredReports = state.securityItems;
                      break;
                    case "سلامة":
                      filteredReports = state.safetyItems;
                      break;
                    case "مروري":
                      filteredReports = state.trafficItems;
                      break;
                    case "بيئي":
                      filteredReports = state.environmentItems;
                      break;
                    default:
                      filteredReports = state.allItems;
                  }

                  if (_cubit.searchResults.isNotEmpty) {
                    filteredReports = filteredReports
                        .where((item) => _cubit.searchResults.contains(item.id))
                        .toList();
                  }

                  if (filteredReports.isEmpty) return const Center(child: Text("لا توجد بلاغات"));

                  return RefreshIndicator(
                    onRefresh: () async => _cubit.loadFirstPage(),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredReports.length,
                            itemBuilder: (context, index) {

                              final report = filteredReports[index];
                              final interactions = state.postsMap[report.id];
                              final current = state.postsMap[report.id];
                              final isLiked = current?.isLikedByCurrentUser ?? false;
                              final mediaUrl = (report.attachments != null && report.attachments!.isNotEmpty)
                                  ? buildMediaUrl2(report.attachments!.first.url)
                                  : "";
                              final isExpanded = _expandedPosts[report.id] ?? false;

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 13),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Color(0xFF2563EB),
                                            child: Icon(Icons.person, color: Colors.white, size: 20),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("${interactions?.reporterDisplayName ?? ""}",
                                                    style: GoogleFonts.cairo(
                                                        fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black)),
                                                const SizedBox(height: 2),
                                                Tooltip(
                                                  message: report.createdAt ?? "",
                                                  child: Text(
                                                    timeAgo(report.createdAt ?? ""),
                                                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        currentUserId==interactions!.reporterId ?
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_horiz, color: Colors.grey),
                                          onSelected: (value) async {
                                            if (value == "edit") {
                                              final updatedData = await showDialog<UpdateReportRequestDto>(
                                                context: context,
                                                builder: (context) {
                                                  final titleController =
                                                  TextEditingController(text: report.title);
                                                  final descController =
                                                  TextEditingController(text: report.description);
                                                  return AlertDialog(
                                                    title: const Text("تعديل البلاغ"),
                                                    content: SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          TextField(
                                                              controller: titleController,
                                                              decoration:
                                                              const InputDecoration(labelText: "العنوان")),
                                                          TextField(
                                                              controller: descController,
                                                              decoration:
                                                              const InputDecoration(labelText: "الوصف")),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text("إلغاء")),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          final dto = UpdateReportRequestDto(
                                                            title: titleController.text,
                                                            description: descController.text,
                                                            category: report.category,
                                                            visibility: report.visibility,
                                                            latitude: report.latitude,
                                                            longitude: report.longitude,
                                                          );
                                                          Navigator.pop(context, dto);
                                                        },
                                                        child: const Text("حفظ"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              if (updatedData != null &&
                                                  (updatedData.title != report.title ||
                                                      updatedData.description != report.description)) {
                                                setState(() {
                                                  report.title = updatedData.title;
                                                  report.description = updatedData.description;
                                                });
                                                await _repo.updateReport(report.id ?? "", updatedData);
                                              }
                                            } else if (value == "delete") {
                                              await _repo.deleteReport(report.id ?? "");
                                              setState(() {
                                                filteredReports.remove(report);
                                              });
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(value: "edit", child: Text("تعديل")),
                                            const PopupMenuItem(value: "delete", child: Text("حذف")),
                                          ],
                                        )
                                            :SizedBox()
                                        ],
                                      ),
                                    ),
                                    // Media
                                    if (mediaUrl.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          if (mediaUrl.contains("mp4") ||
                                              mediaUrl.contains("mov") ||
                                              mediaUrl.contains("avi") ||
                                              mediaUrl.contains("qt")) {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(builder: (_) => FullScreenVideoPage(url: mediaUrl)));
                                          } else {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(builder: (_) => FullScreenImagePage(url: mediaUrl)));
                                          }
                                        },
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(0),
                                          ),
                                          child: buildMediaWidget(context, report.attachments!.first.url),
                                        ),
                                      ),
                                    // Text & like/comment row
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(report.title ?? "بدون عنوان",
                                              style: GoogleFonts.cairo(
                                                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
                                          const SizedBox(height: 6),
                                          Text(report.description ?? "",
                                              style: GoogleFonts.cairo(fontSize: 13, color: Colors.black87),
                                              maxLines: isExpanded ? null : 2,
                                              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis),
                                          if ((report.description?.length ?? 0) > 100)
                                            GestureDetector(
                                              onTap: () => setState(() {
                                                _expandedPosts[report.id] = !isExpanded;
                                              }),
                                              child: Text(isExpanded ? "عرض أقل" : "عرض المزيد",
                                                  style: const TextStyle(
                                                      color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(interactions?.likeCount.toString() ?? "0"),
                                                    IconButton(
                                                      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                                                          color: Colors.red),
                                                      onPressed: () async {
                                                        setState(() {
                                                          favorites[report.id] = !isLiked;
                                                          if (current != null) {
                                                            current.likeCount += (favorites[report.id]! ? 1 : -1);
                                                            current.isLikedByCurrentUser = favorites[report.id]!;
                                                            final cubit = context.read<FeedCubit>();
                                                            final updatedMap = Map<String, ReportInteractionsDto>.from(cubit.state.postsMap);
                                                            updatedMap[report.id ?? ""] = current;
                                                            cubit.emit(cubit.state.copyWith(postsMap: updatedMap));
                                                          }
                                                        });
                                                        await _repo.likeReport(report.id ?? "");
                                                      },
                                                    ),
                                                    SizedBox(width: context.wp(2)),
                                                    Row(
                                                      children: [
                                                        Text("${interactions?.commentCount ?? 0}"),
                                                        IconButton(
                                                          icon: const Icon(Icons.chat_outlined, color: Colors.grey),
                                                          onPressed: () async {
                                                            final newCommentCount = await showModalBottomSheet<int>(
                                                              context: context,
                                                              isScrollControlled: true,
                                                              shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                                              ),
                                                              builder: (_) => SizedBox(
                                                                height: MediaQuery.of(context).size.height * 0.8,
                                                                child: CommentsSection(reportId: report.id ?? ""),
                                                              ),
                                                            );

                                                            // ✅ إذا تم إضافة كومنت جديد نحدث العد محلياً
                                                            if (newCommentCount != null) {
                                                              _cubit.updateLocalCommentCount(report.id ?? "", newCommentCount);
                                                            }

                                                            // ✅ بعد إغلاق صفحة الكومنت، نعمل Reload كامل
                                                            await _cubit.loadFirstPage();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.share, color: Colors.grey),
                                                  onPressed: () {
                                                    final textToShare = """
${report.title ?? "بدون عنوان"}
${report.description ?? ""}
""";
                                                    Share.share(textToShare);
                                                  },
                                                ),                                              ],
                                            ),
                                          ),
                                          SizedBox(height: context.hp(1)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String timeAgo(String dateTimeString) {
  final dateTime = DateTime.parse(dateTimeString).toLocal();
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return difference.inSeconds <= 1
        ? "منذ ثانية"
        : difference.inSeconds == 2
        ? "منذ ثانيتين"
        : "منذ ${difference.inSeconds} ثوانٍ";
  } else if (difference.inMinutes < 60) {
    return difference.inMinutes == 1
        ? "منذ دقيقة"
        : difference.inMinutes == 2
        ? "منذ دقيقتين"
        : "منذ ${difference.inMinutes} دقائق";
  } else if (difference.inHours < 24) {
    return difference.inHours == 1
        ? "منذ ساعة"
        : difference.inHours == 2
        ? "منذ ساعتين"
        : "منذ ${difference.inHours} ساعات";
  } else if (difference.inDays < 7) {
    return difference.inDays == 1
        ? "منذ يوم"
        : difference.inDays == 2
        ? "منذ يومين"
        : "منذ ${difference.inDays} أيام";
  } else {
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }
}

class FullScreenVideoPage extends StatelessWidget {
  final String url;
  const FullScreenVideoPage({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      Navigator.of(context).pop();
    });

    return Scaffold(backgroundColor: Colors.black, body: const Center(child: CircularProgressIndicator()));
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String url;
  const FullScreenImagePage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: InteractiveViewer(child: Image.network(url, fit: BoxFit.contain))),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTextField extends StatefulWidget {
  final FeedCubit cubit;
  const _SearchTextField({required this.cubit});

  @override
  State<_SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<_SearchTextField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.cubit.searchByDisplayName(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'ابحث بالاسم',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: _onChanged,
    );
  }
}
