part of 'profile_page.dart';

class _OwnerProfileInteractions extends StatelessWidget {
  final ProfileCubit cubit;
  const _OwnerProfileInteractions({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      bloc: cubit,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _showEditProfileDialog(context, state.user!);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit profile'),
            ),
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed: () => _showProfileOptions(context),
              child: const Icon(Icons.settings),
            ),
          ],
        );
      },
    );
  }
}

class _GuestProfileInteractions extends StatelessWidget {
  final ProfileCubit cubit;
  const _GuestProfileInteractions({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final currentUserId = UserDataUtil.getUserId();
    return BlocBuilder<ProfileCubit, ProfileState>(
        bloc: cubit,
        builder: (context, state) {
          final followed = state.user!.followers.contains(currentUserId);

          if (state.user!.role == AccountType.customer.value()) {
            return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              followed == true
                  ? ElevatedButton.icon(
                      onPressed: () async {
                        await context
                            .read<ProfileCubit>()
                            .unfollowUser(state.user!, currentUserId);
                      },
                      icon: const Icon(Icons.person_remove_rounded),
                      label: const Text('Unfollow'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () async {
                        await context
                            .read<ProfileCubit>()
                            .followUser(state.user!, currentUserId);
                      },
                      icon: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Follow',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                          backgroundColor: CommonColor.activeBgColor),
                    ),
            ]);
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              followed == true
                  ? ElevatedButton.icon(
                      onPressed: () async {
                        await context
                            .read<ProfileCubit>()
                            .unfollowUser(state.user!, currentUserId);
                      },
                      icon: const Icon(Icons.person_remove_rounded),
                      label: const Text('Unfollow'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () async {
                        await context
                            .read<ProfileCubit>()
                            .followUser(state.user!, currentUserId);
                      },
                      icon: const Icon(
                        Icons.add_business,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Follow',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                          backgroundColor: CommonColor.activeBgColor),
                    ),
              const SizedBox(width: 5),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CameraPage.provider(reviewTarget: state.user),
                  ),
                ),
                icon: const Icon(Icons.reviews),
                label: const Text('Send review'),
              ),
              const SizedBox(width: 5),
              ElevatedButton.icon(
                onPressed: () {
                  context.pushNamed('single-shop', pathParameters: {
                    'shopId': state.user!.id,
                  }, extra: {
                    'shopImage': state.user!.image,
                    'shopName': state.user!.username,
                    'shopPhone': state.user!.phone,
                  });
                },
                icon: const Icon(Icons.food_bank),
                label: const Text('Products'),
              ),
            ],
          );
        });
  }
}

class _ChangePasswordBottomSheet extends StatefulWidget {
  const _ChangePasswordBottomSheet();

  @override
  State<_ChangePasswordBottomSheet> createState() =>
      __ChangePasswordBottomSheetState();
}

class __ChangePasswordBottomSheetState
    extends State<_ChangePasswordBottomSheet> {
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PasswordCubit, PasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordFailure) {
          ToastService.showToast(context, state.message, ToastType.warning);
          return;
        }
        if (state is ChangePasswordSuccess) {
          ToastService.showToast(context, state.message, ToastType.success);
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Confirm new password'),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  await context.read<PasswordCubit>().changePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                        confirmPasswordController.text,
                      );
                },
                child: const Text('Change Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
