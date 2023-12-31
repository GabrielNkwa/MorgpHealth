import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/components/status_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class AppointmentDashboardComponent extends StatelessWidget {
  final UpcomingAppointmentModel upcomingData;

  const AppointmentDashboardComponent({required this.upcomingData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: context.width() - 32,
      decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (upcomingData.patientProfileImg.validate().isNotEmpty && upcomingData.doctorProfileImg.validate().isNotEmpty)
                ImageBorder(src: isDoctor() ? upcomingData.patientProfileImg.validate() : upcomingData.doctorProfileImg.validate(), height: 40, width: 40)
              else if (upcomingData.doctorName.validate().isNotEmpty)
                GradientBorder(
                  gradient: LinearGradient(colors: [primaryColor, appSecondaryColor], tileMode: TileMode.mirror),
                  strokeWidth: 2,
                  borderRadius: 80,
                  child: PlaceHolderWidget(
                    height: 40,
                    width: 40,
                    shape: BoxShape.circle,
                    alignment: Alignment.center,
                    child: Text(
                      isPatient() ? (upcomingData.doctorName.validate(value: 'D')[0].capitalizeFirstLetter()) : upcomingData.patientName.validate(value: 'P')[0].capitalizeFirstLetter(),
                      style: boldTextStyle(color: Colors.black),
                    ),
                  ),
                ),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(upcomingData.id.validate().prefixText(value: '#'), style: secondaryTextStyle(color: primaryColor)),
                  2.height,
                  Text(getRoleWiseAppointmentFirstText(upcomingData), style: boldTextStyle()),
                  if (upcomingData.getVisitTypesInString.validate().isNotEmpty) 4.height,
                  if (upcomingData.getVisitTypesInString.validate().isNotEmpty)
                    ReadMoreText(
                      upcomingData.getVisitTypesInString.validate(),
                      trimLines: 1,
                      style: secondaryTextStyle(),
                      colorClickableText: Colors.pink,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: locale.lblReadMore,
                      trimExpandedText: locale.lblReadLess,
                      locale: Localizations.localeOf(context),
                    ),
                ],
              ).expand(),
              StatusWidget(
                isAppointmentStatus: true,
                status: upcomingData.status.validate(),
              ),
            ],
          ),
          16.height,
          Container(
            width: context.width() - 64,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: boxDecorationDefault(color: context.scaffoldBackgroundColor),
            alignment: Alignment.center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ic_appointment.iconImage(size: 16).paddingLeft(16),
                10.width,
                Text('${upcomingData.appointmentDateFormat}', style: primaryTextStyle(size: 14)).expand(),
              ],
            ),
          ),
          8.height
        ],
      ),
    );
  }
}
