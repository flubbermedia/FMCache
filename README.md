Purpose
-------
**FMCache** extends the handling of memory caching provided by Apple's NSCache by adding support for disk caching.
**FMImageLoader** leverages on the caching provided by FMCache to easily download, save and cache images.
**FMImageView** uses FMImageLoader callbacks to nicely fade in images, once that they have been downloaded.

***NOTE**: the supported build target is iOS 5.1 (Xcode 4.4)*

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

FMCache
-------
Add and object to the FMCache is easy, you only need to be sure it is `NSCoding` compliant (like a `UIImage`) and set it with a key.

    [FMCache setObject:yourObject forKey:yourStringKey];

To retrieve it back... just ask it.

    id yourObject = [FMCache objectForKey:yourStringKey];

This is the basic use for the FMCache and it automatically manage the disk and memory cache.
If you want  to use it in a more advanced way you can choose to use the memory or not (the default is YES)

    [FMCache setObject:yourObjcet forKey:yourStringKey useMemory:NO];

You can also define the `expiratioDate` or combine it with the `useMemory`

    //use the default memory cache and set the expirationDate
    [FMCache setObject:yourObjcet forKey:yourStringKey expirationDate:aDate useMemory:NO];
    
    //combined use
    [FMCache setObject:yourObjcet forKey:yourStringKey expirationDate:aDate useMemory:NO];

Credits
-------
FMFacebookPanel was created by [Maurizio Cremaschi](http://cremaschi.me) and [Andrea Ottolina](http://andreaottolina.com) for [Flubber Media Ltd](http://flubbermedia.com).