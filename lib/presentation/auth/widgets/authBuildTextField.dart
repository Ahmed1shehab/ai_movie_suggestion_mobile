import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';

Widget authBuildTextField(
    {required TextEditingController controller,
    required String labelText,
    required String hintText,
    required Stream<bool> validationStream,
    required TextInputType keyboardType,
    bool obscureText = false,
    void Function(String)? onChanged}) {
  bool isHidden = obscureText;

  // Choose prefix icon based on label
  IconData? _getPrefixIcon(String label) {
    if (label.toLowerCase().contains("email")) {
      return Icons.email_rounded;
    } else if (label.toLowerCase().contains("password")) {
      return Icons.lock;
    } else if (label.toLowerCase().contains("full name")) {
      return Icons.person;
    } else if (label.toLowerCase().contains("Verification Code")) {
      return Icons.tag_outlined;
    }
    return null;
  }

  return StatefulBuilder(
    builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labelText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeightManager.medium),
            ),
            const SizedBox(height: AppSize.s8),
            StreamBuilder<bool>(
              stream: validationStream,
              builder: (context, snapshot) {
                return TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: isHidden,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: ColorManager.secondaryBlack,
                      ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    prefixIcon: Icon(
                      _getPrefixIcon(labelText),
                      color: ColorManager.greyfield,
                    ),
                    suffixIcon: obscureText
                        ? IconButton(
                            icon: Icon(
                              isHidden
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: ColorManager.greyfield,
                            ),
                            onPressed: () {
                              setState(() {
                                isHidden = !isHidden;
                              });
                            },
                          )
                        : null,
                    errorText:
                        (snapshot.data ?? true) ? null : "Invalid $labelText",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: ColorManager.greyfield,
                          width: AppSize.s0_3), // greyfield thin
                      borderRadius: BorderRadius.circular(AppSize.s8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: ColorManager.primary, width: AppSize.s1),
                      borderRadius: BorderRadius.circular(AppSize.s8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: ColorManager.error, width: AppSize.s1_5),
                      borderRadius: BorderRadius.circular(AppSize.s8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: ColorManager.error, width: AppSize.s2),
                      borderRadius: BorderRadius.circular(AppSize.s8),
                    ),
                  ),
                  onChanged: onChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Invalid $labelText";
                    }
                    return null;
                  },
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
