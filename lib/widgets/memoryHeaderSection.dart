import 'package:flutter/material.dart';
import 'package:mapbox_maps_example/responsive_constants.dart';

const double baseWidth = 375.0;


const Color kTitleColor = Colors.black;
class HeaderSection extends StatelessWidget {
  const HeaderSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rs = ResponsiveSize(context); 

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rs.paddingSmall,
        vertical: rs.scale(10.0), 
      ),
      margin: EdgeInsets.zero,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF2C5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.close, size: rs.iconSizeMedium, color: Colors.black),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/book.png',
                width: rs.iconSizeLarge,
                height: rs.iconSizeLarge,
                fit: BoxFit.fill,
              ),
              SizedBox(width: rs.scale(8.0)),
              Text(
                'New Memory',
                style: TextStyle(
                  fontSize: rs.titleFontSize,
                  fontFamily: 'Kumbh Sans',
                  color: kTitleColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.check, size: rs.iconSizeMedium, color: Colors.green),
        ],
      ),
    );
  }
}
