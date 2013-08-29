## OBJCLucene

OBJCLucene is an Objective-C wrapper for CLucene.  It's meant to be lightweight and leverage CLucene as much as possible.  It brings a bit more cocoa-isms to the API while trying to keep the Lucene structure.

Currently what's implemented is the bare minimum. Ideally overtime this will expand to include more API's and features of CLucene.

It's only been tested and compiled with the iOS 7 SDK.  It should build just fine for OS X by just changing the target.

To compile, run the "OBJCLucene" target, and it will build a universal static library, along with copying the headers to the source/build directory. On your application you'll need to add "-lstdc++" to "Other Linker Flags". 