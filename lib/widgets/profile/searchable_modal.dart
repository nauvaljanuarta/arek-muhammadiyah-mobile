import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showSearchableModal<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) itemLabel,
  required Function(T) onSelected,
}) async {
  final TextEditingController searchCtrl = TextEditingController();
  List<T> filteredItems = List.from(items);

  await showCupertinoModalPopup(
    context: context,
    builder: (_) {
      return SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.9, 
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      CupertinoSearchTextField(
                        controller: searchCtrl,
                        onChanged: (value) {
                          setModalState(() {
                            filteredItems = items
                                .where((e) => itemLabel(e)
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: filteredItems.isEmpty
                            ? const Center(
                                child: Text("Data tidak ditemukan"),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: filteredItems.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 0.5),
                                itemBuilder: (_, i) {
                                  final item = filteredItems[i];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      onSelected(item);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      child: Text(itemLabel(item)),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 2),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: SizedBox(
                          width: double.infinity,
                          child : const Center(child : Text("Tutup")))
                          ,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
