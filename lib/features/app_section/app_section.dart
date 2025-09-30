import 'package:flutter/material.dart';

import '../profile/presentation/pages/profile_page.dart';
import '../reports/presentation/pages/create_report_page.dart';
import '../reports/presentation/pages/feed_page.dart';
import '../../../../core/routes/routes.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final _feedPage = const FeedPage(); // 👈 نخليها ثابتة

  @override
  Widget build(BuildContext context) {
    // تبويب الإضافة كصفحة وهمية للـ Navigator
    Widget _currentPage() {
      switch (_selectedIndex) {
        case 0:
          return _feedPage;
        case 1:
        return CreateReportWizard();

        case 2:
          return const ProfilePage();
        default:
          return _feedPage;
      }
    }

    return Scaffold(
      body: _currentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: "إضافة بلاغ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "البروفايل",
          ),
        ],
      ),
    );
  }
}
