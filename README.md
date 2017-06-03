# AHFuture

[![CI Status](http://img.shields.io/travis/AlexHmelevskiAG/AHFuture.svg?style=flat)](https://travis-ci.org/AlexHmelevskiAG/AHFuture)
[![Version](https://img.shields.io/cocoapods/v/AHFuture.svg?style=flat)](http://cocoapods.org/pods/AHFuture)
[![License](https://img.shields.io/cocoapods/l/AHFuture.svg?style=flat)](http://cocoapods.org/pods/AHFuture)
[![Platform](https://img.shields.io/cocoapods/p/AHFuture.svg?style=flat)](http://cocoapods.org/pods/AHFuture)

AHFuture is a concepts of asynchronous api using idea of futures.

AHFuture  implements proven functional concepts in Swift to provide a powerful alternative to completion blocks and support typesafe error handling in asynchronous code.


## Example
We write a lot of asynchronous code. Whether we're waiting for something to come in from the network or want to perform an expensive calculation off the main thread and then update the UI, we often do the 'fire and callback' dance. Here's a typical snippet of asynchronous code:

```swift
User.logIn(username, password) { user, error in
    if !error {
        Posts.fetchPosts(user, success: { posts in
            // do something with the user's posts
        }, failure: handleError)
    } else {
        handleError(error) // handeError is a custom function to handle errors
    }
}
```

Now let's see what BrightFutures can do for you:

```swift
User.logIn(username, password).flatMap { user in
    Posts.fetchPosts(user)
}.onSuccess { posts in
    // do something with the user's posts
}.onFailure { error in
    // either logging in or fetching posts failed
}.execute()
```

## Supported operations: 
 - [map](#map)
 - [flatMap](#`flatMap`)
 - [filter](#filter)
 - [retry](#retry)
 - [recover](#recover)
 - [run/observe](#run/observe)

### `map`
If success will transfrom `User` response to `UserViewModel` that can be used in success block
```swift
User.logIn(username, password).map { UserViewModel.init }
.onSuccess { viewModel in
    // do something with viewModel
}.onFailure { error in
    // either logging in or fetching posts failed
}.execute()
```

### `flatMap`

If logIn succeed the response will be tranfromed to another AHFuture and the success block will contain result from the second AHFuture
```swift
User.logIn(username, password).flatMap { Posts.fetchPosts }
.onSuccess { posts in
    // do something with the user's posts
}.onFailure { error in
    // either logging in or fetching posts failed
}.execute()
```

### `filter`
Will execute completion if predicate is true. 
```swift
User.logIn(username, password).flatMap { Posts.fetchPosts }
			      .filter { PostFilter.isTodaysPost }
.onSuccess { posts in
    // do something with the user's posts
}.onFailure { error in
    // either logging in or fetching posts failed
}.execute()
```
### `retry`
Retry operator will try to execute AHFuture if there is an error. The parametr shows the number of attempts
```swift
User.logIn(username, password).flatMap { Posts.fetchPosts }
			      .retry(5)
.onSuccess { posts in
    // do something with the user's posts
}.onFailure { error in
    // either logging in or fetching posts failed
}.execute()
```

### `recover`
Recover operator helps transform error to a placeholder object.
```swift
User.logIn(username, password).flatMap { Posts.fetchPosts }
			      .retry(5)
                              .recover {ErrorHandler.transformToPlaceholderModel}
.onSuccess { posts in
    // do something with the user's posts
}.onFailure { error in
    // either logging in or fetching posts failed
}.execute()
```

### `run/observe`
Sometimes we need to run our work on a particular thread and observe on another. For this purposes there is a `run` operator

```swift
Calculator.primeNumber(number)
.run(on: myGlobalQueue)
.observe(on: .main)
.onSuccess { posts in
    // do something with the user's posts
}.onFailure { error in
    // either logging in or fetching posts failed
}.execute()
```


## Installation

AHFuture is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AHFuture"
```

## TODO
- add timeout operator
- add synchronize/concat/zip operators


## Author

Alex Hmelevski, alexei.hmelevski@gmail.com

## License

AHFuture is available under the MIT license. See the LICENSE file for more info.

