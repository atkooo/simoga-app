// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theming/colors.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;

  const SearchField({required this.controller});

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.w,
      child: TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        style: TextStyle(color: Colors.black, fontSize: 14.sp),
        decoration: InputDecoration(
          hintStyle: TextStyle(color: ColorsManager.gray76, fontSize: 14.sp),
          hintText: 'Cari...',
          prefixIcon: _focusNode.hasFocus
              ? null
              : Icon(Icons.search, color: Colors.grey.shade300),
          prefixIconConstraints: BoxConstraints(minWidth: 30.w),
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: ColorsManager.gray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: ColorsManager.mainBlue),
          ),
        ),
        onChanged: (value) {},
      ),
    );
  }
}
