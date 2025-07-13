import 'package:ai_movie_suggestion/presentation/common/utils/size_config.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/constants_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  final Function(int index) onCategorySelected;
  final int selectedIndex;

  const CategorySelector({
    super.key,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final List<String> categories = [
    AppStrings.trending,
    AppStrings.nowPlaying,
    AppStrings.newReleases
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize SizeConfig
    SizeConfig.init(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorManager.secondaryPrimary,
        borderRadius: BorderRadius.circular(SizeConfig.scaleSize(AppSize.s24)),
      ),
      padding: EdgeInsets.all(SizeConfig.scaleSize(AppSize.s2)),
      child: Row(
        children: List.generate(categories.length, (index) {
          final isSelected = index == widget.selectedIndex;
          return Expanded( 
            child: GestureDetector(
              onTap: () => widget.onCategorySelected(index),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: AppConstants.sliderAnimation),
                margin: EdgeInsets.symmetric(
                  horizontal: SizeConfig.scaleSize(2),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.scaleSize(AppSize.s8), // Reduced padding
                    vertical: SizeConfig.scaleSize(AppSize.s10)),
                decoration: BoxDecoration(
                  color: isSelected ? ColorManager.primary : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(SizeConfig.scaleSize(AppSize.s20)),
                ),
                child: FittedBox( // Wrap Text with FittedBox
                  fit: BoxFit.scaleDown,
                  child: Text(
                    categories[index],
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          fontSize: SizeConfig.scaleText(FontSize.s14),
                          color: isSelected
                              ? ColorManager.white
                              : Colors.white.withOpacity(0.6),
                        ),
                    textAlign: TextAlign.center,
                    // Remove overflow and maxLines to allow full text
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}