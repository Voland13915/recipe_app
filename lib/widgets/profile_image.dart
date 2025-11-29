import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final double height;
  final String image;
  const ProfileImage({
    Key? key,
    required this.height,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = image.trim().isNotEmpty;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
        image: hasImage
            ? DecorationImage(
          image: CachedNetworkImageProvider(image),
          fit: BoxFit.fitHeight,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: !hasImage
          ? Icon(
        Icons.person,
        size: height * 0.5,
        color: Colors.grey.shade600,
      )
          : null,
    );
  }
}