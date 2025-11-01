import 'package:flutter/material.dart';

import '../service/text_content.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red,),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('আমাদের সম্পর্কে',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, height: 1.5)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('প্রতিটি সদস্যের সামাজিক ও অর্থনৈতিক উন্নয়ন নিশ্চিত করা।',style: TextStyle(fontSize: 16, height: 1.5))),
          ),
          Text('আমাদের লক্ষ্য',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, height: 1.5)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(bngLong, style: TextStyle(fontSize: 16, height: 1.5),),
          )
        ],
      ),
    );
  }
}
