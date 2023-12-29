import 'package:flutter/material.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';

pricetagDesign(context, price, scategory, content) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
    alignment: Alignment.center,
    child: ListTile(
        title: Container(margin: EdgeInsets.only(bottom: 10), child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            scategory,
            price
          ],
        )),
        subtitle: content),
    decoration: BoxDecoration(
      boxShadow: [BoxShadow(color: maincolor,blurRadius: 3,)],
      border: Border.all(color: maincolor,),
      color: Colors.white,
    
      borderRadius: BorderRadius.circular(border_rad_size),
    ),
  );
}
