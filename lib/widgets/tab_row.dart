// tab_row
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TabRow extends StatelessWidget {
  const TabRow({
    Key? key,
    required this.onFilterTap,
  }) : super(key: key);

  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 6.0.h,
        width: MediaQuery.of(context).size.width / 3.0,
        child: OutlinedButton.icon(
          onPressed: onFilterTap,
          icon: const Icon(Icons.filter_list),
          label: Text(
            'Filter',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}