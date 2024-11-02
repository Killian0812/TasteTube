part of 'profile_page.dart';

Future<void> _showEditProfileDialog(BuildContext context, User user) {
  final cubit = context.read<ProfileCubit>();
  final usernameController = TextEditingController(text: user.username);
  final bioController = TextEditingController(text: user.bio ?? '');
  final emailController = TextEditingController(text: user.email ?? '');
  final phoneController = TextEditingController(text: user.phone ?? '');

  File? imageFile;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
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
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!) as ImageProvider<Object>
                          : (user.image != null
                              ? NetworkImage(user.image!)
                                  as ImageProvider<Object>
                              : null),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
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
