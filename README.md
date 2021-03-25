# FlexibleView



![demo](./Images/demo.png)

## Usage

```swift
let flexView = FlexibleView()
flexView.horizentalAlignment = .center
flexView.horizontalSpacing = .fixed(8)
flexView.verticalSpacing = .fixed(8)
flexView.contentInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
tags.forEach {
	flexView.addFlexibleItem(TagLabel(tagName: $0))
}
```



## License

Pretty is released under the MIT license. See LICENSE for details.