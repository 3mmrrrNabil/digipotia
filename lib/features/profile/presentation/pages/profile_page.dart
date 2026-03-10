import 'package:digipotia/core/extensions/media_query_extensions.dart';
import 'package:digipotia/features/profile/presentation/pages/points.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_values.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/retrofit/ain_api.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/storage_helper/app_shared_preference_helper.dart';
import '../cubit/profile_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileCubit _cubit;
  @override
  void initState() {
    super.initState();
    _checkLogin();

    _cubit = serviceLocator<ProfileCubit>();
    _cubit.load();

  }
  Future<void> _checkLogin() async {
    final token = await SharedPreferencesHelper.getString(AppValues.token);

    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login'); // أو المسار الفعلي لشاشة تسجيل الدخول
      }
    }
  }
  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  final List<Map<String, int>> levels = [
    {"min": 0, "max": 49},
    {"min": 50, "max": 99},
    {"min": 100, "max": 199},
    {"min": 200, "max": 499},
  ];

  int pointsToNextLevel(int points) {
    if (points < 50) {
      return 49 - points;
    } else if (points < 100) {
      return 99 - points;
    } else if (points < 200) {
      return 199 - points;
    } else if (points < 500) {
      return 499 - points;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double wp(double percent) =>
        MediaQuery.of(context).size.width * percent / 100;
    double hp(double percent) =>
        MediaQuery.of(context).size.height * percent / 100;

    return BlocBuilder<ProfileCubit, ProfileState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.data == null) {
          return const Center(child: Text('No data'));
        } else if (state.isSuccess) {
          final u = state.data!;
          List<ReportDto2> filteredReports = state.allItems;
          final int points = u.trustPoints;
          final int completedBadges = u.badge;

          final int totalPointsForAllBadges = pointsToNextLevel(points);

          final currentLevel = levels.firstWhere(
                (level) => points >= level["min"]! && points <= level["max"]!,
            orElse: () => levels.last,
          );

          final int levelRange =
              currentLevel["max"]! - currentLevel["min"]! + 1;
          final int currentPointsInLevel = points - currentLevel["min"]!;
          final double progressPercent = currentPointsInLevel / levelRange;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: wp(4), vertical: hp(3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
InkWell(
    onTap: ()=> Navigator.pushReplacementNamed(context,Routes.login),
    child: Icon(Icons.logout)),

                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(wp(2)),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 0),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name & Avatar Row
                            Row(
                              children: [

                                Container(
                                  width: wp(12),
                                  height: wp(12),
                                  padding: EdgeInsets.all(wp(3)),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF2563EB),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x3F000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 0),
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.person_outline,
                                      color: Colors.white,
                                      size: context.sp(20),
                                    ),
                                  ),
                                ),
                                SizedBox(width: wp(2)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          u.displayName,
                                          style: GoogleFonts.cairo(
                                            color: Colors.black,
                                            fontSize: wp(5),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.date_range_outlined,
                                          color: Color(0xFF2563EB),
                                          size: context.sp(16),
                                        ),
                                        Text(
                                          '  عضو منذ ديسمبر 2024',
                                          style: GoogleFonts.cairo(
                                            color: Colors.black,
                                            fontSize: wp(2.7),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: hp(2)),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: [
                                  Text(
                                    'متبقي ${totalPointsForAllBadges} نقطه علي وسامك القادم',
                                    style: GoogleFonts.cairo(
                                      color: const Color(0xFF747474),
                                      fontSize: wp(3.2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: hp(1.3)),
                            Stack(
                              alignment: Alignment.bottomLeft,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: hp(1.8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x3F000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 0),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: wp(40) * progressPercent,
                                  height: hp(1.8),
                                  decoration: BoxDecoration(
                                    color: const Color(0x9EFFF712),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: hp(2)),
                            InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return Points(
                                      points: u.trustPoints,
                                      completedBadges: u.badge == 0 ? 0 : u.badge,
                                    );
                                  },
                                ),
                              ),
                              child: Container(
                                width: double.infinity,
                                height: hp(4),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFFFFEE6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x3F000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 0),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(),
                                    Row(
                                      children: [
                                        Text(
                                          'عرض النقاط',
                                          style: GoogleFonts.cairo(
                                            color: Colors.black,
                                            fontSize: wp(3.2),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          "assets/svg/SparklesOutline.svg",
                                          width: wp(3),
                                          height: hp(3),
                                        )
                                      ],
                                    ),
                                    const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: hp(1)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: hp(2)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildInfoBox(context, '${state.data!.trustPoints}  من النقاط  ',
                            const Color(0xFFFFFEE6), "assets/svg/SparklesOutline.svg"),
                        buildInfoBox(context, '${_cubit.countStatus4()} تم حله',
                            const Color(0xFF48BB78).withOpacity(0.15), "assets/svg/true.svg"),
                        buildInfoBox(context, '${filteredReports.length} ',
                            const Color(0xFF2563EB).withOpacity(0.15), "assets/svg/document.svg"),
                      ],
                    ),
                    SizedBox(height: hp(2)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التقارير السابقه',
                          style: GoogleFonts.cairo(
                            color: Colors.black,
                            fontSize: wp(5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              
              
                      ],
                    ),
                    SizedBox(height: hp(1)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        return buildReportItem(
                          context,
                          report.title ?? 'مشكلة بدون عنوان',
                          formatTimeAgo(DateTime.parse(report.createdAt
                          )),
                          report.status,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // حالة الخطأ
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'حدث خطأ ما',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _cubit.load(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildInfoBox(BuildContext context, String text, Color color, String asset) {
    double wp(double percent) =>
        MediaQuery.of(context).size.width * percent / 100;
    double hp(double percent) =>
        MediaQuery.of(context).size.height * percent / 100;

    return Container(
      width: wp(25),
      height: hp(10),
      padding: EdgeInsets.symmetric(horizontal: wp(3), vertical: hp(0.5)),
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        shadows: [
          BoxShadow(
            color: const Color(0x3F000000).withOpacity(1 / 100),
            blurRadius: 3,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(asset, width: wp(3), height: hp(3)),
          SizedBox(height: hp(0.5)),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: const Color(0xFF5D5D5D),
              fontSize: wp(3),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReportItem(BuildContext context, String title, String subtitle, String status) {
    double wp(double percent) =>
        MediaQuery.of(context).size.width * percent / 100;
    double hp(double percent) =>
        MediaQuery.of(context).size.height * percent / 100;

    return Container(
      width: double.infinity,
      height: context.hp(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.withOpacity(0.4),
          width: 1.3,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 3),
            spreadRadius: 3,
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: hp(0.5)),
      child: Padding(
        padding: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.black,
                    fontSize: wp(3.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF747474),
                    fontSize: wp(2.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                width: status == '3' ||status == '5' ? 100 :   90,
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: status == '4'
                          ? const Color(0xFF0C9F36):
                      status == '3'? Colors.orange:
                      status == '5'? Colors.redAccent:
                      status == '2'? Colors.teal
                        :const Color(0xFF2563EB),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Center(
                  child: Text(
                    status == '1' ? 'معلق' : status == '2' ? 'قيد المعالجه':status == '3'?'تم الارسال':status == '4'?'تم الحل':status == '5'?'تم الرفض':'',
                    style: TextStyle(
                      color: status == '4'
                          ? const Color(0xFF0C9F36):
                      status == '3'? Colors.orange:
                      status == '5'? Colors.redAccent:
                      status == '2'? Colors.teal
                          :const Color(0xFF2563EB),
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String formatTimeAgo(DateTime date) {
    return timeago.format(date, locale: 'ar');
  }
}
