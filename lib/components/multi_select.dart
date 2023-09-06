// ignore_for_file: unused_import

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/body_widget.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/components/price_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/network/service_repository.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/select_service_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class MultiSelectWidget extends StatefulWidget {
  final int? clinicId;
  List<String>? selectedServicesId;

  MultiSelectWidget({this.clinicId, this.selectedServicesId});

  @override
  _MultiSelectWidgetState createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  TextEditingController searchCont = TextEditingController();

  Future<ServiceListModel>? future;

  List<ServiceData> servicesList = [];

  bool showClear = false;

  @override
  void initState() {
    super.initState();
    init(showLoader: false);
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) appStore.setLoading(true);
    getData();
  }

  Future<void> getData() async {
    future = getServiceResponseAPI(
      searchString: searchCont.text,
      clinicId: widget.clinicId.toString(),
      doctorId: appointmentAppStore.mDoctorSelected?.iD ?? userStore.userId.validate(),
    ).then((value) {
      if (searchCont.text.isNotEmpty) {
        showClear = true;
      } else {
        showClear = false;
      }
      servicesList = value.serviceData.validate();
      if (widget.selectedServicesId != null) {
        multiSelectStore.clearList();
        if (value.serviceData != null && value.serviceData.validate().isNotEmpty) {
          value.serviceData.validate().forEach((element) {
            if (widget.selectedServicesId.validate().contains(element.serviceId)) {
              element.isCheck = true;

              multiSelectStore.addSingleItem(element, isClear: false);
            }
          });
          value.serviceData.validate().retainWhere((element) => element.status == ACTIVE_SERVICE_STATUS);
        }
        setState(() {});
        appStore.setLoading(false);
      }
      return value;
    }).catchError((e) {
      appStore.setLoading(false);

      setState(() {});
      throw e;
    });
  }

  void _clearSearch() async {
    hideKeyboard(context);
    searchCont.clear();
    init(showLoader: true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future multiSelectDialog({String? text}) async {
    await showInDialog(
      context,
      contentPadding: EdgeInsets.all(0),
      builder: (p0) {
        return Container(
          width: context.width(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${locale.lblNote}: ', style: boldTextStyle()).paddingSymmetric(horizontal: 16, vertical: 16),
              ...[
                TextIcon(
                  prefix: ic_multi_select.iconImage(),
                  spacing: 16,
                  text: text ?? locale.lblMultipleSelectionIsAvailableForThisService,
                  expandedText: true,
                  maxLine: 2,
                  textStyle: primaryTextStyle(size: 14),
                ).paddingSymmetric(horizontal: 8),
              ],
              32.height,
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    finish(context);
                  },
                  child: Text(locale.lblClose, style: primaryTextStyle(color: primaryColor, size: 14)),
                ),
              ).paddingRight(8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.lblSelectServices,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        actions: [
          IconButton(
            onPressed: () {
              multiSelectDialog();
            },
            icon: Icon(Icons.info_outline_rounded, color: white),
          ).paddingRight(8),
        ],
      ),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            AppTextField(
              controller: searchCont,
              textFieldType: TextFieldType.NAME,
              decoration: inputDecoration(
                context: context,
                hintText: locale.lblSearchServices,
                prefixIcon: ic_search.iconImage().paddingAll(16),
                suffixIcon: !showClear
                    ? Offstage()
                    : ic_clear.iconImage().paddingAll(16).onTap(
                        () {
                          _clearSearch();
                        },
                        borderRadius: radius(),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
              ),
              onChanged: (newValue) {
                if (newValue.isEmpty) {
                  showClear = false;
                  _clearSearch();
                } else {
                  Timer(Duration(milliseconds: 500), () {
                    init(showLoader: true);
                  });
                  showClear = true;
                }
                setState(() {});
              },
              onFieldSubmitted: (searchString) {
                hideKeyboard(context);
                init(showLoader: true);
              },
            ).paddingOnly(bottom: 42, left: 16, right: 16, top: 16),
            16.height,
            Row(
              children: [
                ic_multi_select.iconImage(size: 16),
                8.width,
                Text(locale.lblMultipleSelectionIsAvailableForThisService, style: secondaryTextStyle()).expand(),
              ],
            ).paddingOnly(top: 84, bottom: 16, left: 16, right: 16),
            SnapHelperWidget<ServiceListModel>(
              future: future,
              loadingWidget: SelectServiceShimmerScreen(),
              errorBuilder: (error) {
                return NoDataWidget(
                  imageWidget: Image.asset(
                    ic_somethingWentWrong,
                    height: 180,
                    width: 180,
                  ),
                  title: error.toString(),
                );
              },
              errorWidget: ErrorStateWidget(),
              onSuccess: (snap) {
                if (snap.serviceData.validate().isEmpty && !appStore.isLoading) {
                  return SingleChildScrollView(child: NoDataFoundWidget(text: searchCont.text.isEmpty ? locale.lblNoActiveServicesAvailable : locale.lblCantFindServiceYouSearchedFor)).center();
                }
                snap.serviceData.validate().retainWhere((element) => element.status == ACTIVE_SERVICE_STATUS);

                return AnimatedListView(
                  itemCount: snap.serviceData.validate().length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 0, bottom: 80, right: 16, left: 16),
                  itemBuilder: (context, index) {
                    ServiceData serviceData = snap.serviceData.validate()[index];

                    if (serviceData.name.isEmptyOrNull) return Offstage();
                    return Container(
                      padding: EdgeInsets.zero,
                      decoration: boxDecorationDefault(boxShadow: [], color: context.cardColor),
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        checkboxShape: RoundedRectangleBorder(borderRadius: radius(4)),
                        controlAffinity: ListTileControlAffinity.trailing,
                        tileColor: context.cardColor,
                        secondary: serviceData.image.validate().isNotEmpty
                            ? ImageBorder(src: serviceData.image.validate(), height: 40).paddingSymmetric(horizontal: 8)
                            : GradientBorder(
                                gradient: LinearGradient(colors: [primaryColor, appSecondaryColor], tileMode: TileMode.mirror),
                                strokeWidth: 2,
                                borderRadius: 80,
                                child: PlaceHolderWidget(
                                  height: 40,
                                  width: 40,
                                  alignment: Alignment.center,
                                  shape: BoxShape.circle,
                                  child: Text(
                                    serviceData.name.validate(value: 'S')[0].capitalizeFirstLetter(),
                                    style: boldTextStyle(color: Colors.black, size: 20),
                                  ),
                                ),
                              ).paddingSymmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: radius()),
                        value: serviceData.isCheck,
                        title: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${serviceData.name.capitalizeFirstLetter().validate()}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: primaryTextStyle(),
                                ),
                                4.height,
                                PriceWidget(price: serviceData.charges.validate(), textStyle: boldTextStyle()),
                              ],
                            ).expand(),
                            8.width,
                            Row(
                              children: [
                                if (serviceData.multiple.validate()) ic_multi_select.iconImage(size: 20),
                              ],
                            ),
                          ],
                        ),
                        onChanged: (v) async {
                          if (serviceData.multiple.validate()) {
                            servicesList.forEach((element) {
                              if (element.multiple.validate() == false && element.isCheck) {
                                element.isCheck = false;
                                multiSelectStore.removeItem(element);
                              }
                            });
                            serviceData.isCheck = !serviceData.isCheck;
                            if (serviceData.isCheck) {
                              multiSelectStore.addSingleItem(serviceData, isClear: false);
                            } else {
                              multiSelectStore.removeItem(serviceData);
                            }
                            setState(() {});
                          } else {
                            if (servicesList.where((element) => element.isCheck.validate()).length > 1) {
                              await multiSelectDialog(text: locale.lblMultipleSelectionIsNotAvailableForThisService);
                            }
                            servicesList.forEach((element) {
                              if (element.isCheck) {
                                element.isCheck = false;
                                setState(() {});
                              }
                            });

                            serviceData.isCheck = !serviceData.isCheck;
                            if (serviceData.isCheck) {
                              multiSelectStore.addSingleItem(serviceData, isClear: true);
                            } else {
                              multiSelectStore.removeItem(serviceData);
                            }
                            setState(() {});
                          }
                        },
                      ),
                    ).paddingSymmetric(vertical: 8);
                  },
                ).paddingTop(16);
              },
            ).paddingTop(110),
            LoaderWidget().visible(appStore.isLoading).center()
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () {
          finish(context);
        },
      ),
    );
  }
}
