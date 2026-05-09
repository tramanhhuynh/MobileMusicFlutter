import 'package:flutter/material.dart';
import '../bloc/lib_state.dart';

class LibTabBar extends StatelessWidget {
  final LibraryFilter filter;
  final Function(LibraryFilter) onFilterChanged;
  const LibTabBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        _buildTab(context, 'Tất cả', LibraryFilter.all),
        const SizedBox(width: 16),
        _buildTab(context, 'Nhạc', LibraryFilter.music),
        const SizedBox(width: 16),
        _buildTab(context, 'Album', LibraryFilter.album),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String label, LibraryFilter value) {
    final bool selected = filter == value;
    return _HoverTab(
      label: label,
      selected: selected,
      onTap: () => onFilterChanged(value),
    );
  }
}

class _HoverTab extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _HoverTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_HoverTab> createState() => _HoverTabState();
}

class _HoverTabState extends State<_HoverTab> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bool showBlackText = widget.selected || _hovering;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected ? Colors.grey[300] : Colors.grey[800],
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: showBlackText ? Colors.black : Colors.white,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
