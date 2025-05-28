import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/search/view/search_cubit.dart';

class SearchUserTab extends StatelessWidget {
  const SearchUserTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchCubit, SearchState>(
      listener: (context, state) {
        if (state is SearchError) {
          ToastService.showToast(context, state.message, ToastType.warning);
        }
      },
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SearchInitial) {
          return const Center(child: Text('Type to search for users'));
        }
        final users = state.users;

        if (users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 15),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              key: ValueKey(user.id),
              leading: CircleAvatar(
                  radius: 30, backgroundImage: NetworkImage(user.image!)),
              title: Text(user.username),
              subtitle: Text(user.email!),
              onTap: () {
                context.push('/user/${user.id}');
              },
            );
          },
        );
      },
    );
  }
}
