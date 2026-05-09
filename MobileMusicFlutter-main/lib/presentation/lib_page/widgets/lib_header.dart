import 'package:flutter/material.dart';

class LibHeader extends StatelessWidget {
  const LibHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Thư Viện',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, size: 28, color: Colors.white54),
            onPressed: () {
              // TODO: Thêm chức năng tìm kiếm sau này
            },
          ),
        ],
      ),
    );
  }
}
