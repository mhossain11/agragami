import 'package:agragami/admin/id_create/service/create_id_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../auth/widgets/text_field.dart';
import '../../../cachehelper/chechehelper.dart';
import '../../../cachehelper/toast.dart';
import '../../log/service/log_service.dart';
import 'edit_id_screen.dart';

class CreateIdScreen extends StatefulWidget {
  const CreateIdScreen({super.key});

  @override
  State<CreateIdScreen> createState() => _CreateIdScreenState();
}

class _CreateIdScreenState extends State<CreateIdScreen> {
  TextEditingController useridController = TextEditingController();
  final CreateIdService _createIdService = CreateIdService();
  final LogService _logService = LogService();
  bool isLoadingId = false;
  String selectedRole = 'user';
  bool editView = false;
  String DocId ='';
  String name='';
  String email='';
  String adminId='';
  @override
  void initState() {
    super.initState();
    getName();
  }
  Future<String?> getName() async {
    name =  (await CacheHelper().getString('names'))!;
   // DocId =  (await CacheHelper().getString('userDocId'))!;
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

  Future<void> _create() async {
    setState(() => isLoadingId = true);

    final userId = useridController.text.trim();
    final newDocId = await _createIdService.addUserId(
      role: selectedRole,
      userId: userId,
    );

    // 🔹 If user already exists
    if (newDocId == null) {
      setState(() => isLoadingId = false);
      CustomToast().showToast(context, "User ID already exists!", Colors.orange);
      return;
    }

    // 🔹 Log the creation
    await _logService.addLog(
      name: name,
      email: email,
      userid: adminId,
      oldData: 'Create user id',
      newData: userId,
      note: 'User Id: $selectedRole Create',
    );

    // 🔹 Update UI
    setState(() {
      isLoadingId = false;
      editView = true;
      DocId = newDocId;
    });

    // 🔹 Success message
    CustomToast().showToast(context, "$selectedRole added successfully!", Colors.green);
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create User id'),
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

          // 🔹 Dropdown for Role Selection
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: "Select Role",
                border: OutlineInputBorder(),
              ),
              items: const [
               // DropdownMenuItem(value: 'admin', child: Text("Admin")),
                DropdownMenuItem(value: 'user', child: Text("User")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),
          ),
          SizedBox(height: 10,),

          isLoadingId? Center(child: CircularProgressIndicator(),):
         SizedBox(
            width: 250,
            child: ElevatedButton(
                onPressed:_create,
                child: Text('Create Id')),),
          SizedBox(height: 10,),
          Visibility(
            visible: editView,
            child: SizedBox(
              width: 250,
              child: ElevatedButton(
                  onPressed:(){
                    //debugPrint('DocId: $DocId');
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>EditIdScreen(
                          userId: useridController.text.toString(),
                          docId: DocId,
                          selectedRole: selectedRole,)));
                  },
                  child: Text('Edit Create Id')),),
          )

        ],
      ),
    );
  }
}
