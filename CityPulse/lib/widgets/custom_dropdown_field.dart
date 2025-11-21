import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:citypulse/core/theme/app_theme.dart';
import 'package:gap/gap.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<T> items;
  final T? value;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String? hintText;
  final bool isDense;

  const CustomDropdownField({
    Key? key,
    required this.title,
    required this.icon,
    required this.items,
    required this.value,
    required this.itemLabel,
    required this.onChanged,
    this.hintText,
    this.isDense = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 20),
            ),
            const Gap(10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const Gap(8),
        isIOS
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  int selectedIndex = value != null ? items.indexOf(value!) : 0;
                  final selected = await showCupertinoModalPopup<T>(
                    context: context,
                    builder: (ctx) => Container(
                      height: 250,
                      color: CupertinoColors.systemBackground.resolveFrom(ctx),
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground
                                  .resolveFrom(ctx),
                              border: Border(
                                bottom: BorderSide(
                                  color: CupertinoColors.separator.resolveFrom(
                                    ctx,
                                  ),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CupertinoButton(
                                  child: const Text('İptal'),
                                  onPressed: () => Navigator.pop(ctx),
                                ),
                                CupertinoButton(
                                  child: const Text('Tamam'),
                                  onPressed: () =>
                                      Navigator.pop(ctx, items[selectedIndex]),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 32,
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedIndex,
                              ),
                              onSelectedItemChanged: (index) {
                                selectedIndex = index;
                              },
                              children: items
                                  .map((e) => Center(child: Text(itemLabel(e))))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (selected != null) onChanged(selected);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          value != null
                              ? itemLabel(value!)
                              : (hintText ?? 'Seçiniz'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_down,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              )
            : DropdownButtonFormField<T>(
                isDense: isDense,
                decoration: InputDecoration(
                  hintText: hintText ?? 'Seçiniz',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primaryBlue,
                  ),
                ),
                value: value,
                items: items
                    .map(
                      (e) => DropdownMenuItem<T>(
                        value: e,
                        child: Text(itemLabel(e)),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
      ],
    );
  }
}
