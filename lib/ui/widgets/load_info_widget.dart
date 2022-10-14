import 'package:flutter/material.dart';

class LoadInfoWidget extends StatelessWidget {
  LoadInfoWidget({Key key,this.child,
    this.title,this.message,
    this.reloadAction, this.reloadButtonTitle,}):super(key: key);

  final Function reloadAction;
  final String title;
  final String message;
  final String reloadButtonTitle;
  final Widget child;


  @override
  Widget build(BuildContext context) {
    var messageWidget;
    if(message != null){
      messageWidget = Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyText2,
          textAlign: TextAlign.center,
        ),
      );
    }
    else{
      messageWidget = SizedBox(height: 10,);
    }
    return Padding(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Flexible(
            child: child??SizedBox(),
          ),
          SizedBox(height: 10,),
          Visibility(
            visible: title != null,
            child: Text(
              title??'',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ),
          messageWidget,
          Visibility(
            visible: reloadAction != null,
            child: MaterialButton(
              textColor: Theme.of(context).primaryColor,
              child: Text(
                reloadButtonTitle??'',
              ),
              onPressed: (){
                if(reloadAction != null){
                  reloadAction();
                }
              },
            ),
          ),
        ],
      ),
      padding: EdgeInsets.all(10.0),
    );
  }
}
