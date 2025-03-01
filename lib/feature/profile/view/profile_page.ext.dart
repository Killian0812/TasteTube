part of 'profile_page.dart';

Future<void> _showEditProfileDialog(BuildContext context, User user) {
  final cubit = context.read<ProfileCubit>();
  final usernameController = TextEditingController(text: user.username);
  final bioController = TextEditingController(text: user.bio ?? '');
  final emailController = TextEditingController(text: user.email ?? '');
  final phoneController = TextEditingController(text: user.phone ?? '');

  XFile? imageFile;

  Future<void> pickImage() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return Padding(
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
              'Edit Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            StatefulBuilder(builder: (context, snapshot) {
              return Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: imageFile != null
                            ? (kIsWeb
                                ? Image.network(
                                    imageFile!.path,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(imageFile!.path),
                                    fit: BoxFit.cover,
                                  ))
                            : (user.image != null
                                ? Image.network(
                                    user.image!,
                                    fit: BoxFit.cover,
                                  )
                                : null),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black..withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.upload,
                        size: 30,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await pickImage();
                        snapshot(() {});
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
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
                  await cubit.updateProfile(
                    bio: bioController.text,
                    username: usernameController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    imageFile: imageFile,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
            )
          ],
        ),
      );
    },
  );
}

Future<void> _showChangePasswordDialog(BuildContext context) {
  final cubit = context.read<PasswordCubit>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return BlocListener<PasswordCubit, PasswordState>(
        bloc: cubit,
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
                decoration:
                    const InputDecoration(labelText: 'Current password'),
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
                    await cubit.changePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                      confirmPasswordController.text,
                    );
                  },
                  child: const Text('Change Password',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
