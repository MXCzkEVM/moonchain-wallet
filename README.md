# DataDash Wallet

DataDash wallet using an ERC-20 smart contract.

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

This library includes DataDash wallet's UI(User Interface) and business logic. The basic components and images, fonts, colors come from defination of designer's Figma. The logic part is to call the related APIs.

The repository: https://github.com/MXCzkEVM/mxc-shared-flutter