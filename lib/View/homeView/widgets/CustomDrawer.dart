import 'package:flutter/material.dart';


import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../constants/styles.dart';
import '../../profile/settings/help.dart';
import '../../profile/settings/settings.dart';
import '../../profile/settings/terms_and_conditions.dart';
class CustomDrawer extends StatelessWidget {
   const CustomDrawer({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primaryColor,
      width: MediaQuery.of(context).size.width/1.5,
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: ListView(
          children: [
             SizedBox(
               height: MediaQuery.of(context).size.height/3.8,
               child: DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    Text('RXROUTE',style: text60018,),
                    SizedBox(height: 10,),
                    CircleAvatar(
                      radius: 40,
                      child: Text('${Utils.userName?[0].toUpperCase()}'),
                    ),
                    SizedBox(height: 10,),
                    Text('${Utils.UserType == 'rep' ? 'REPRESENTATIVE' : 'MANAGER'}',style: text60014,)
                  ],
                ),
                           ),
             ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings(),));
              },
              title: Row(
                children: [
                  SizedBox(
                    height:24,
                    width: 24,
                    child: Image.asset('assets/icons/settings2.png'),
                  ),
                  const SizedBox(width: 20,),
                  const Text('Settings',style: text60012),
                ],
              ),
            ),

            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => TermsAndConditions(),));
              },
              child: ListTile(
                title: Row(
                  children: [
                    SizedBox(
                      height:24,
                      width: 24,
                      child: Image.asset('assets/icons/termsandc.png'),
                    ),
                    const SizedBox(width: 20,),
                    const Text('Terms & Conditions',style: text60012,),
                  ],
                ),
              ),
            ),

            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => HelpCenter(),));
              },
              child: ListTile(
                title: Row(
                  children: [
                    SizedBox(
                      height:24,
                      width: 24,
                      child: Image.asset('assets/icons/help.png'),
                    ),
                    const SizedBox(width: 20,),
                    const Text('Help Center',style: text60012),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/3,),
            InkWell(
              onTap: (){
                Utils.deleteuser(context);
              },
              child: ListTile(
                title: Row(
                  children: [
                    SizedBox(
                      height:24,
                      width: 24,
                      child: Image.asset('assets/icons/exit.png'),
                    ),
                    const SizedBox(width: 20,),
                    const Text('Logout',style:text60012),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}