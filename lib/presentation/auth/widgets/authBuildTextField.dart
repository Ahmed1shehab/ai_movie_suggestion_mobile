import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';

Widget authBuildTextField({
  required TextEditingController controller,
  required String labelText,
  required String hintText,
  required Stream<bool> validationStream,
  required TextInputType keyboardType,
  bool obscureText = false,
  void Function(String)? onChanged,
}) {
  bool isHidden = obscureText;

  IconData? _getPrefixIcon(String label) {
    if (label.toLowerCase().contains("email")) {
      return Icons.email_rounded;
    } else if (label.toLowerCase().contains("password")) {
      return Icons.lock_rounded;
    } else if (label.toLowerCase().contains("full name")) {
      return Icons.person_rounded;
    } else if (label.toLowerCase().contains("verification code")) {
      return Icons.tag_rounded;
    }
    return null;
  }

  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeightManager.semiBold,
              fontSize: FontSize.s15,
              color: ColorManager.secondaryBlack,
            ),
          ),
          const SizedBox(height: AppSize.s10),
          StreamBuilder<bool>(
            stream: validationStream,
            builder: (context, snapshot) {
              final isValid = snapshot.data ?? true;
              
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.s12),
                  boxShadow: [
                    BoxShadow(
                      color: isValid 
                          ? Colors.black.withOpacity(0.04)
                          : ColorManager.error.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: isHidden,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: ColorManager.secondaryBlack,
                    fontSize: FontSize.s15,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: ColorManager.greyfield,
                      fontSize: FontSize.s14,
                    ),
                    filled: true,
                    fillColor: isValid 
                        ? ColorManager.white 
                        : ColorManager.error.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p16,
                      vertical: AppPadding.p16,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                        left: AppPadding.p12,
                        right: AppPadding.p8,
                      ),
                      child: Icon(
                        _getPrefixIcon(labelText),
                        color: isValid 
                            ? ColorManager.greyfield 
                            : ColorManager.error,
                        size: AppSize.s22,
                      ),
                    ),
                    suffixIcon: obscureText
                        ? IconButton(
                            icon: Icon(
                              isHidden
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: ColorManager.greyfield,
                              size: AppSize.s22,
                            ),
                            onPressed: () {
                              setState(() {
                                isHidden = !isHidden;
                              });
                            },
                          )
                        : null,
                    errorText: !isValid ? "Invalid $labelText" : null,
                    errorStyle: TextStyle(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeightManager.medium,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorManager.greyfield.withOpacity(0.3),
                        width: AppSize.s1,
                      ),
                      borderRadius: BorderRadius.circular(AppSize.s12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorManager.primary,
                        width: AppSize.s2,
                      ),
                      borderRadius: BorderRadius.circular(AppSize.s12),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorManager.error,
                        width: AppSize.s1_5,
                      ),
                      borderRadius: BorderRadius.circular(AppSize.s12),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorManager.error,
                        width: AppSize.s2,
                      ),
                      borderRadius: BorderRadius.circular(AppSize.s12),
                    ),
                  ),
                  onChanged: onChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Invalid $labelText";
                    }
                    return null;
                  },
                ),
              );
            },
          ),
        ],
      );
    },
  );
}