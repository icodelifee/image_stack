library image_stack;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Creates an array of circular images stacked over each other
class ImageStack extends StatelessWidget {
  /// List of image urls
  final List<String> imageList;

  /// Image radius for the circular image
  final double? imageRadius;

  /// Count of the number of images to be shown
  final int? imageCount;

  /// Total count will be used to determine the number of circular images
  /// to be shown along with showing the remaining count in an additional
  /// circle
  final int totalCount;

  /// Optional field to set the circular image border width
  final double? imageBorderWidth;

  /// Optional field to set the color of circular image border
  final Color? imageBorderColor;

  /// The text style to apply if there is any extra count to be shown
  final TextStyle extraCountTextStyle;

  /// Set the background color of the circle
  final Color backgroundColor;

  /// Enum to define the image source.
  ///
  /// Describes type of the image source being sent in [imageList]
  ///
  /// Possible values:
  ///  * Asset
  ///  * Network
  ///  * File
  final ImageSource? imageSource;

  /// Custom widget list passed to render circular images
  final List<Widget> children;

  /// Radius for the circular image to applied when [children] is passed
  final double? widgetRadius;

  /// Count of the number of widget to be shown as circular images when [children]
  /// is passed
  final int? widgetCount;

  /// Optional field to set the circular border width when [children] is passed
  final double? widgetBorderWidth;

  /// Optional field to set the color of circular border when [children] is passed
  final Color? widgetBorderColor;

  /// List of `ImageProvider`
  final List<ImageProvider> providers;

  /// To show the remaining count if the provided list size is less than [totalCount]
  final bool showTotalCount;

  final CounterType counterType;

  /// Creates a image stack widget.
  ///
  /// The [imageList] and [totalCount] parameters are required.
  ImageStack({
    Key? key,
    required this.imageList,
    this.imageRadius = 25,
    this.imageCount = 3,
    required this.totalCount,
    this.imageBorderWidth = 2,
    this.imageBorderColor = Colors.grey,
    this.imageSource = ImageSource.Network,
    this.showTotalCount = true,
    this.counterType = CounterType.Separate,
    this.extraCountTextStyle = const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    this.backgroundColor = Colors.white,
  })  : children = [],
        providers = [],
        widgetBorderColor = null,
        widgetBorderWidth = null,
        widgetCount = null,
        widgetRadius = null,
        super(key: key);

  /// Creates a image stack widget by passing list of custom widgets.
  ///
  /// The [children] and [totalCount] parameters are required.
  ImageStack.widgets({
    Key? key,
    required this.children,
    this.widgetRadius = 25,
    this.widgetCount = 3,
    required this.totalCount,
    this.widgetBorderWidth = 2,
    Color this.widgetBorderColor = Colors.grey,
    this.counterType = CounterType.Separate,
    this.showTotalCount = true,
    this.extraCountTextStyle = const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    this.backgroundColor = Colors.white,
  })  : imageList = [],
        providers = [],
        imageBorderColor = null,
        imageBorderWidth = null,
        imageCount = null,
        imageRadius = null,
        imageSource = null,
        super(key: key);

  /// Creates an image stack by passing list of `ImageProvider`.
  ///
  /// The [providers] and [totalCount] parameters are required.
  ImageStack.providers({
    Key? key,
    required this.providers,
    this.imageRadius = 25,
    this.imageCount = 3,
    required this.totalCount,
    this.imageBorderWidth = 2,
    this.imageBorderColor = Colors.grey,
    this.showTotalCount = true,
    this.counterType = CounterType.Separate,
    this.extraCountTextStyle = const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    this.backgroundColor = Colors.white,
  })  : imageList = [],
        children = [],
        widgetBorderColor = null,
        widgetBorderWidth = null,
        widgetCount = null,
        widgetRadius = null,
        imageSource = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var images = <Widget>[];
    var widgets = <Widget>[];
    var providersImages = <Widget>[];
    int _size = children.length > 0 ? widgetCount! : imageCount!;
    if (imageList.isNotEmpty) {
      images.add(circularImage(imageList[0], 0, images.length));
    } else if (children.isNotEmpty) {
      widgets.add(circularWidget(children[0]));
    } else if (providers.isNotEmpty) {
      providersImages.add(circularProviders(providers[0]));
    }

    if (imageList.length > 1) {
      if (imageList.length < _size) {
        _size = imageList.length;
      }
      images.addAll(imageList
          .sublist(1, _size)
          .asMap()
          .map((index, image) => MapEntry(
                index,
                Positioned(
                  right: 0.8 * imageRadius! * (index + 1.0),
                  child: circularImage(image, index + 1, images.length),
                ),
              ))
          .values
          .toList());
    }
    if (children.length > 1) {
      if (children.length < _size) {
        _size = children.length;
      }
      widgets.addAll(children
          .sublist(1, _size)
          .asMap()
          .map((index, widget) => MapEntry(
                index,
                Positioned(
                  right: 0.8 * widgetRadius! * (index + 1.0),
                  child: circularWidget(widget),
                ),
              ))
          .values
          .toList());
    }
    if (providers.length > 1) {
      if (providers.length < _size) {
        _size = providers.length;
      }
      providersImages.addAll(providers
          .sublist(1, _size)
          .asMap()
          .map((index, data) => MapEntry(
                index,
                Positioned(
                  right: 0.8 * imageRadius! * (index + 1.0),
                  child: circularProviders(data),
                ),
              ))
          .values
          .toList());
    }
    int _renderedImageSize = images.length > 0
        ? images.length
        : children.length > 0
            ? children.length
            : providersImages.length;
    return Container(
      child: Row(
        children: <Widget>[
          images.isNotEmpty || widgets.isNotEmpty || providersImages.isNotEmpty
              ? Stack(
                  clipBehavior: Clip.none,
                  textDirection: TextDirection.rtl,
                  children: children.length > 0
                      ? widgets
                      : providers.length > 0
                          ? providersImages
                          : images,
                )
              : SizedBox(),
          if (counterType == CounterType.Separate)
            Container(
              margin: EdgeInsets.only(left: 5),
              child: showTotalCount && totalCount - _renderedImageSize > 0
                  ? Container(
                      constraints: BoxConstraints(minWidth: imageRadius!),
                      padding: EdgeInsets.all(3),
                      height: imageRadius,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(imageRadius!),
                          border: Border.all(
                              color: imageBorderColor!,
                              width: imageBorderWidth!),
                          color: backgroundColor),
                      child: Center(
                        child: Text(
                          (totalCount - images.length).toString(),
                          textAlign: TextAlign.center,
                          style: extraCountTextStyle,
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
        ],
      ),
    );
  }

  circularWidget(Widget widget) {
    return Container(
      height: widgetRadius,
      width: widgetRadius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(
          color: widgetBorderColor!,
          width: widgetBorderWidth!,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widgetRadius!),
        child: widget,
      ),
    );
  }

  Widget circularImage(String imageUrl, int index, int imageLength) {
    return Container(
      height: imageRadius,
      width: imageRadius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: imageBorderWidth!,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          image: DecorationImage(
            colorFilter: counterType == CounterType.OnImage
                ? index == 0
                    ? ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.multiply,
                      )
                    : null
                : null,
            image: imageProvider(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
        child: counterType == CounterType.OnImage
            ? index == 0
                ? Text(
                    '+${totalCount - (imageCount ?? 0)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : null
            : null,
      ),
    );
  }

  Widget circularProviders(ImageProvider imageProvider) {
    return Container(
      height: imageRadius,
      width: imageRadius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: imageBorderWidth!,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  imageProvider(imageUrl) {
    if (this.imageSource == ImageSource.Asset) {
      return AssetImage(imageUrl);
    } else if (this.imageSource == ImageSource.File) {
      return FileImage(imageUrl);
    }
    return NetworkImage(imageUrl);
  }
}

enum ImageSource { Asset, Network, File }
enum CounterType { OnImage, Separate }
