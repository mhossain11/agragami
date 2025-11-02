import 'package:Agragami/res/appsize.dart';
import 'package:Agragami/res/apptextstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperInfo extends StatelessWidget {
  const DeveloperInfo({super.key});

  final String _logo = 'assets/images/softkormo.png';
  final String _playStoreUrl =
      'https://play.google.com/store/apps/dev?id=7038737113790828648';
  final String _linkedinUrl =
      'https://www.linkedin.com/in/syed-faysal-hossain-885826196';
  final String _profileUrl = 'http://faysalhossain.com/';

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: AppSize.h8 * 20,
                width: AppSize.h8 * 20,
                child: CircleAvatar(
                  radius: AppSize.r28,
                  backgroundImage: AssetImage(_logo),
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Developed by Faysal Hossain',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Flutter & Android Developer',
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(height: 4),
          Text(
            'WhatsApp: 01687477579',
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(height: 14),
          // Play Store button
          ElevatedButton(
            onPressed: () => _launchUrl(_playStoreUrl),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('View Apps'),
          ),
          const SizedBox(height: 18),
          // LinkedIn icon button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50.h,
                width: 50.w,
                child: IconButton(
                  onPressed: () => _launchUrl(_profileUrl),
                  icon:  Image.asset('assets/images/link.png',),
                  tooltip: 'Profile',
                ),
              ),
              SizedBox(width: 10,),
              SizedBox(
                height: 50.h,
                width: 50.w,
                child: IconButton(
                  onPressed: () => _launchUrl(_linkedinUrl),
                  icon:  Image.asset('assets/images/linkedin.png',),
                  tooltip: 'LinkedIn Profile',
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
