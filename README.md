# WorldExplorer

This app enables you to check the details for the countries in all the five continents.

##Design
This is my first OS X app, so I used a Storyboard in order to design the UI quickly and learn what components `AppKit` makes available to developers. The Storyboard has a `NSSplitViewController` as the Root View Controller for the main window. 

The top controller (`RegionController`) is for picking the regions, and currently is built using a stack view and 5 buttons, enabling the user to chose what continent to explore. This should be built with a `NSCollectionView` in case we might want to add more options or a better UI-UX, but right now it sounded reasonable to build the UI this way and optimize later.

The bottom controller (`CountryController`) contains a split view with three panes: one for the filter view (`FilterHandlerView`), another with the results (`CountryListView`) and the detail view (`CountryDetailView`).

The `FilterHandlerView` is built simply with `NSTextField` and is responsible for observing the changes in these text field values and notifing observers via the `FilterHandlerProtocol`

The `CountryListView` is built with a `NSCollectionView` and displays the countries for the selected region and filters. The collection view item for the country is the `CountryItem` class. This view uses `CollectionViewDataSource` in order to abstract away complexity. This will be discussed later.

Finally the `CountryDetailView` is built with three `NSTextField` and just sets the value for the selected country.

##Logic
The `CountryController` is the class responsible for:

1. React to the user region selection (via the `RegionPickerObserver`) 
2. React to the user filtering results (via the `FilterHandlerProtocol`)
3. React to the user clicking on a country to view it's details (via the `.countrySelectHandler` property of the `CountryListView`)

Which is not ideal since it's a `NSViewController` subclass, but in a fairly simple app it looks like the right tradeoff.

##Project structure
The files neccesary for the OS X app are in the `Controllers` and `Cells` folders. 

The files belong to the model layer are in `WorldExplorerKit` and these should be able to be used for any Swift based application. 

The files in the `BlurFoundation` are some basic classes and types I use in most of my projects to abstract away REST API communication (`Drosky` and `Endpoint`), JSON parsing (`Parse`), asynchrony (`Deferred`) and error handling (`Result`). 

`CollectionViewDataSource` is a port of a class that I normally use with `UICollectionView`, but I could port fairly easily to `NSCollectionView`. It's used to abstract collection views that load data from the network (that's why it has a `.state` property) and bind a `Model` to a `ReusableCell`, to reduce boilerplate code when working with collection views.