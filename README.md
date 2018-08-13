

# FMImageView

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

**FMImageView** is a slideshow and image viewer with zoom and interactive dismissal transitions.

<p align="center">
  <img height="400" src="resources/FMImageView.gif" />
</p>

## Features
- [x] Support image slideshow with pagination
- [x] Support double tapping to zoom in/out
- [x] Support remote image loader with caching
- [x] Support the interactive transition animations
- [x] Support custom bottom view
- [x] Support custom configuration

## Requirements
- iOS 9.0+

## Installation

Insert the following line in your Cartfile:
```
git "git@github.com:tribalmedia/FMImageView.git"
```
and run `carthage update FMImageView --platform ios --no-use-binaries`


## Usage
#### Create a configuration object
```swift
var config = Config(initImageView: UIImageView, initIndex: Int)
```
For details, see [Configuration](#configuration)

#### Create a datasource object
```swift
var datasource = FMImageDataSource(imageURLs: [URL])
```
or 

```swift
var datasource = FMImageDataSource(images: [UIImage])
```

### Controller
```swift
let fmImageVC = FMImageSlideViewController(datasource: datasource, config: config)

fmImageVC.view.frame = UIScreen.main.bounds

self.present(fmImageVC, animated: true)
```

### Callback
- Implement callback to handle location of images  
```swift
let fmImageVC = FMImageSlideViewController(datasource: datasource, config: config)
fmImageVC.didMoveToViewControllerHandler = { index in
    // Mark code get imageView by index

    fmImageVC.setNewDestinatonFrame(imageView: UIImageView)
}
```

## Configuration
#### The configuration supports the following parameter:
- [`bottomView`](#ref-bottom-view)

#### Reference
- <a name="ref-bottom-view"></a>`bottomView`   
It will always show the bottom
Type: `HorizontalStackView`  
Default: `nil`
Default height: `40.0`

## Apps using FMImageView
<a href="https://funmee.jp"><img src="resources/funmee.png" width="100"></a>

## Author
Made by Tribal Media House with ❤️

## License
FMImageView is released under the MIT license. See LICENSE for details.
