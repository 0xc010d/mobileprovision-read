How to easily build it
=====================

Just run the command below in your terminal:

    curl https://raw.github.com/0xc010d/mobileprovision-read/master/main.m | gcc -framework Foundation -framework Security -o /usr/local/bin/mobileprovision-read -x objective-c -

This command would download the source, compile it and put resulting binary to `/usr/local/bin/mobileprovision-read`

Run `mobileprovision-read` without any parameter to get short help.

