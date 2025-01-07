import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:food_app/utilities/constants.dart';
import 'package:food_app/utilities/layout_constants.dart';

class AppBarwidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarwidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorPalette.bgColor,
      title: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: LayoutConstants.paddingSmall),
        child: Row(
          children: [
            SvgPicture.asset(
              IconsName.menu,
              height: 30,
              width: 40,
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  IconsName.location,
                  height: 30,
                  width: 40,
                ),
                const SizedBox(width: 20),
                const Text('Mumbai',
                    style: TextStyle(
                        fontSize: FontsSize.head6,
                        fontWeight: FontWeight.w300)),
                const SizedBox(width: 20),
                SvgPicture.asset(
                  IconsName.dropdown,
                  height: 30,
                  width: 40,
                ),
              ],
            )),
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(ImagesName.avatar),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
