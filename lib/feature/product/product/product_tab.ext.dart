part of 'product_tab.dart';

class CreateOrEditProductPage extends StatefulWidget {
  final ProductCubit productCubit;
  final CategoryCubit categoryCubit;
  final Product? product;
  const CreateOrEditProductPage(
      {super.key,
      required this.categoryCubit,
      required this.productCubit,
      this.product});

  @override
  State<CreateOrEditProductPage> createState() =>
      _CreateOrEditProductPageState();
}

class _CreateOrEditProductPageState extends State<CreateOrEditProductPage> {
  Product? get product => widget.product;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController nameController;
  late TextEditingController costController;
  late TextEditingController descriptionController;
  late TextEditingController quantityController;
  late String selectedCurrency;
  late String? selectedCategory;
  List<File> selectedImages = [];
  late bool ship;

  @override
  void initState() {
    nameController = TextEditingController(text: product?.name);
    costController = TextEditingController(text: product?.cost.toString());
    descriptionController = TextEditingController(text: product?.description);
    quantityController =
        TextEditingController(text: product?.quantity.toString() ?? '0');
    selectedCurrency = product?.currency ?? "VND";
    selectedCategory = product?.categoryId;
    ship = product?.ship ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categoryCubit.state.categories;
    final isEditing = product != null;

    return Scaffold(
      appBar: AppBar(
        title: isEditing
            ? const Text('Edit product')
            : const Text('Create new product'),
        actions: [
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () async {
                  bool? confirmed = await showConfirmDialog(
                    context,
                    title: "Confirm delete product",
                    body: 'Are you sure you want to delete this product?',
                  );
                  if (confirmed != true) {
                    return;
                  }
                  bool isDeleted =
                      await widget.productCubit.deleteProduct(product!);
                  if (isDeleted && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
        ],
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
              if (isEditing) _uploadedImages(context, widget.productCubit),
              _selectedImages(),
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
              Row(
                children: [
                  const Text("Ship:    "),
                  AnimatedToggleSwitch<bool>.dual(
                    current: ship,
                    first: false,
                    second: true,
                    borderWidth: 3.0,
                    onChanged: (bool value) => setState(() => ship = value),
                    iconBuilder: (value) => value
                        ? const Icon(Icons.local_shipping,
                            color: CommonColor.activeBgColor)
                        : const Icon(Icons.not_interested, color: Colors.grey),
                    styleBuilder: (value) => value
                        ? const ToggleStyle(
                            backgroundColor: CommonColor.activeBgColor,
                            indicatorColor: Colors.white)
                        : const ToggleStyle(
                            backgroundColor: CommonColor.greyOutBgColor),
                    textBuilder: (value) => value
                        ? const Center(
                            child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.white),
                          ))
                        : const Center(child: Text('No')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              BlocBuilder<ProductCubit, ProductState>(
                bloc: widget.productCubit,
                builder: (context, state) {
                  return CommonButton(
                    text: isEditing ? 'Update' : 'Create',
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
                        bool success =
                            await widget.productCubit.addOrEditProduct(
                          name,
                          cost,
                          selectedCurrency,
                          ship,
                          description,
                          quantity,
                          selectedCategory!,
                          selectedImages,
                          product,
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

  Widget _uploadedImages(BuildContext context, ProductCubit cubit) {
    if (product!.images.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return SizedBox(
        height: 110,
        child: ReorderableListView(
          scrollDirection: Axis.horizontal,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = product!.images.removeAt(oldIndex);
              product!.images.insert(newIndex, item);
            });
          },
          children: [
            for (int index = 0; index < product!.images.length; index++)
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                key: ValueKey(product!.images[index]),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Image.network(
                      product!.images[index].url,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () async {
                        bool? confirmed = await showConfirmDialog(
                          context,
                          title: "Confirm delete image",
                          body:
                              'Are you sure you want to delete this uploaded image?',
                        );
                        if (confirmed != true) {
                          return;
                        }
                        bool isDeleted = await cubit.deleteSingleProductImage(
                            product!.id, product!.images[index].filename);
                        if (isDeleted) {
                          setState(() {
                            product!.images.removeAt(index);
                          });
                        }
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
      );
    }
  }

  Widget _selectedImages() {
    if (selectedImages.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return SizedBox(
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
            for (int index = 0; index < selectedImages.length; index++)
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                key: ValueKey(selectedImages[index]),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
      );
    }
  }

  Future<List<File>> _pickImages() async {
    List<XFile> images = await _picker.pickMultiImage(limit: 8);
    images = images.sublist(0, min(8 - selectedImages.length, images.length));
    return images.map((image) => File(image.path)).toList();
  }
}
