import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {

  LoadingWidget({@required this.title, Key key}):super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10,
          ),
          ConstrainedBox(
            constraints: BoxConstraints.loose(Size.fromWidth(200)),
            child: LinearProgressIndicator(),
          )
        ],
      ),
    );
  }
}
