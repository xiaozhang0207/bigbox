// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:bigbox/configs/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CachedImageIniter extends StatelessWidget {
  String url;
  String type;
  double height;
  double radius;
  double width;
  CachedImageIniter(this.url,
      {super.key,
      this.type = 'default',
      this.height = 200,
      this.radius = 6.0,
      this.width = 0});

  @override
  Widget build(BuildContext context) {
    if (type == 'default') {
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: SizedBox(
          width: width == 0 ? double.infinity : width,
          height: height,
          child: url.contains('data:image/png;base64')
              ? Image.memory(
                  base64Decode(url.replaceAll('data:image/png;base64, ', '')),
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade50
                        : AppTheme.deepDarkGray,
                    highlightColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.grey.shade200
                            : AppTheme.dark,
                    child: Container(
                      width: width == 0 ? double.infinity : width,
                      height: height,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : AppTheme.dark,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: height,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppTheme.lighterGray
                        : AppTheme.deepDarkGray,
                  ),
                ),
        ),
      );
    } else {
      return Image(
        image: CachedNetworkImageProvider(url),
        fit: BoxFit.cover,
      );
    }
  }
}
