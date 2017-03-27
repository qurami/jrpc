# jrpc

[![Version](https://img.shields.io/cocoapods/v/jrpc.svg?style=flat)](http://cocoapods.org/pods/jrpc)
[![License](https://img.shields.io/cocoapods/l/jrpc.svg?style=flat)](http://cocoapods.org/pods/jrpc)
[![Platform](https://img.shields.io/cocoapods/p/jrpc.svg?style=flat)](http://cocoapods.org/pods/jrpc)

`jrpc` is a simple [JSONRPC 2.0](http://www.jsonrpc.org/specification) client written in Swift. 
It offers support structure to perform JSONRPC requests and to process responses.

## Status

This pod is in development and therefore it is still in its beta release, however everything that 
gets into master is toroughly tested and reviewed, so it should work for what it does.
If you have suggestions, improvements, or find bugs, feel free to fork and pull request!

### Known Issues
- The ID of a JSONRPC request/response is always treated as a string, the coice has been made to simplify the API and a better decision has to be made about this.
- The client handles one request at time, I'm still not sure I want to change this behaviour, but it might be handy.
- The client doesn't offer support for any kind of http authentication right now, but it could be easily solved by injecting a custom url session.
- This readme lacks of examples and better descriptions, and they will come soon with the rest as well in the near future.
- Automated tests aren't running on the CI, I'm making sure they pass locally however.


## Installation

jrpc is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "jrpc", '~>0.1.0-beta'
```

## Author

Marco Musella

## License

jrpc is available under the MIT license. See the LICENSE file for more info.
