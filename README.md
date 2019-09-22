# ShopifyIOS

There's haptic feedback for most of the actions(I always wanted to try implementing it and it was surprisingly easy).

Other than that, pretty standard implementation of a CollectionView with some networking. If I were to add stuff to it, I'd probably add a 
error alerts for if things failed to download, and perhaps a user flow if something didn't load in.

# Third Party Dependencies

This project uses Cartography to condense the layout code. I've found in the past, that while Autolayout is definitely the way to implement UI, both storyboards/XIBs and programatically creating constraints are either unwieldy or unneccessaryily introduce complexity. Cartography
is a library which condenses the Constraint API and makes it much easier to write, and in my opinion, read. 
