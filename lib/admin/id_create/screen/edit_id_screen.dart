import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../auth/widgets/text_field.dart';
import '../../../cachehelper/toast.dart';
import '../service/create_id_service.dart';

class EditIdScreen extends StatefulWidget {
   EditIdScreen({super.key,required this.docId,
     required this.selectedRole,
     required this.userId
   });

  String userId;
  String docId;
  String selectedRole;


  @override
  State<EditIdScreen> createState() => _EditIdScreenState();
}

class _EditIdScreenState extends State<EditIdScreen> {
  TextEditingController useridController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  final CreateIdService _createIdService = CreateIdService();
  bool isLoadingId = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      roleController.text = widget.selectedRole;
    });
  }

  Future<void> _update() async {
    setState(() => isLoadingId = true);
    await _createIdService.updateUserId(
      role: roleController.text,
      docId: widget.docId,
      newUserId: useridController.text,
    );

    setState(() => isLoadingId = false);
    CustomToast().showToast(context,"${useridController.text} Update successfully!",Colors.green);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User id'),
        centerTitle: true,
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextField(controller: useridController,
              labelText: 'User_ID',),
          ),
          SizedBox(height: 10,),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextField(controller: roleController,readOnly: true,
              labelText: 'Role',),
          ),
          SizedBox(height: 10,),

          isLoadingId? Center(child: CircularProgressIndicator(),):
          SizedBox(
            width: 250,
            child: ElevatedButton(
                onPressed:_update,
                child: Text('Update Create Id')),),

        ],
      ),
    );
  }
}
