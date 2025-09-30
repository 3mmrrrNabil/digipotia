import 'dart:io';
import 'package:digipotia/core/extensions/media_query_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/retrofit/ain_api.dart';
import '../../../../core/routes/routes.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../../../core/constants/app_values.dart';
import '../../../../core/storage_helper/app_shared_preference_helper.dart';
import '../widgets/problem_caategory_item.dart';
import '../widgets/profie_state_item.dart';

class CreateReportWizard extends StatefulWidget {
  const CreateReportWizard({super.key});

  @override
  State<CreateReportWizard> createState() => _CreateReportWizardState();
}

class _CreateReportWizardState extends State<CreateReportWizard> {
  int _currentStep = 0;

  int? _category;
  File? _file;
  bool _isVideo = false;
  int _visibility = 1;
  double? _latitude;
  double? _longitude;
  bool _isTitleEmpty =false;
  bool _isDescEmpty =false;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late final ReportsRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = serviceLocator<ReportsRepository>();
  }

  Future<void> _pickFile(bool isVideo) async {
    final picker = ImagePicker();

    // نطلب صلاحية الكاميرا أولاً
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      // لو رفض المستخدم الصلاحية
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى السماح بالوصول إلى الكاميرا')),
      );
      return;
    }

    // بعد السماح نعرض اختيار المصدر
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر المصدر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('المعرض'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('الكاميرا'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        _file = File(picked.path);
        _isVideo = isVideo;
      });
    }
  }  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك فعّل إذن الموقع")),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
    });
  }

  Future<void> _pickOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapPickerPage(),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  Future<void> _submitReport() async {
    try {
      final reporterId =
          await SharedPreferencesHelper.getString(AppValues.userId) ?? '';
      if (reporterId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Missing reporter id')),
          );
        }
        return;
      }

      final id = await _repo.createReport(
        CreateReportRequestDto(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          category: _category ?? 5,
          visibility: _visibility??1,
          latitude: _latitude ?? 0,
          longitude: _longitude ?? 0,
          reporterId: reporterId,
        ),
      );

      await _repo.upload(id, _file!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إرسال البلاغ بنجاح ✅"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      setState(() => _currentStep = 6);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل الإرسال: $e")),
        );
      }
    }
  }
  bool _isLoading = false;

  void _nextStep() async {
    if (_currentStep == 5) {
      setState(() => _isLoading = true); // بداية اللودينج

      await _submitReport(); // تنفيذ الإرسال

      setState(() => _isLoading = false); // نهاية اللودينج

      // بعد نجاح الإرسال، الانتقال للهوم
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (_currentStep < 6) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  /// Stepper بصري مع دوائر وأيقونات وخط يمتد حتى الدائرة النشطة


  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Expanded(
          child: Column(
            children: [
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _category = 2),
                    child: ProblemCategoryItem(
                      title: "أمني",
                      color: Colors.red,
                      description: "مشاكل الأمان والإضاءة والحراسة",
                      iconPath: "assets/svg/امني.svg",
                      isSelected: _category == 2,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _category = 3),
                    child: ProblemCategoryItem(
                      title: "سلامة",
                      description: "مخاطر السلامة والحوادث المحتملة",
                      iconPath: "assets/svg/سلامه.svg",
                      isSelected: _category == 3,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _category = 4),
                    child: ProblemCategoryItem(
                      title: "بيئي",
                      description: "التلوث والنظافة والبيئة",
                      iconPath: "assets/svg/بيئي.svg",
                      isSelected: _category == 4,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _category = 5),
                    child: ProblemCategoryItem(
                      title: "مروري",
                      description: "مشاكل الطرق والمرور والمواصلات",
                      iconPath: "assets/svg/مروري.svg",
                      isSelected: _category == 5,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _category = 1),
                child: ProblemCategoryItem(
                  title: "أخرى",
                  iconPath: "assets/svg/الكل.svg",
                  isSelected: _category == 1,
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: context.hp(6)),
                child: GestureDetector(
                  onTap: () {
                    if (_category == null) {
                      // لو المستخدم ما اختارش حاجة
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى اختيار فئة المشكلة أولاً ⚠️'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return; // يمنع الانتقال
                    }
                    _nextStep(); // إذا اختار شيء ينقل للخطوة التالية
                  },
                  child: Container(
                    width: context.wp(80),
                    height: context.hp(6),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.sp(3)),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'التالي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case 1:
        return
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.sp(15)),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // عنوان الصفحة
                    Column(
                      children: [
                        Text(
                          'تفاصيل المشكلة',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: context.sp(20),
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: context.hp(1)),
                        SizedBox(
                          width: context.wp(80),
                          child: Text(
                            'اكتب وصفاً واضحاً ومفصلاً للمشكلة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF3D3D3D),
                              fontSize: context.sp(12),
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.hp(2)),

                    // عنوان البلاغ
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: context.wp(85),
                          child: Text(
                            'عنوان البلاغ',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: const Color(0xFF525252),
                              fontSize: context.sp(16),
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(1)),
                        Container(
                          width: context.wp(85),
                          height: context.hp(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(context.sp(5)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x3F000000),
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                                spreadRadius: 0,
                              ),
                            ],
                            border: _isTitleEmpty
                                ? Border.all(color: Colors.red, width: 2)
                                : null,
                          ),
                          child: TextField(
                            controller: _titleController,
                            onChanged: (_) {
                              if (_isTitleEmpty &&
                                  _titleController.text.trim().isNotEmpty) {
                                setState(() => _isTitleEmpty = false);
                              } else if (_titleController.text.trim().isEmpty) {
                                setState(() => _isTitleEmpty = true);
                              }
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.hp(2)),

                    // وصف البلاغ
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: context.wp(85),
                          child: Text(
                            'وصف البلاغ',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: const Color(0xFF525252),
                              fontSize: context.sp(16),
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(1)),
                        Container(
                          width: context.wp(85),
                          height: context.hp(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(context.sp(5)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x3F000000),
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                                spreadRadius: 0,
                              ),
                            ],
                            border: _isDescEmpty
                                ? Border.all(color: Colors.red, width: 2)
                                : null,
                          ),
                          child: TextField(
                            controller: _descController,
                            onChanged: (_) {
                              if (_isDescEmpty &&
                                  _descController.text.trim().isNotEmpty) {
                                setState(() => _isDescEmpty = false);
                              } else if (_descController.text.trim().isEmpty) {
                                setState(() => _isDescEmpty = true);
                              }
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.hp(3)),

                    // الأزرار
                    Padding(
                      padding: EdgeInsets.only(bottom: context.hp(2)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isTitleEmpty = _titleController.text.trim().isEmpty;
                                _isDescEmpty = _descController.text.trim().isEmpty;
                              });

                              if (_isTitleEmpty || _isDescEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'يرجى ملء جميع الحقول المطلوبة 🔴'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return; // يمنع الانتقال للخطوة التالية
                              }

                              _nextStep(); // كل شيء صحيح
                            },
                            child: Container(
                              width: context.wp(30),
                              height: context.hp(5),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.sp(15),
                                vertical: context.sp(5),
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(context.sp(3)),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'التالي',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.sp(16),
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _prevStep,
                            child: Container(
                              width: context.wp(30),
                              height: context.hp(5),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.sp(15),
                                vertical: context.sp(5),
                              ),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(context.sp(3)),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: const Color(0x3F000000),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'السابق',
                                  style: TextStyle(
                                    color: const Color(0xFF5D5D5D),
                                    fontSize: context.sp(16),
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
;
      case 2:
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: context.hp(2)),
            child: Container(
              width: context.wp(90), // بدل 335
              padding: EdgeInsets.all(context.sp(4)),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.sp(5)),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: context.sp(1),
                    offset: Offset(0, context.sp(0.5)),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: context.sp(4),
                  children: [
                    // العنوان والوصف
                    Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: context.sp(4),
                        children: [
                          Text(
                            'اضافه صور أو فيديو',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: context.sp(20),
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'الصور تساعد في فهم المشكلة بشكل أفضل (اختياري)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF3D3D3D),
                              fontSize: context.sp(12),
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Container اختيار الملفات
    Container(
    width: context.wp(90),
    height: context.hp(25),
    padding: EdgeInsets.all(context.sp(2)),
    decoration: ShapeDecoration(
    color: Colors.white,
    shape: RoundedRectangleBorder(
    side: BorderSide(width: context.sp(0.5), color: Color(0xFFC9C9C9)),
    borderRadius: BorderRadius.circular(context.sp(5)),
    ),
    ),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: () => _pickFile(false), // صورة
            icon: const Icon(Icons.image),
            label: const Text("صورة"),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => _pickFile(true), // فيديو
            icon: const Icon(Icons.videocam),
            label: const Text("فيديو"),
          ),
        ],
      ),

      if (_file != null)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(_isVideo ? Icons.videocam : Icons.image, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(_file!.path)),
            ],
          ),
        ),
    ],
    ),
    ),               SizedBox(height: context.hp(2)),
                    // الأزرار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: _nextStep,
                          child: Container(
                            width: context.wp(30),
                            height: context.hp(5),
                            decoration: ShapeDecoration(
                              color: Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.sp(3)),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'التالي',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _prevStep,
                          child: Container(
                            width: context.wp(30),
                            height: context.hp(5),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.sp(3)),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: context.sp(1),
                                  offset: Offset(0, context.sp(0.5)),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'السابق',
                              style: TextStyle(
                                color: Color(0xFF5D5D5D),
                                fontSize: context.sp(16),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.hp(2)),
                  ],
                ),
              ),
            ),
          ),
        );
        case 3:
        return Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: context.hp(2)),
                  child: Container(
                    width: context.wp(90),
                    padding: EdgeInsets.all(context.sp(30)),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.sp(20)),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // عنوان
                        Text(
                          'تحديد الموقع',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: context.sp(20),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        SizedBox(height: context.hp(1)),
                        Text(
                          'حدد موقع المشكله بدقة لتسهيل عملية الحل',
                          style: TextStyle(
                            color: Color(0xFF3D3D3D),
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.hp(2)),

                        // الكارت الأول
                        InkWell(
                          onTap: () async {
                            await _getCurrentLocation();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("تم تحديد الموقع"),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: context.hp(10),
                            padding: EdgeInsets.symmetric(
                                horizontal: context.wp(4), vertical: context.hp(1.5)),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.sp(15)),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(width: context.sp(6), height: context.sp(6), child: Stack()),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'الموقع الحالي',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: context.sp(16),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    Text(
                                      'استخدم موقعك الحالي تلقائيا',
                                      style: TextStyle(
                                        color: Color(0xFF8F8F8F),
                                        fontSize: context.sp(12),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                                Image.asset(
                                  'assets/images/location.png',
                                  color: Colors.green,
                                  width: context.wp(10),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(2)),

                        // الكارت الثاني
                        InkWell(
                          onTap: () async {
                            await _pickOnMap();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("تم تحديد الموقع"),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: context.hp(10),
                            padding: EdgeInsets.symmetric(
                                horizontal: context.wp(4), vertical: context.hp(1.5)),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.sp(15)),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(width: context.sp(6), height: context.sp(6), child: Stack()),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'تحديد علي الخريطة',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: context.sp(16),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    Text(
                                      'اختر الموقع يدويا من الخريطة',
                                      style: TextStyle(
                                        color: Color(0xFF8F8F8F),
                                        fontSize: context.sp(12),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: context.wp(1)),
                                  child: Icon(
                                    Icons.public,
                                    color: Colors.blue,
                                    size: context.sp(25),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ========================================
                // Row الأزرار تحت المحتوى مباشرة
                // ========================================
                Padding(
                  padding: EdgeInsets.only(bottom: context.hp(2), top: context.hp(5)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: _nextStep,
                        child: Container(
                          width: context.wp(30),
                          height: context.hp(5),
                          decoration: ShapeDecoration(
                            color: Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.sp(3)),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'التالي',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.sp(16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _prevStep,
                        child: Container(
                          width: context.wp(30),
                          height: context.hp(5),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.sp(3)),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: context.sp(1),
                                offset: Offset(0, context.sp(0.5)),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'السابق',
                            style: TextStyle(
                              color: Color(0xFF5D5D5D),
                              fontSize: context.sp(16),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );


      case 4:
        return Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.wp(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.wp(90),
                  padding: EdgeInsets.all(context.wp(4)),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.sp(15)),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: context.sp(4),
                        offset: Offset(0, context.sp(1)),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'مراجعة البلاغ',
                          style: TextStyle(
                            fontSize: context.sp(20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: context.hp(1)),
                      Center(
                        child: Text(
                          'تأكد من صحة جميع البيانات قبل الإرسال',
                          style: TextStyle(
                            fontSize: context.sp(12),
                            color: Color(0xFF3D3D3D),
                          ),
                        ),
                      ),
                      SizedBox(height: context.hp(2)),
                      Text(
                        'عنوان البلاغ',
                        style: TextStyle(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        _titleController.text,
                        style: TextStyle(fontSize: context.sp(12)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: context.hp(1)),
                      Text(
                        'وصف البلاغ',
                        style: TextStyle(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        _descController.text,
                        style: TextStyle(fontSize: context.sp(12)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                      SizedBox(height: context.hp(1)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: context.wp(2), vertical: context.hp(1)),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: Color(0xFF2563EB)),
                            borderRadius: BorderRadius.circular(context.sp(10)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: context.sp(16), color: Color(0xFF2563EB)),
                                Text(
                                  '  سيتم استخدام الموقع الحالي',
                                  style: TextStyle(
                                      fontSize: context.sp(10),
                                      color: Color(0xFF2563EB)),
                                ),
                              ],
                            ),
                            Text(
                              "${_latitude?.toStringAsFixed(4) ?? 0.0} , ${_longitude?.toStringAsFixed(4) ?? 0.0}",
                              style: TextStyle(
                                  fontSize: context.sp(10), color: Color(0xFF2563EB)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.hp(1)),
                      Text(
                        'اعدادات الخصوصيه',
                        style: TextStyle(
                            fontSize: context.sp(16), fontWeight: FontWeight.w700),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: context.hp(1)),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: context.wp(60),
                        runSpacing: context.hp(2),
                        children: [
                          RadioOption(
                            value: 1,
                            groupValue: _visibility,
                            text: 'علني',
                            onChanged: (v) => setState(() => _visibility = v!),
                          ),
                          RadioOption(
                            value: 2,
                            groupValue: _visibility,
                            text: 'سري',
                            onChanged: (v) => setState(() => _visibility = v!),
                          ),
                          RadioOption(
                            value: 3,
                            groupValue: _visibility,
                            text: 'مجهول',
                            onChanged: (v) => setState(() => _visibility = v!),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: context.hp(2), top: context.hp(5)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () async {
                          setState(() => _isLoading = true);
                          try {
                            await _submitReport();
                            if (!mounted) return;
                            Navigator.pushReplacementNamed(context, Routes.appSection);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("فشل الإرسال: $e")),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                        child: Container(
                          width: context.wp(30),
                          height: context.hp(5),
                          decoration: ShapeDecoration(
                            color: Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.sp(3)),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _isLoading
                              ? SizedBox(
                            width: context.sp(15),
                            height: context.sp(15),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            'التالي',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.sp(16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _prevStep,
                        child: Container(
                          width: context.wp(30),
                          height: context.hp(5),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.sp(3)),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: context.sp(1),
                                offset: Offset(0, context.sp(0.5)),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'السابق',
                            style: TextStyle(
                              color: Color(0xFF5D5D5D),
                              fontSize: context.sp(16),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return const SizedBox();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: context.hp(28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x3F000000),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(top: context.hp(3)),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Spacer(),
                        Text(
                          'اضافه بلاغ جديد',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF4D4D4D),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    SizedBox(height: context.hp(3)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        final isActive = _currentStep == index;
                        final isCompleted = _currentStep > index;

                        final steps = [
                          {"title": "التصنيف", "icon": "assets/images/all.png"},
                          {"title": "التفاصيل", "icon": "assets/images/details.png"},
                          {"title": "الوسائط", "icon": "assets/images/media.png"},
                          {"title": "الموقع", "icon": "assets/images/location.png"},
                          {"title": "المراجعه", "icon": "assets/images/all.png"},

                        ];

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.wp(2)),
                          child: ProfileStepItem(
                            title: steps[index]["title"]!,
                            iconPath: steps[index]["icon"]!,
                            isActive: isActive,
                            isCompleted: isCompleted,
                          ),
                        );
                      }),
                    )
                  ],
                ),
              ),
            ),


 //            Expanded(
 //              child: Column(
 //                children: [
 //                  Spacer(),
 //
 //                  Row(
 //                    mainAxisAlignment: MainAxisAlignment.center,
 //                    children: const [
 //                      Spacer(),
 //
 //                      ProblemCategoryItem(
 //                        title: "أمني",
 //                        description: "مشاكل الأمان والإضاءة والحراسة",
 //                        iconPath: "assets/svg/امني.svg",
 //                      ),
 // Spacer(),
 //                       ProblemCategoryItem(
 //                        title: "سلامة",
 //                        description: "مخاطر السلامة والحوادث المحتملة",
 //                        iconPath: "assets/svg/سلامه.svg",
 //                      ),
 //                      Spacer(),
 //
 //                    ],
 //                  ),
 //                  Spacer(),
 //
 //                  Row(
 //                    mainAxisAlignment: MainAxisAlignment.center,
 //                    children: const [
 //                      Spacer(),
 //
 //                      ProblemCategoryItem(
 //                        title: "بيئي",
 //                        description: "التلوث والنظافة والبيئة",
 //                        iconPath: "assets/svg/بيئي.svg",
 //                      ),
 //                      Spacer(),
 //                      ProblemCategoryItem(
 //                        title: "مروري",
 //                        description: "مشاكل الطرق والمرور والمواصلات",
 //                        iconPath: "assets/svg/مروري.svg",
 //                      ),
 //                      Spacer(),
 //
 //                    ],
 //                  ),
 //                  Spacer(),
 //
 //                  const ProblemCategoryItem(
 //                    title: "أخرى",
 //                    iconPath: "assets/svg/الكل.svg",
 //                  ),
 //                  Spacer(),
 //                  Padding(
 //                    padding:  EdgeInsets.only(bottom:context.hp(6)),
 //                    child: Container(
 //                      width: context.wp(80),
 //                      height: context.hp(7),
 //                      decoration: ShapeDecoration(
 //                        color: const Color(0xFF2563EB) /* primary */,
 //                        shape: RoundedRectangleBorder(
 //                          borderRadius: BorderRadius.circular(15),
 //                        ),
 //                      ),
 //                      child: Center(
 //                        child: Text(
 //                          'التالي',
 //                          style: TextStyle(
 //                            color: Colors.white,
 //                            fontSize: 16,
 //                            fontFamily: 'Cairo',
 //                            fontWeight: FontWeight.w700,
 //                          ),
 //                        ),
 //                      ),
 //                    ),
 //                  )
 //
 //                ],
 //              ),
 //            ),
_buildStepContent(),
          ],
        ),
      ),
      // bottomNavigationBar: _currentStep < 6
      //     ? BottomAppBar(
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 16),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         if (_currentStep > 0)
      //           TextButton(
      //             onPressed: _prevStep,
      //             child: const Text("رجوع"),
      //           ),
      //         TextButton(
      //           onPressed: _nextStep,
      //           child: Text(_currentStep == 5 ? "إرسال" : "التالي"),
      //         ),
      //       ],
      //     ),
      //   ),
      // )
      //     : null,
    );
  }
  Widget categoryItem(Map<String, dynamic> cat) {
    final isSelected = _category == cat["id"];
    return Padding(
      padding: const EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () => setState(() => _category = cat["id"]),
        child: Container(
          width: context.wp(40),
          height: context.hp(13), // زودنا الارتفاع لاستيعاب النص الإضافي
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.6), width: 0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 3,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cat["label"],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : cat["color"] as Color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    cat["icon"],
                    width: 40,
                    height: 40,
                    color: isSelected ? Colors.white : cat["color"] as Color,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                cat["description"] ?? "", // نص الوصف الجديد
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? pickedLocation;
  String? pickedAddress;
  TextEditingController _searchController = TextEditingController();
  MapController _mapController = MapController();

  // Reverse Geocoding
  Future<void> _getAddress(LatLng point) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'com.example.myapp',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name'];
        setState(() {
          pickedAddress = displayName ?? "العنوان غير متوفر";
        });
      } else {
        setState(() {
          pickedAddress = "فشل في جلب العنوان";
        });
      }
    } catch (e) {
      setState(() {
        pickedAddress = "حدث خطأ أثناء جلب العنوان";
      });
    }
  }

  // Forward Geocoding (بحث عن عنوان)
  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
    );

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'com.example.myapp',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final point = LatLng(lat, lon);

          setState(() {
            pickedLocation = point;
            pickedAddress = data[0]['display_name'];
          });

          _mapController.move(point, 15.0);
        } else {
          setState(() {
            pickedAddress = "المكان غير موجود";
          });
        }
      } else {
        setState(() {
          pickedAddress = "فشل في البحث";
        });
      }
    } catch (e) {
      setState(() {
        pickedAddress = "حدث خطأ أثناء البحث";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("اختر موقعك على الخريطة")),
      body: Column(
        children: [
          // حقل البحث
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "ابحث عن مكان",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchLocation,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // الخريطة
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(30.0444, 31.2357),
                    initialZoom: 12.0,
                    onTap: (tapPos, point) async {
                      setState(() {
                        pickedLocation = point;
                      });
                      await _getAddress(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.myapp',
                    ),
                    if (pickedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80,
                            height: 80,
                            point: pickedLocation!,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
                // عرض العنوان
                if (pickedAddress != null)
                  Positioned(
                    bottom: 80,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pickedAddress!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: pickedLocation == null
            ? null
            : () {
          Navigator.pop(context, pickedLocation);
        },
        label: const Text("تأكيد الموقع"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}

class RadioOption extends StatelessWidget { final int value; final int groupValue; final String text; final ValueChanged<int?> onChanged; const RadioOption({ super.key, required this.value, required this.groupValue, required this.text, required this.onChanged, }); @override Widget build(BuildContext context) { return InkWell( onTap: () => onChanged(value), child: Container( width: context.wp(30), height: context.hp(6), padding: EdgeInsets.symmetric(horizontal: context.wp(2)), decoration: ShapeDecoration( color: Colors.white, shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(context.sp(4)), ), shadows: [ BoxShadow( color: Color(0x3F000000), blurRadius: context.sp(4), ) ], ), child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(text, style: TextStyle(fontSize: context.sp(16))), Radio<int>( value: value, groupValue: groupValue, onChanged: onChanged, ), ], ), ), ); } }