# GPStorageKit

`Copyright (c) 2023, Greg PFISTER. MIT License`

A collection of storage tools for SwiftUI apps.

## About

This is a collection of storage tools for SwiftUI apps. It provides:
- memory and persistent cache ([documentation](./Docs/CACHE.md))
- user defaults ([documentation](./Docs/USER_DEFAULTS.md))
- keychain ([documentation](./Docs/KEYCHAIN.md))

They are all packaged as property wrappers, designed to be used in views 
(similar to `@State`) or view models (similar to `@Published`). Each storage entry 
is defined as object keys (similar to `@Environment`), reducing the risk of bugs
when misspelling the storage entry key.

## Getting started

First, add the Swift package to your Xcode project (File -> Add Packages...):
`https://github.com/gpfister/gp-swift-storage-kit`.

Then, add the library `GPStorageKit` to your target dependencies.

Finally, import `GPStorageKit` in your source files:

```swift
import GPStorageKit
```

## Example

An example iOS app `gp-swift-storage-kit-test` can be found in 
[here](./Examples/gp-swift-storage-kit-test).

## Contributions

Contributions are welcome, please refer to these 
[contributions guidelines](./CONTRIBUTING.md).

## License

Provided under the [MIT License](./LICENSE.md).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
