import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../auth/widgets/text_field.dart';
import '../../../cachehelper/chechehelper.dart';
import '../../../cachehelper/toast.dart';
import '../../log/service/log_service.dart';
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
  final LogService _logService = LogService();
  bool isLoadingId = false;
  String DocId ='';
  String name='';
  String email='';
  String adminId='';

  @override
  void initState() {
    super.initState();
    getName();
    setState(() {
      useridController.text = widget.userId;
      roleController.text = widget.selectedRole;
    });
  }

  Future<String?> getName() async {
    name =  (await CacheHelper().getString('names'))!;
     DocId =  (await CacheHelper().getString('userDocId'))!;
    adminId =  (await CacheHelper().getString('adminId'))!;
    email =  (await CacheHelper().getString('email'))!;
    if (name == null || name.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }if (adminId == null ||adminId.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }

    if (email == null || email.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }
    setState(() {
      name = name;
      email = email;
      adminId = adminId;
    });
  }

  Future<void> _update(BuildContext dialogContext) async {
    setState(() => isLoadingId = true);
    await _createIdService.updateUserId(
      role: roleController.text,
      docId: widget.docId,
      newUserId: useridController.text,
    );

    await _logService.addLog(
        name:  name,
        email: email,
        userid:  adminId,
        oldData:  widget.userId,
        newData: useridController.text,
        note: 'Edit User Id:${useridController.text}'
    );

    setState(() => isLoadingId = false);
    CustomToast().showToast(context,"${useridController.text} Update successfully!",Colors.green);
    useridController.clear();
    roleController.clear();
    Navigator.pop(context);
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
                onPressed:(){
                  _update(context);
                },
                child: Text('Update Create Id')),),

        ],
      ),
    );
  }
}
