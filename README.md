# Moonchain Wallet

Self custodial Moonchain wallet, Seamless interaction with MXC chains & EVM based chains, Enabling users to Send/Receive tokens, NFTs, and interact with Web3 DApps.

## Project Structure

According to our project, there everything is divided on three things: data, domain, presentation. 

In data we have everything related to working with data. HttpClients, Databases, Sockets. 
In data we have repositories - they should work with data-objects (httpclient / serialized data) inside, but expose logic on domain language.
For example, the repository method definition can look like this - Book getBook(int bookNumber). The method definition say to us that method will return book according to book number. There is no everything HTTP-related or Database-related in method signature. So according to method definition we can't say what data source will be used (rest api / protobuf* api / db). This give us an option to change implementation of  method, without changing code that actually uses this method. Now we are doing HTTP requests to get the book, tomorrow backend can say "Hey, now we use Protobuf api instead of http api", in a week we will store the books locally and we will change the method implementation again, but not the signature, so we don't need to change the methods which actually use this getBook method, we will need to only change data layer, not others domain or presentation layer.

In domain we write everything specific for our app on own domain language. Here we are not tied with backend. We define here entities - Book, Bookshelf, Author, we define here UseCases. UseCases is our business app logic. For example, we have an app that should be able to get books of some author and place the books on some shelf.  Use case will look like this:
```
BooksRepository _booksRepository;

moveAuthorBooks(String author) {
  final books = await _booksRepository.getBookByAuthor(author);
  final shelf = Shelf(name: author);
  _booksRepository.moveBooksToShelf(books, shelf)
}
```
Domain should not have anything from data layer. It should only contain business logic.  UseCase here don't know how repository will get the book. Ideally, the BooksRepository should be an interface without logic at all, if you are familiar with languages like Java or C#, but that's requiring writing more code, so we have compromise here (And somewhere we should have implementation of this repository, like ApiBooksRepository). 

And last but not least - presentation. 
In our current app presentation based on MVP pattern. We have model - our state, we have view - our widget and we have presenter - presenter. MVP pattern is very similar to MVC. We store every data related to widget in its state, we update/maintain the state via presenter and show the data in widget. This let us to split logic from ui. For example, this pattern helped me a lot in miner statistic page refactoring. The ui for all statistic page is very similar, so I created 1 widget, but I created multiple presenters to maintain different data.  In presenter we do UI logic, like "Change some button color", "change text to Loading when button is clicked". 

This let us to share whole features between our projects. For example, if we want to display BTC Mining data in MXC Controller, we are able to take use case from DD app. UseCase is domain logic, it should not depend on UI.  So we will take the use case (or even share between projects via Shared module) and will just write different UI for this use case (because web isn't mobile and they have different ui/ux problems, we can't reuse UI here).
And also, UseCases are feature-level, while presenters are widget-level. So 1 presenter should serve 1 widget (page).

## Shared Library

This library includes Moonchain wallet's UI(User Interface) and business logic. The basic components and images, fonts, colors come from defination of designer's Figma. The logic part is to call the related APIs.

The repository: https://github.com/MXCzkEVM/mxc-shared-flutter

## App Update

We can update our app automatically on android, not now support for iOS. With appcenter's distribute [API](https://openapi.appcenter.ms/#/distribute/releases_getLatestByPublicDistributionGroup), it requests the latest version to compare our app version. It will update automatically if the latest version number more than our app version's.

Note: 

Based on build number to compare to update, not using version number(like 1.0.0) to compare.

### Environment Variables Setup

1. Create assets/.env file with following content:

```sh
APPCENTER_SECRET_ANDROID=${APPCENTER_SECRET_ANDROID}
APPCENTER_DISTRIBUTION_GROUP_ID_ANDROID=${APPCENTER_DISTRIBUTION_GROUP_ID_ANDROID}
```

2. Go to android's `Build` page on appcenter, find a branch to set up above variables's value in `Environment variables` form.

Note:
About getting the distribute group id, refer to the above `How To Distribute A Latest Version`

### Distribute

We will release two differet versions depended on application store platform. One channel is product, another is google play. By different channels, to respectively submit release versions, especially google play vesion does not have updating automatically feature, since it has policy limitation for application update. Using the following commands:

```
flutter build apk --flavor product --release
flutter build appbundle --flavor googlePlay --release
```

When you want to debug on your local computer, suggest to create .vscode/launch.json file to run our app, not use a command:

```
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "moonchain-wallet",
            "request": "launch",
            "type": "dart",
            "args": [
                "--flavor",
                "product"
            ],
            "program": "lib/main.dart",
        },
    ]
}
```

#### How To Distribute A Latest Version

1. Need to build `release_china` branch with the latest build number on appcenter.

2. When finish the first step, go to `Distribute` menu's `Groups` submenu, and create a group for the public, it aims to everyone to access to this group. 

3. Go to this public group, and at this time you can get group id from settings. 

4. Click `New release` button, to select a latest version to distribute in `release_china` branch. After that, on the `RELEASES` column, you can see a new version on the list as you just added.

5. Launch our app, it will check the latest build number automatically to update for the first time on android.

There is alternative way to distribute a latest version.

1. On `Build` menu, select a latest build of `release_china` branch, click `Distribute` to show a dialog on the right of screen.

2. Click `Click to begin` to select the public group, and then click `Next` button to finish distribution process.

3. Once distributed, you can check a latest version as you released on the `RELEASES` column of the public group on the `Groups` submenu of `Distribute` menu.