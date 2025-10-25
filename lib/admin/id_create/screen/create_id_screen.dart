import 'package:flutter/material.dart';

import '../../../auth/widgets/text_field.dart';

class CreateIdScreen extends StatefulWidget {
  const CreateIdScreen({super.key});

  @override
  State<CreateIdScreen> createState() => _CreateIdScreenState();
}

class _CreateIdScreenState extends State<CreateIdScreen> {
  TextEditingController useridController = TextEditingController();
  bool isLoadingId = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: Column(
        children: [

          CustomTextField(controller: useridController,
            labelText: 'User_ID',),
          SizedBox(height: 10,),

          isLoadingId? Center(child: CircularProgressIndicator(),):
         SizedBox(
            width: 250,
            child: ElevatedButton(
                onPressed:(){},
                child: Text('Create Id')),)

        ],
      ),
    );
  }
}
