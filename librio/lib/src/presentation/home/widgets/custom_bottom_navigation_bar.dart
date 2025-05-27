import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:librio/src/routes/routes.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SvgPicture.asset('assets/icons/home_icon.svg',
                width: 24, height: 24),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SvgPicture.asset('assets/icons/exchange_icon.svg',
                width: 24, height: 24),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SvgPicture.asset('assets/icons/chat_icon.svg',
                width: 24, height: 24),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SvgPicture.asset('assets/icons/profile_icon.svg',
                width: 24, height: 24),
          ),
          label: '',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            if (currentIndex != 0) context.go(AppRoutes.home);
            break;
          case 1:
            if (currentIndex != 1) context.push(AppRoutes.exchangeRequests);
            break;
          case 2:
            // Chat - implementar depois
            break;
          case 3:
            if (currentIndex != 3) context.push(AppRoutes.profile);
            break;
        }
      },
    );
  }
}
