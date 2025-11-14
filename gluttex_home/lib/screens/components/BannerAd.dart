import 'package:flutter/material.dart';

Widget _buildBannerAd() {
  return Container(
    height: 60, // Standard banner height
    width: double.infinity,
    alignment: Alignment.center,
    child: AdWidget(ad: _bannerAd), // Your BannerAd instance
  );
}
