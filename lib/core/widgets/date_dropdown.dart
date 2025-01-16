import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DateDropdown extends StatelessWidget {
  final String? selectedDay;
  final String? selectedMonth;
  final String? selectedYear;
  final Function(String?) onDayChanged;
  final Function(String?) onMonthChanged;
  final Function(String?) onYearChanged;
  final bool showDayDropdown;
  final bool showYearDropdown;

  const DateDropdown({
    super.key,
    this.selectedDay,
    this.selectedMonth,
    this.selectedYear,
    required this.onDayChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    this.showDayDropdown = false,
    this.showYearDropdown = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (showDayDropdown)
          SizedBox(
            width: 50.w,
            height: 30.w,
            child: _buildDropdown(
              items: List.generate(31, (index) => (index + 1).toString()),
              hint: 'Tanggal',
              value: selectedDay,
              onChanged: onDayChanged,
            ),
          ),
        if (showDayDropdown) SizedBox(width: 8.w),
        SizedBox(
          width: 120.w,
          height: 30.w,
          child: _buildDropdown(
            items: [
              'Januari',
              'Februari',
              'Maret',
              'April',
              'Mei',
              'Juni',
              'Juli',
              'Agustus',
              'September',
              'Oktober',
              'November',
              'Desember'
            ],
            hint: 'Bulan',
            value: selectedMonth,
            onChanged: onMonthChanged,
          ),
        ),
        if (showYearDropdown) SizedBox(width: 8.w),
        if (showYearDropdown)
          SizedBox(
            width: 80.w,
            height: 30.w,
            child: _buildDropdown(
              items: List.generate(
                  10, (index) => (DateTime.now().year - index).toString()),
              hint: 'Tahun',
              value: selectedYear,
              onChanged: onYearChanged,
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required String hint,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(fontSize: 14.sp, color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white,
          icon: Icon(Icons.arrow_drop_down,
              color: Colors.grey.shade600, size: 20.sp),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
