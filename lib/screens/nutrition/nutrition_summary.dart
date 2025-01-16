import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routing/routes.dart';
import 'line_chart_with_label.dart';
import '../recomendation_card/recomendation_tab.dart';
import '../../core/widgets/date_dropdown.dart';
import '../../theming/colors.dart';
import '../../theming/styles.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/section_title.dart';

class NutritionSummary extends StatefulWidget {
  final String childName;

  const NutritionSummary({super.key, required this.childName});

  @override
  _NutritionSummaryState createState() => _NutritionSummaryState();
}

class _NutritionSummaryState extends State<NutritionSummary> {
  String? selectedMonth;
  String? selectedYear;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Gizi ${widget.childName}',
          style: TextStyles.font24Blue700Weight.copyWith(
              color: ColorsManager.mainBlue, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            DateDropdown(
              selectedMonth: "Juni",
              selectedYear: "2024",
              onMonthChanged: (value) {
                setState(() {
                  selectedMonth = value;
                });
              },
              onYearChanged: (value) {
                setState(() {
                  selectedYear = value;
                });
              },
              onDayChanged: (_) {},
              showDayDropdown: false,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 180.w,
                ),
                child: SearchField(controller: _searchController),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'Kalori'),
                const LineChartWithLabel(
                  data: [
                    FlSpot(0, 1200),
                    FlSpot(1, 1500),
                    FlSpot(2, 1400),
                    FlSpot(3, 1600),
                    FlSpot(4, 1700),
                    FlSpot(5, 1800),
                    FlSpot(6, 1900),
                    FlSpot(7, 1200),
                    FlSpot(8, 1500),
                    FlSpot(9, 1400),
                    FlSpot(10, 1600),
                    FlSpot(11, 1700),
                    FlSpot(12, 1800),
                    FlSpot(13, 1900),
                  ],
                  color: ColorsManager.mainBlue,
                  unit: 'kkal (kilokalori)',
                ),
                SizedBox(height: 20.h),
                const SectionTitle(title: 'Protein'),
                const LineChartWithLabel(
                  data: [
                    FlSpot(0, 20),
                    FlSpot(1, 30),
                    FlSpot(2, 50),
                    FlSpot(3, 70),
                    FlSpot(4, 80),
                    FlSpot(5, 70),
                    FlSpot(6, 65),
                    FlSpot(7, 55),
                    FlSpot(8, 70),
                    FlSpot(9, 75),
                    FlSpot(10, 80),
                    FlSpot(11, 90),
                    FlSpot(12, 100),
                    FlSpot(13, 80),
                  ],
                  color: Colors.greenAccent,
                  unit: 'gram (g)',
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.mainBlue,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      child: Text(
                        'Tampilkan Semua',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                const SectionTitle(title: 'Rekomendasi'),
                SizedBox(height: 10.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      RecommendationCard(
                        icon: Icons.article,
                        title: 'Artikel',
                      ),
                      SizedBox(width: 16),
                      RecommendationCard(
                        icon: Icons.restaurant,
                        title: 'Resep',
                      ),
                      SizedBox(width: 16),
                      RecommendationCard(
                        icon: Icons.history,
                        title: 'Riwayat Makan',
                      ),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, Routes.educationContentList);
                        },
                        child: RecommendationCard(
                          icon: Icons.article,
                          title: 'Konten Edukasi',
                        ),
                      ),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, Routes.programIntervensiList);
                        },
                        child: RecommendationCard(
                          icon: Icons.article,
                          title: 'Program Intervensi',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
