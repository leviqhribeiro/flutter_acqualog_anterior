import 'package:flutter/material.dart';

class LoadActionButton extends StatelessWidget {
  LoadActionButton(
      {Key key,
      @required this.child,
      @required this.isLoading,
        @required this.onPressed,
        this.width = double.infinity,
      this.height,
      })
      : super(key: key);

  final bool isLoading;
  final double width;
  final double height;
  final Function onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 320);
    final basePaddingValue = 10.0;
    final height = this.height ?? Theme.of(context).buttonTheme.height;
    return AnimatedSwitcher(
      duration: duration,
      child: isLoading
          ? Container(
              width: height,
              height: height,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0.5, 1),
                    )
                  ]),
              padding: EdgeInsets.all(basePaddingValue),
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : null,
            )
          : _buildActionButton(context),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    //https://flutter.dev/docs/cookbook/animation/animated-container
    //AnimatedCrossFade(firstChild: null, secondChild: null, crossFadeState: null, duration: null)
    final height = this.height ?? Theme.of(context).buttonTheme.height;
    if (width != null) {
      return ConstrainedBox(
        constraints: BoxConstraints.expand(
          width: width,
          height: height,
        ),
        child: ElevatedButton(
          //textColor: Colors.white,
          //color: Theme.of(context).primaryColor,
          child: child,
          onPressed: isLoading ? () {} : onPressed,
        ),
      );
    } else {
      return ElevatedButton(
        //textColor: Colors.white,
        //color: Theme.of(context).primaryColor,
        child: child,
        onPressed: isLoading ? () {} : onPressed,
      );
    }
  }
}
