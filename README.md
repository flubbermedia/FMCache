Purpose
-------
**FMCache** extends the handling of memory caching provided by Apple's NSCache by adding support for disk caching.

**FMImageLoader** leverages on the caching provided by FMCache to easily download, save and cache images.

**FMImageView** uses FMImageLoader callbacks to nicely fade in images, once that they have been downloaded.

**NOTE: the supported build target is iOS 5.1 (Xcode 4.4)*

Installation
------------
To use the FMImageView in your app, just drag the FMCache, FMImageLoader and FMImageView class files into your project.
Instead, if you want to use only the FMCache, drag only the two FMCache class files into the project.

Usage
-----
(see sample Xcode projects `/Demo-RockSongs` and `/Demo-FindImages`)

FMImageView
-----------
Use the FMImageView exactly as if it you would use an UIImageView.
In addition to that you can use the property `imageURL` to load asynchronously the remote image.

    imageView.imageURL = [NSURL URLWithString:@"http://website.com/coolimage.png"];

Otherwise you can use the `setImageURL:completion` method to be notified when the image loading is finished

    [imageView setImageURL:url
                completion:^{
                    //your code here
                }];

FMImageLoader
-------------
This class handles all the image download connections and it's the core behind the FMImageView.
It has only a simple method `loadImageURL:completion` that create the connection and add it to the queue notifying the completion within a block.
FMImageLoader also use the FMCache to make the image request as faster as possible.

**NOTE: you don not need to use it directly if you just want to implement the FMImageView in your project.*

FMCache
-------
Add and object to the FMCache is easy, you only need to be sure it is `NSCoding` compliant (like a `UIImage`) and set it with a key.

    [FMCache setObject:yourObject forKey:yourStringKey];

To retrieve it back... just ask it.

    id yourObject = [FMCache objectForKey:yourStringKey];

This is the basic use for the FMCache and it automatically manage the disk and memory cache.
If you want  to use it in a more advanced way you can choose to use the memory or not (the default is YES).

    [FMCache setObject:yourObjcet forKey:yourStringKey useMemory:NO];

You can also define the `expiratioDate` or combine it with the `useMemory`.

    //use the default memory cache and set the expirationDate
    [FMCache setObject:yourObjcet forKey:yourStringKey expirationDate:aDate];
    
    //combined use
    [FMCache setObject:yourObjcet forKey:yourStringKey expirationDate:aDate useMemory:NO];

You can ask if an object is cached

    //return a bool that is true if there's an object cached with that key
    //this method check both the memory and disk cache
    [FMCache hasObjectForKey:aKey];

    //this method check only the disk cache
    [FMCache hasObjectOnDiskForKey:aKey];

    //this method check only the memory cache
    [FMCache hasObjectInMemoryForKey:aKey];

To clean the cache you remove all the objects in one time or just remove one with a specific key.
Keep in mind that you don't need to clean the old objects in the cache, it automatically do once the application is launched.

    //delete a specific object from the cache
    [FMCache removeObjectForKey:aKey];

    //delete all the cached objects
    [FMCache removeAllObjects];

Credits
-------
FMFacebookPanel was created by [Maurizio Cremaschi](http://www.linkedin.com/in/cremaschi) and [Andrea Ottolina](http://www.linkedin.com/in/andreaottolina) for [Flubber Media Ltd](http://flubbermedia.com).