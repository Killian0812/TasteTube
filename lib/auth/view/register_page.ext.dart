import 'package:flutter/material.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/text.dart';

class AccountTypeSelectionPage extends StatefulWidget {
  const AccountTypeSelectionPage({super.key});

  @override
  State<AccountTypeSelectionPage> createState() =>
      _AccountTypeSelectionPageState();
}

class _AccountTypeSelectionPageState extends State<AccountTypeSelectionPage> {
  String selectedRole = '';

  String getDescriptionForRole(String role) {
    switch (role) {
      case 'RESTAURANT':
        return 'As a restaurant, you can manage your menu, receive customer feedback, and showcase your offerings.';
      case 'CUSTOMER':
        return 'As a customer, you can explore restaurants, view menus, and share reviews of your dining experiences.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Select account type",
          style: CommonTextStyle.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Choose how you would like to use the app:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAccountTypeCard(
                  title: 'RESTAURANT',
                  icon: Icons.restaurant_menu,
                  isSelected: selectedRole == 'RESTAURANT',
                  onTap: () {
                    setState(() {
                      selectedRole = 'RESTAURANT';
                    });
                  },
                ),
                _buildAccountTypeCard(
                  title: 'CUSTOMER',
                  icon: Icons.person,
                  isSelected: selectedRole == 'CUSTOMER',
                  onTap: () {
                    setState(() {
                      selectedRole = 'CUSTOMER';
                    });
                  },
                ),
              ],
            ),
            selectedRole.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 30.0),
                    child: Text(
                      getDescriptionForRole(selectedRole),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : const SizedBox(height: 40),
            CommonButton(
              text: "Confirm",
              onPressed: () {
                showConfirmDialog(
                  context,
                  title: "Confirm account type",
                  body:
                      'You have selected $selectedRole as your account type.\n'
                      'This selection allows you to enjoy specialized features.\n\n'
                      'Action is irreversible.\n',
                );
              },
              isDisabled: selectedRole.isEmpty,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 150,
        height: 180,
        decoration: BoxDecoration(
          color: isSelected
              ? CommonColor.activeBgColor
              : CommonColor.greyOutBgColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 10,
              )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 60, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
