import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/bill_list_model.dart';
import 'package:kivicare_flutter/network/bill_repository.dart';
import 'package:kivicare_flutter/screens/patient/components/bill_component.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/bill_records_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class MyBillRecordsScreen extends StatefulWidget {
  @override
  _MyBillRecordsScreenState createState() => _MyBillRecordsScreenState();
}

class _MyBillRecordsScreenState extends State<MyBillRecordsScreen> {
  Future<List<BillListData>>? future;

  List<BillListData> billList = [];

  int page = 1;

  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    if (appStore.isLoading) {
      appStore.setLoading(false);
    }
    init();
  }

  void init({bool showLoader = false}) async {
    if (showLoader) appStore.setLoading(true);
    future = getBillListApi(
      page: page,
      billList: billList,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      setState(() {});
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.lblBillingRecords,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        elevation: 0,
        color: appPrimaryColor,
      ),
      body: InternetConnectivityWidget(
        retryCallback: () => setState,
        child: Stack(
          children: [
            SnapHelperWidget<List<BillListData>>(
              future: future,
              errorWidget: ErrorStateWidget(),
              loadingWidget: BillRecordsShimmerScreen(),
              errorBuilder: (error) {
                return NoDataWidget(
                  imageWidget: Image.asset(ic_somethingWentWrong, height: 180, width: 180),
                  title: error.toString(),
                ).center();
              },
              onSuccess: (snap) {
                if (snap.isEmpty) return EmptyStateWidget(emptyWidgetTitle: locale.lblNoBillsFound);
                return AnimatedScrollView(
                  onSwipeRefresh: () async {
                    setState(() {
                      page = 1;
                    });
                    init(showLoader: false);
                    return await 1.seconds.delay;
                  },
                  onNextPage: () {
                    if (!isLastPage) {
                      setState(() {
                        page++;
                      });
                      init(showLoader: true);
                    }
                  },
                  disposeScrollController: true,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
                  listAnimationType: listAnimationType,
                  physics: AlwaysScrollableScrollPhysics(),
                  slideConfiguration: SlideConfiguration(verticalOffset: 400),
                  children: [
                    Text('${locale.lblNote} :  ${locale.lblSwipeMassage}', style: secondaryTextStyle(size: 10, color: appSecondaryColor)),
                    8.height,
                    ...snap
                        .map((billData) => BillComponent(
                              billData: billData,
                              callToRefresh: () {
                                init(showLoader: true);
                              },
                            ))
                        .toList()
                  ],
                );
              },
            ),
            Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading).center(),
            )
          ],
        ),
      ),
    );
  }
}
