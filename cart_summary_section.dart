import 'package:circle_list/circle_list.dart';
import 'package:consumer_flutter_app/screens/cart_summary_section_screen/controller/cart_summary_controller.dart';
import 'package:consumer_flutter_app/screens/cart_summary_section_screen/models/location.dart';
import 'package:consumer_flutter_app/screens/cart_summary_section_screen/widget/build_cost_estimation_and_add_Address.dart';
import 'package:consumer_flutter_app/screens/cart_summary_section_screen/widget/build_heading_widget.dart';
import 'package:consumer_flutter_app/screens/cart_summary_section_screen/widget/build_sliding_button_Widget.dart';
import 'package:consumer_flutter_app/screens/cart_summary_section_screen/widget/build_some_information_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../network/shared_prefs.dart';
import '../../styles.dart';
import '../../themes.dart';
import '../../widgets/custom_loader.dart';

class CartSummarySection extends StatefulWidget {
  CartSummarySection({Key? key, required this.parentController})
      : super(key: key);
  ScrollController parentController;

  @override
  State<CartSummarySection> createState() => _CartSummarySectionState();
}

class _CartSummarySectionState extends State<CartSummarySection> {
  @override
  RxString baseUrl = "".obs;
  FocusNode focusNode = FocusNode();
  bool isFocused = false;
  int _counter = 0;

  ScrollPhysics _physics = const NeverScrollableScrollPhysics();
  CartSummaryController cartSummaryController =
      Get.put(CartSummaryController());

  late ScrollController childController = ScrollController()
    ..addListener(listViewScrollListener);

  void listViewScrollListener() {
    if (childController.offset <= childController.position.minScrollExtent &&
        !childController.position.outOfRange) {
      setState(() {
        _physics = const NeverScrollableScrollPhysics();
      });
    }
  }

  init() async {
    baseUrl.value = (await SharedPref.getBaseUrl())!;
    setState(() {});
  }

  @override
  void initState() {
    init();
    CartSummaryController cartSummaryController =
        Get.put(CartSummaryController());
    cartSummaryController.getCartSummary(
        Location(lat: "28.386477482471445", long: "76.96638183036099"),
        context);
    super.initState();
  }

  void mainScrollListener() {
    if (widget.parentController.offset >=
        widget.parentController.position.maxScrollExtent) {
      setState(() {
        if (_physics is NeverScrollableScrollPhysics) {
          _physics = const ScrollPhysics();
          childController.animateTo(childController.position.minScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.parentController.addListener(mainScrollListener);
    return Padding(
        padding:
            EdgeInsets.symmetric(vertical: Insets.xl, horizontal: Insets.lg),
        child: ClipRect(
            child: Stack(children: [
          Container(
            height: Insets.offsetMed * 6.6,
            decoration: const BoxDecoration(
              borderRadius: Corners.xlBorder,
              color: AppTheme.white,
            ),
            child: Obx(
              () => cartSummaryController.cartResponse.value.data != null
                  ? Column(children: [
                      const BuildCartHeadingWidget(),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: childController,
                          physics: _physics,
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: Insets.sm,
                                bottom: Insets.offsetMed * 1.2,
                                left: Insets.lg,
                                right: Insets.lg),
                            child: Column(
                              children: [
                                buildCartItemsWidget(),
                                const BuildSomeInformationWidget(),
                                BuildCostEstimationAndAddAddress(),
                              ],
                            ),
                          ),
                        ),
                      )
                    ])
                  : showCircularLoader(),
            ),
          ),
          BuildSlidingButtonWidget(),
        ])));
  }

  Widget buildCartItemsWidget() {
    return Obx(() => Container(
          padding: EdgeInsets.only(top: Insets.xl, bottom: Insets.med),
          child: cartSummaryController.cartResponse.value.data!.itemCount! > 8
              ? buildGridView()
              : CircleList(
                  //if list items greater than 8 ,then buildGridView()
                  showInitialAnimation: true,
                  innerRadius: Insets.offset / 2,
                  outerRadius: cartSummaryController
                              .cartResponse.value.data!.orderItems!.length <
                          2
                      ? Insets.offset / 2
                      : Insets.offsetMed * 1.4,
                  origin: const Offset(0, 0),
                  childrenPadding: Insets.lg,
                  centerWidget: Column(
                    children: [
                      CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.transparent,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                                "${baseUrl.value}${cartSummaryController.cartResponse.value.data!.orderItems!.first.imageUrl!}"),
                            backgroundColor: Colors.purple[50],
                          )),
                      Text(
                        "${cartSummaryController.cartResponse.value.data!.orderItems!.first.finalQuantity!.toStringAsFixed(2)}kg |₹${cartSummaryController.cartResponse.value.data!.orderItems!.first.finalAmount!.toStringAsFixed(2)}",
                        style: TextStyles.title1.copyWith(fontSize: 11),
                      )
                    ],
                  ),
                  children: List.generate(
                      cartSummaryController
                              .cartResponse.value.data!.orderItems!.length -
                          1, (index) {
                    return Column(
                      children: [
                        CircleAvatar(
                            radius: Corners.outerAvatarRadius,
                            backgroundColor: Colors.transparent,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  "${baseUrl.value}${cartSummaryController.cartResponse.value.data!.orderItems![index + 1].imageUrl!}"),
                              backgroundColor: Colors.purple[50],
                            )),
                        Text(
                          "${cartSummaryController.cartResponse.value.data!.orderItems![index + 1].finalQuantity!.toStringAsFixed(2)}kg |₹${cartSummaryController.cartResponse.value.data!.orderItems![index + 1].finalAmount!.toStringAsFixed(2)}",
                          style: TextStyles.title1.copyWith(fontSize: 11),
                        )
                      ],
                    );
                  }),
                ),
        ));
  }

  Widget categoryItem({required String label, required int index}) =>
      GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Obx(
            () => Card(
              shape:
                  const RoundedRectangleBorder(borderRadius: Corners.lgBorder),
              color: AppTheme.containerWhite,
              semanticContainer: true,
              elevation: 2,
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Insets.sm, horizontal: Insets.sm),
                  child: Column(children: [
                    Row(children: [
                      Text("43",
                          style: TextStyles.body3
                              .copyWith(color: AppTheme.iconColor)),
                      const Spacer(),
                      SvgPicture.asset(
                        "assets/images/edit_icon.svg",
                        color: AppTheme.iconColor,
                        width: Insets.med,
                      )
                    ]),
                    SizedBox(
                      width: Insets.xxl * 3,
                      child: CircleAvatar(
                        radius: Insets.xl,
                        backgroundColor: AppTheme.grey.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.body1
                          .copyWith(color: AppTheme.iconColor, fontSize: 12),
                    ),
                    SizedBox(
                      height: Insets.xs,
                    ),
                    RichText(
                        text: TextSpan(
                            text:
                                "${cartSummaryController.cartResponse.value.data!.orderItems![index].finalQuantity!.toStringAsFixed(2)}",
                            style: TextStyles.h1
                                .copyWith(color: AppTheme.black, fontSize: 10),
                            children: <TextSpan>[
                          TextSpan(
                            text:
                                " ₹${cartSummaryController.cartResponse.value.data!.orderItems![index].finalAmount!.toStringAsFixed(2)}",
                            style: TextStyles.h1
                                .copyWith(color: AppTheme.red, fontSize: 10),
                          ),
                        ]))
                  ]),
                ),
              ),
            ),
          ),
          onTap: () {});

  Widget buildGridView() {
    return Padding(
        padding: EdgeInsets.only(left: Insets.lg, right: Insets.lg),
        child: GridView.builder(
          controller: childController,
          physics: _physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: Insets.sm,
            crossAxisCount: 3,
            childAspectRatio: 0.7,
          ),
          itemCount:
              cartSummaryController.cartResponse.value.data!.orderItems!.length,
          shrinkWrap: true,
          itemBuilder: (_, index) => categoryItem(
              label: cartSummaryController
                  .cartResponse.value.data!.orderItems![index].productName!,
              index: index),
        ));
  }
}
