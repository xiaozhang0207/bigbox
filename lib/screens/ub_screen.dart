import 'package:bigbox/builder/scafold_builder.dart';
import 'package:bigbox/shared/app_bar.dart';
import 'package:flutter/material.dart';

class UbScreen extends StatefulWidget {
  const UbScreen({super.key});

  @override
  State<UbScreen> createState() => _UbScreenState();
}

class _UbScreenState extends State<UbScreen> {
  @override
  Widget build(BuildContext context) {
    return const ScafoldBuilder(
      appbar: CustomAppBar(
        title: 'Улаанбаатарт бүртгэх',
        isCamera: true,
      ),
      child: Column(
        children: [],
      ),
    );
  }
}
