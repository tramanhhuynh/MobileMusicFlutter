import 'package:flutter/material.dart';
import 'package:music_player/common/helpers/is_dark_mode.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget ? title;
  final Widget ? action;
  final Color ? backgroundColor;
  final bool hideBack;
  const BasicAppbar({
    this.title,
    this.hideBack = false,
    this.action,
    this.backgroundColor,
    super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: title ?? const Text(''),
      actions: [
        action ?? Container()
      ],
      leading: hideBack ? null : IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(200),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back_ios_new, size: 15, 
          color: context.IsDarkMode ? Colors.white : Colors.white )
        ),
      ),
    );
  }
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
