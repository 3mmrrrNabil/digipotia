import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/retrofit/ain_api.dart';
class AuthoritiesPage extends StatelessWidget {
  const AuthoritiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final api = serviceLocator<AinApi>();
    return Scaffold(
      appBar: AppBar(title: const Text('Authorities')),
      body: FutureBuilder<List<AuthorityDto>>(
        future: api.getAuthorities(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final a = items[index];
              return ListTile(title: Text(a.name), subtitle: Text(a.department));
            },
          );
        },
      ),
    );
  }
}

