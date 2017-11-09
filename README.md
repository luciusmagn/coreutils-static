# coreutils-static

Because we all need the most static coreutils we can get in this world.

## Getting
Download from the Releases section or run `./build.sh`.

Note that you really can't have truly static binaries on Darwin or
Windows machines, because there are no static libraries that can be used.

On Linux, we use musl instead of glibc to avoid `dlopen()`.
## What's the point of this?
I can run coreutils anywhere
