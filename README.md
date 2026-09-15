# Clover

Clover is the rich-text editing component used by Clover for iOS. It produces Trilium-compatible HTML and is published separately so recipients of the Clover binary can obtain the source code for the MPL-covered component and Clover's modifications.

## Origin and modifications

Parts of Clover are derived from [Trinote](https://github.com/StephenArg/Trinote) at commit `64249fc1`. The imported files, bundled editor assets, and Clover modifications are documented in [NOTICE.md](NOTICE.md). Reproducible patches are available in [`patches/`](patches/).

## License

Clover is distributed under the [Mozilla Public License 2.0](LICENSE). MPL-covered source files and modifications in this repository remain available under MPL-2.0. Third-party assets retain their respective licenses as described in [NOTICE.md](NOTICE.md).

## Requirements

- Swift 5.9+
- iOS 17+
- Xcode 15+

## Swift Package Manager

Add this repository as a Swift package and select its library product.
