part of 'product_tab.dart';

class CreateProductPage extends StatefulWidget {
  final ProductCubit productCubit;
  final CategoryCubit categoryCubit;
  const CreateProductPage(
      {super.key, required this.categoryCubit, required this.productCubit});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final ImagePicker _picker = ImagePicker();
  final nameController = TextEditingController();
  final costController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController(text: "0");
  String selectedCurrency = 'VND';
  String? selectedCategory;
  List<File> selectedImages = [];

  @override
  Widget build(BuildContext context) {
    final categories = widget.categoryCubit.state.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new product'),
      ),
      body: BlocListener<ProductCubit, ProductState>(
        bloc: widget.productCubit,
        listener: (context, state) {
          if (state is CreateProductError) {
            ToastService.showToast(context, state.message, ToastType.warning);
            return;
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  selectedImages.addAll(await _pickImages());
                  setState(() {});
                },
                child: const Text('Pick images (Limit: 8)'),
              ),
              const SizedBox(height: 10),
              if (selectedImages.isNotEmpty)
                SizedBox(
                  height: 110,
                  child: ReorderableListView(
                    scrollDirection: Axis.horizontal,
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final File item = selectedImages.removeAt(oldIndex);
                        selectedImages.insert(newIndex, item);
                      });
                    },
                    children: [
                      for (int index = 0;
                          index < selectedImages.length;
                          index++)
                        Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          key: ValueKey(selectedImages[index]),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Image.file(
                                selectedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: costController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Cost'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedCurrency,
                    items: ['USD', 'VND'].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCurrency = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                hint: const Text('Category'),
                isExpanded: true,
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<ProductCubit, ProductState>(
                bloc: widget.productCubit,
                builder: (context, state) {
                  return CommonButton(
                    text: 'Create',
                    isLoading: (state is ProductLoading),
                    onPressed: () async {
                      final String name = nameController.text.trim();
                      final double cost =
                          double.tryParse(costController.text) ?? 0;
                      final String description =
                          descriptionController.text.trim();
                      final int quantity =
                          int.tryParse(quantityController.text) ?? 0;

                      if (name.isNotEmpty &&
                          cost > 0 &&
                          selectedCategory != null) {
                        bool success = await widget.productCubit.addProduct(
                          name,
                          cost,
                          selectedCurrency,
                          description,
                          quantity,
                          selectedCategory!,
                          selectedImages,
                        );
                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } else {
                        ToastService.showToast(
                          context,
                          'The product name, cost, and category are required',
                          ToastType.warning,
                        );
                      }
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<List<File>> _pickImages() async {
    List<XFile> images = await _picker.pickMultiImage(limit: 8);
    images = images.sublist(0, min(8 - selectedImages.length, images.length));
    return images.map((image) => File(image.path)).toList();
  }
}
