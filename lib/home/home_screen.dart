  import 'dart:ui';

  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';

  class Report {
    final String title;
    final String description;
    final String category;
    final String location;
    final String time;
    final String status;
    final String reporter;
    final String imageUrl;

    Report({
      required this.title,
      required this.description,
      required this.category,
      required this.location,
      required this.time,
      required this.status,
      required this.reporter,
      required this.imageUrl,
    });
  }

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    final List<String> categories = ["الكل", "أمني", "سلامه", "بيئي", "مروري"];
    String selectedCategory = "الكل";

    final List<Report> reports = [
      Report(
        title: "إضاءة الشارع",
        description:
        "الإضاءة في شارع الملك فهد معطلة منذ أسبوع مما يشكل خطراً أمنياً يؤثر على سلامة المشاة والسيارات في الليل زنحتاج لمن يصلحها في اقرب وقت .",
        category: "أمني",
        location: "شارع الرياض - الفهد",
        time: "منذ ساعتين",
        status: "قيد المعالجة",
        reporter: "أم محمد",
        imageUrl: "https://picsum.photos/400/200",
      ),
      Report(
        title: "مخلفات بناء",
        description: "وجود مخلفات بناء في الحي تشكل خطراً بيئياً وصحياً.",
        category: "بيئي",
        location: "حي الرمال",
        time: "منذ يوم",
        status: "قيد المعالجة",
        reporter: "سعيد",
        imageUrl: "https://picsum.photos/400/201",
      ),
      Report(
        title: "حادث مروري",
        description: "وقع حادث مروري على طريق الملك فهد يسبب ازدحام شديد.",
        category: "مروري",
        location: "طريق الملك فهد",
        time: "منذ 30 دقيقة",
        status: "قيد المعالجة",
        reporter: "فهد",
        imageUrl: "https://picsum.photos/400/202",
      ),
    ];

    @override
    Widget build(BuildContext context) {
      final filteredReports = selectedCategory == "الكل"
          ? reports
          : reports.where((r) => r.category == selectedCategory).toList();

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("اهلا بك"),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person_outline, color: Color(0xFF2563EB)),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ✅ التصنيفات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: const Text(
                  "التصنيفات",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                reverse: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ✅ التقارير
            Expanded(
              child: ListView.builder(
                itemCount: filteredReports.length,
                itemBuilder: (context, index) {
                  final report = filteredReports[index];
                  return Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.network(
                                report.imageUrl,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 160,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 160,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                                      decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.7),

                  gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2563EB),
                                            Color(0xFF444C97),
                                          ],
                                          begin: Alignment.centerRight,
                                          end: Alignment.centerLeft,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        report.status,
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ),
                            Positioned(
                              bottom: 15,
                              right: 8,

                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "${report.category} ",
                                      style:  GoogleFonts.cairo  (
                                          fontSize: 12, color: Colors.black87),
                                    ),
                                    const Icon(Icons.shield_sharp,
                                        size: 14, color: Colors.red),
                                    const SizedBox(width: 4),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12,right: 12,bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Center(
                                child: Icon(
                                  Icons.more_horiz,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                      "${report.time}  ",
                                        style: GoogleFonts.cairo (
                                          fontSize: 13,
                                          color: Color(0xFF5E5E5E),
                                        ),

                                      ),
                                      Icon(Icons.alarm,color:Color(0xFF5E5E5E),size: 15,),
                                    ],
                                  ),


                                  Row(
                                    children: [
                                      Text(
                                        report.reporter,
                                        style: GoogleFonts.cairo(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.person_outline,
                                          size: 17, color: Colors.blue),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                report.title,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                textDirection: TextDirection.rtl,
                                report.description,
                                style:  GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: Colors.black87,

                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                 IconButton(
                                      icon: const Icon(Icons.open_in_new,
                                          color: Colors.grey),
                                      onPressed: () {},
                                    ),

                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chat_outlined,
                                            color: Colors.grey),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.favorite_border,
                                            color: Colors.red),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2563EB),
          onPressed: () {},
          label:  Row(
            children: [
              Text(" اضافة بلاغ   ",style:   GoogleFonts.cairo(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 14),),
              Icon(Icons.add,color: Colors.white,size: 23,),
            ],
          ),
        ),
      );
    }
  }
