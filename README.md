IMPORTANT
=====================

That version is quite old and is outdated.
Please use [that gist](https://gist.github.com/sharpland/5134242) instead. Believe me, it's much better, it also allows you to use key-path to retrieve profile properties.

You might use the command below to build the app. It would download the source, compile it and put the resulting binary to /usr/local/bin/mobileprovision-read

    curl https://raw.github.com/gist/5134242 | gcc -framework Foundation -framework Security -o /usr/local/bin/mobileprovision-read -x objective-c -

