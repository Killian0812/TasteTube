part of 'product_tab.dart';

class CreateOrEditProductPage extends StatefulWidget {
  final ProductCubit productCubit;
  final CategoryCubit categoryCubit;
  final Product? product;
  const CreateOrEditProductPage({
    super.key,
    required this.categoryCubit,
    required this.productCubit,
    this.product,
  });

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
  late TextEditingController prepTimeController;
  late TextEditingController sizeNameController;
  late TextEditingController sizePriceController;
  late TextEditingController toppingNameController;
  late TextEditingController toppingPriceController;
  late String selectedCurrency;
  late String? selectedCategory;
  List<XFile> selectedImages = [];
  List<SizeOption> sizes = [];
  List<ToppingOption> toppings = [];
  late bool ship;

  @override
  void initState() {
    nameController = TextEditingController(text: product?.name);
    costController = TextEditingController(text: product?.cost.toString());
    descriptionController = TextEditingController(text: product?.description);
    quantityController =
        TextEditingController(text: product?.quantity.toString() ?? '0');
    prepTimeController =
        TextEditingController(text: product?.prepTime?.toString());
    sizeNameController = TextEditingController();
    sizePriceController = TextEditingController();
    toppingNameController = TextEditingController();
    toppingPriceController = TextEditingController();
    selectedCurrency = product?.currency ?? "VND";
    selectedCategory = product?.categoryId;
    ship = product?.ship ?? true;
    sizes = product?.sizes ?? [];
    toppings = product?.toppings ?? [];
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    costController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    prepTimeController.dispose();
    sizeNameController.dispose();
    sizePriceController.dispose();
    toppingNameController.dispose();
    toppingPriceController.dispose();
    super.dispose();
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
                  widget.productCubit.deleteProduct(product!);
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: bottomNavBarHeight + 10),
        child: BlocBuilder<ProductCubit, ProductState>(
          bloc: widget.productCubit,
          builder: (context, state) {
            return CommonButton(
              text: isEditing ? 'Update' : 'Create',
              isLoading: (state is ProductLoading),
              onPressed: () async {
                final String name = nameController.text.trim();
                final double cost = double.tryParse(costController.text) ?? 0;
                final String description = descriptionController.text.trim();
                final int quantity = int.tryParse(quantityController.text) ?? 0;
                final int? prepTime = int.tryParse(prepTimeController.text);

                if (name.isNotEmpty && cost > 0 && selectedCategory != null) {
                  widget.productCubit.addOrEditProduct(
                    name: name,
                    cost: cost,
                    currency: selectedCurrency,
                    ship: ship,
                    description: description,
                    quantity: quantity,
                    categoryId: selectedCategory!,
                    images: selectedImages,
                    prepTime: prepTime,
                    sizes: sizes,
                    toppings: toppings,
                    product: product,
                  );
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
        ),
      ),
      body: BlocListener<ProductCubit, ProductState>(
        bloc: widget.productCubit,
        listener: (context, state) {
          if (state is CreateOrUpdateProductError) {
            ToastService.showToast(context, state.message, ToastType.warning);
            return;
          }
          if (state is ProductDeleted) {
            ToastService.showToast(context, state.message, ToastType.success);
            Navigator.of(context).pop();
            return;
          }
          if (state is CreateOrUpdateProductSuccess) {
            ToastService.showToast(context, state.message, ToastType.success);
            Navigator.of(context).pop();
            return;
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, appBarHeight + 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              TextField(
                controller: costController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Cost',
                  suffixText: UserDataUtil.getCurrency(),
                ),
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
              const SizedBox(height: 10),
              TextField(
                controller: prepTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Preparation Time (minutes)',
                  hintText: 'Optional',
                ),
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
                        ? const Icon(
                            Icons.local_shipping,
                            color: CommonColor.activeBgColor,
                          )
                        : const Icon(
                            Icons.not_interested,
                            color: Colors.white,
                          ),
                    styleBuilder: (value) => value
                        ? const ToggleStyle(
                            backgroundColor: CommonColor.activeBgColor,
                            indicatorColor: Colors.white,
                            borderColor: CommonColor.activeBgColor,
                          )
                        : const ToggleStyle(
                            backgroundColor: Colors.transparent,
                            indicatorColor: CommonColor.activeBgColor,
                            borderColor: CommonColor.activeBgColor,
                          ),
                    textBuilder: (value) => value
                        ? const Center(
                            child: Text(
                              'Yes',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : const Center(child: Text('No')),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Size Options Section
              const Text(
                'Size Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sizeNameController,
                      decoration: const InputDecoration(labelText: 'Size Name'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Tooltip(
                      message:
                          'Price can be negative (e.g., -10000 VND for smaller sizes)',
                      child: TextField(
                        controller: sizePriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        decoration: InputDecoration(
                          labelText: 'Extra Cost',
                          hintText: 'Can be negative (e.g., -10000)',
                          suffixText: UserDataUtil.getCurrency(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final name = sizeNameController.text.trim();
                      final price =
                          double.tryParse(sizePriceController.text) ?? 0;
                      if (name.isNotEmpty) {
                        setState(() {
                          sizes.add(SizeOption(name: name, extraCost: price));
                          sizeNameController.clear();
                          sizePriceController.clear();
                        });
                      } else {
                        ToastService.showToast(
                          context,
                          'Size name and valid price are required',
                          ToastType.warning,
                        );
                      }
                    },
                    child: const Text('Add Size'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (sizes.isNotEmpty)
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sizes.length,
                    itemBuilder: (context, index) {
                      final size = sizes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Chip(
                          label: Text('${size.name}: ${size.extraCost}'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              sizes.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),

              // Topping Options Section
              const Text(
                'Topping Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: toppingNameController,
                      decoration:
                          const InputDecoration(labelText: 'Topping Name'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: toppingPriceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Extra Cost',
                        suffixText: UserDataUtil.getCurrency(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final name = toppingNameController.text.trim();
                      final price =
                          double.tryParse(toppingPriceController.text) ?? 0;
                      if (name.isNotEmpty && price >= 0) {
                        setState(() {
                          toppings
                              .add(ToppingOption(name: name, extraCost: price));
                          toppingNameController.clear();
                          toppingPriceController.clear();
                        });
                      } else {
                        ToastService.showToast(
                          context,
                          'Topping name and valid price are required',
                          ToastType.warning,
                        );
                      }
                    },
                    child: const Text('Add Topping'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (toppings.isNotEmpty)
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: toppings.length,
                    itemBuilder: (context, index) {
                      final topping = toppings[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Chip(
                          label: Text('${topping.name}: ${topping.extraCost}'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              toppings.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),
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
                          product!.id,
                          product!.images[index].filename,
                        );
                        if (isDeleted) {
                          setState(() {
                            product!.images.removeAt(index);
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.7),
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
              final XFile item = selectedImages.removeAt(oldIndex);
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
                    child: kIsWeb
                        ? Image.network(
                            selectedImages[index].path,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(selectedImages[index].path),
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
                          color: Colors.red.withValues(alpha: 0.7),
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

  Future<List<XFile>> _pickImages() async {
    List<XFile> images = await _picker.pickMultiImage(limit: 8);
    images = images.sublist(0, min(8 - selectedImages.length, images.length));
    return images;
  }
}
