import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../../common/ui.dart';
import '../../../../../color_constants.dart';
import '../../../../common/animation_controllers/animation.dart';
import '../../../routes/app_routes.dart';
import '../../global_widgets/block_button_widget.dart';
import '../../global_widgets/loading_cards.dart';
import '../controller/validation_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ValidationView extends GetView<ValidationController> {

  List bookings = [];
  String barcode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.colorScheme.secondary,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            "Validate Transaction".tr,
            style: Get.textTheme.headline6.merge(TextStyle(color: context.theme.primaryColor)),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => {Get.offNamed(Routes.ROOT)},
          ),

        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(10),
          decoration: Ui.getBoxDecoration(color: backgroundColor),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: ()=>{
                          controller.currentState.value = 0
                        },
                        child: Obx(()=> Card(
                            color: controller.currentState.value == 0 ? interfaceColor : inactive,
                            elevation: controller.currentState.value == 0 ? 10 : null,
                            shadowColor:  inactive,
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text('Validate Delivery'.tr, style: TextStyle(color: Get.theme.primaryColor))
                            )
                        ))
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                        onTap: ()=>{
                          controller.currentState.value = 1
                        },
                        child: Obx(() => Card(
                            color: controller.currentState.value == 1 ? interfaceColor : inactive,
                            elevation: controller.currentState.value == 1 ? 10 : null,
                            shadowColor: inactive,
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text('Delivery Code'.tr, style: TextStyle(color: Get.theme.primaryColor))
                            )
                        )
                        )
                    )
                  ],
                ),
                SizedBox(height: 20),
                Obx(() => controller.currentState.value == 0 ? confirmDelivery(context) : buildBookingList(context)
                //myDeliveryCode(context)
                )
              ],
            )
          ),
        )
    );
  }

  Widget confirmDelivery(BuildContext context){
    return Column(
      children: [
        if(controller.validationType.value == 0 || controller.validationType.value == 1)...[
          DelayedAnimation(
              delay: 100,
              child: GestureDetector(
                  onTap: ()=>{
                    controller.validationType.value = 1,
                    controller.scan()
                  },
                  child: Card(
                    color: interfaceColor,
                    elevation: 10,
                    shadowColor: inactive,
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Icon(Icons.qr_code_scanner, size: 80, color: Colors.white),
                            SizedBox(height: 10),
                            Container(
                                padding: EdgeInsets.all(10),
                                child: Text('Scanner le Code'.tr, style: TextStyle(color: Get.theme.primaryColor)
                                )
                            )
                          ],
                        )
                    ),
                  )
              )
          ),
          SizedBox(height: 20),
          DelayedAnimation(delay: 150,
              child: Text('Scan details example', style: TextStyle(color: pink))),
          SizedBox(height:60),
        ],
        if(controller.validationType.value == 0)
        Text('---------- OR ----------'.tr, style: TextStyle(fontSize: 20)),
        //Divider(color: inactive),
        SizedBox(height: 30),
        if(controller.validationType.value == 0 || controller.validationType.value == 2)
        DelayedAnimation(delay: 200,
        child: Container(
            padding: EdgeInsets.only(top: 20, bottom: 14, left: 20, right: 20),
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                ],
                border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text( "Validation code".tr,
                  style: Get.textTheme.bodyText1,
                  textAlign: TextAlign.start,
                ),
                TextFormField(
                  maxLines: 1,
                  controller: controller.codeController,
                  onTap: ()=>{
                    controller.validationType.value = 2
                  },
                  //validator: validator,
                  style: Get.textTheme.bodyText2,
                  obscureText: false,
                  textAlign: TextAlign.start,
                  decoration: Ui.getInputDecoration(
                    hintText: 'xxxx xxxx xxxx',
                    iconData: Icons.lock,
                  ),
                ),
              ],
            )
        )),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if(controller.validationType.value != 0)
            DelayedAnimation(delay: 250,
                child: GestureDetector(
                    onTap: ()=>{
                      controller.validationType.value = 0
                    },
                    child: Obx(()=> Card(
                        color: controller.validationType.value != 0 ? specialColor : null,
                        elevation: controller.validationType.value != 0 ? 10 : null,
                        shadowColor:  controller.validationType.value != 0 ? specialColor :  null,
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('Cancel'.tr, style: Get.textTheme.headline5.merge(TextStyle(color: Get.theme.primaryColor)))
                        )
                    ))
                ),
            ),
            DelayedAnimation(delay: 250,
                child: BlockButtonWidget(
                  onPressed: () {
                    controller.completeTransaction(controller.codeController);
                    Timer(Duration(milliseconds: 100), () {
                      controller.codeController.clear();
                    });
                  },
                  color: Get.theme.colorScheme.secondary,
                  text: Text(
                    "Validate Transaction".tr,
                    style: Get.textTheme.headline5.merge(TextStyle(color: Get.theme.primaryColor)),
                  ),
                ).paddingSymmetric(vertical: 10, horizontal: 20)
            )
          ],
        )
      ],
    );
  }

  Widget buildBookingList(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                border: Border.all(
                  color: Get.theme.focusColor.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(10)),
            child: GestureDetector(
              onTap: () {
                //Get.toNamed(Routes.SEARCH, arguments: controller.heroTag.value);
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 12, left: 0),
                    child: Icon(Icons.search, color: Get.theme.colorScheme.secondary),
                  ),
                  Expanded(
                    child: Material(
                      color: Get.theme.primaryColor,
                      child: TextField(
                        //controller: controller.textEditingController,
                        style: Get.textTheme.bodyText2,
                        onChanged: (value)=> controller.filterSearchResults(value),
                        autofocus: false,
                        cursorColor: Get.theme.focusColor,
                        decoration: Ui.getInputDecoration(hintText: "Destination town...".tr),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() => Expanded(
              child: controller.isLoading.value ?
              LoadingCardWidget() :
              controller.bookings.value.isNotEmpty ?
              ListView.builder(
                  itemCount: controller.bookings.length,
                  itemBuilder: (context, index){
                    Future.delayed(Duration.zero, (){
                      controller.bookings.sort((a, b) => a['travel']["departure_date"].compareTo(b['travel']["departure_date"]));
                    });
                    return InkWell(
                        onTap: ()=>{
                          Get.bottomSheet(
                            buildBookingSheet(context, controller.bookings[index]['code']),
                            isScrollControlled: true,
                          )
                        },
                        child: Card(
                            elevation: 10,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              //side: BorderSide(color: interfaceColor.withOpacity(0.4), width: 2),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Column(
                              //alignment: AlignmentDirectional.topStart,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(width: 100,
                                            child: Center(child: FaIcon(FontAwesomeIcons.planeDeparture)),
                                          ),
                                          Container(width: 100,
                                            child: Center(child: FaIcon(FontAwesomeIcons.planeArrival)),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            alignment: Alignment.topCenter,
                                            width: 100,
                                            child: Text(controller.bookings[index]['travel']['departure_town'].toString(), style: Get.textTheme.headline1.merge(TextStyle(fontSize: 18))),
                                          ),
                                          FaIcon(FontAwesomeIcons.arrowRight),
                                          Container(
                                              alignment: Alignment.topCenter,
                                              width: 100,
                                              child: Text(controller.bookings[index]['travel']['arrival_town'].toString(), style: Get.textTheme.headline1.merge(TextStyle(fontSize: 18)))
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            child: Icon( FontAwesomeIcons.calendarDay, size: 18),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 12),
                                            width: 1,
                                            height: 24,
                                            color: Get.theme.focusColor.withOpacity(0.3),
                                          ),
                                          Expanded(
                                            child: Text('Date de Départ', style: Get.textTheme.headline1.
                                            merge(TextStyle(color: appColor, fontSize: 16))),
                                          ),
                                          Text(controller.bookings[index]['travel']['departure_date'].toString(), style: Get.textTheme.headline1.
                                          merge(TextStyle(color: interfaceColor, fontSize: 16)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 30,
                                                  child: Icon( Icons.attach_money_outlined, size: 18),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 12),
                                                  width: 1,
                                                  height: 24,
                                                  color: Get.theme.focusColor.withOpacity(0.3),
                                                ),
                                                Text(controller.bookings[index]['kilo_booked'].toString(), style: Get.textTheme.headline6.
                                                merge(TextStyle(color: specialColor, fontSize: 16)))
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            child: Row(
                                              children: [
                                                Icon(FontAwesomeIcons.shoppingBag, size: 18),
                                                Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 12),
                                                  width: 1,
                                                  height: 24,
                                                  color: Get.theme.focusColor.withOpacity(0.3),
                                                ),
                                                Text(controller.bookings[index]['kilo_booked_price'].toString() + " Kg", style: Get.textTheme.headline1.
                                                merge(TextStyle(color: appColor, fontSize: 16)))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                        )
                    );
                  }) : Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height /4),
                    FaIcon(FontAwesomeIcons.folderOpen, color: inactive.withOpacity(0.3),size: 80),
                    Text('No bookings found', style: Get.textTheme.headline5.merge(TextStyle(color: inactive.withOpacity(0.3))))
                  ]
              )
          ))
        ]
      )
    );
  }

  Widget buildBookingSheet(BuildContext context, var bookingCode){
    return Container(
      height: Get.height/1.2,
      decoration: BoxDecoration(
        color: background,
        //Get.theme.primaryColor,
        borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Get.theme.focusColor.withOpacity(0.4), blurRadius: 30, offset: Offset(0, -30)),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 30,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: (Get.width / 2) - 30),
              decoration: BoxDecoration(
                color: Get.theme.focusColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Get.theme.focusColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
                //child: SizedBox(height: 1,),
              ),
            ),
            SizedBox(height: 20),
            Text('Booking Validation', style: Get.textTheme.headline4.merge(TextStyle(fontSize: 20))),
            SizedBox(height: 20),
            DelayedAnimation(
                delay: 100,
                child: Container(
                  padding: EdgeInsets.only(top: 00,bottom: 20, left: 60, right: 60),
                  child: QrImage(
                    data: "$bookingCode",
                    version: QrVersions.auto,
                    size: 200,
                    gapless: false,
                  )
                )
            ),
            SizedBox(height: 20),
            Text('---------- OR ----------'.tr, style: TextStyle(fontSize: 20)),

            SizedBox(height: 20),
            DelayedAnimation(delay: 200,
                child: Container(
                    padding: EdgeInsets.only(top: 20, bottom: 14, left: 20, right: 20),
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                        ],
                        border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text( "Validation code".tr,
                          style: Get.textTheme.bodyText1,
                          textAlign: TextAlign.start,
                        ),
                        TextFormField(
                          maxLines: 1,
                          initialValue: bookingCode.toString(),
                          //controller: codeController,
                          onTap: ()=>{
                            //controller.validationType.value = 2
                          },
                          style: Get.textTheme.bodyText2,
                          readOnly: true,
                          obscureText: false,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    )
                )),
          ],
        )
      )
    );
  }
}
