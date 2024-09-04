import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../New Rx Project/Manager/BottomNav/BottomNavManager.dart';
import '../New Rx Project/Rep/Bottom navigation rep/Bottomnavigationrep.dart';
import '../Util/Routes/routes_name.dart';

class SuccessfullyAdded extends StatefulWidget {
  const SuccessfullyAdded({super.key});

  @override
  State<SuccessfullyAdded> createState() => _SuccessfullyAddedState();
}

class _SuccessfullyAddedState extends State<SuccessfullyAdded> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: -20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _navigateToNextPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToNextPage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userType = preferences.getString('userType');
    print('user type in succes splash:$userType');
    await Future.delayed(const Duration(seconds: 3), () {});
    if(userType == 'Rep'){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigationRep(),));
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigationMngr(),));
      // Navigator.pushNamedAndRemoveUntil(context, RoutesName.home_manager, (route) => false,);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6)
                ),
                child: Image.asset('assets/icons/splashimage.png')),
          ),
          SizedBox(
            height: 80,
            width: 80,
            child: AnimatedBuilder(
              animation: _animation,
              child: Image.asset('assets/icons/verify.png'),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animation.value),
                  child: child,
                );
              },
            ),
          ),
          const SizedBox(height: 10,),
          const Text('Success !', style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700
          ),)
        ],
      ),
    );
  }
}
