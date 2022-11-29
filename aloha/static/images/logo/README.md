Generally, we prefer to use SVG assets when possible.

However, many websites where you might want to use a Aloha logo do not
support SVG files. If you need a Aloha logo asset in a different
format (E.g. a 512px height PNG), you can generate that from one of
the `.svg` files in this directory.

On Linux, you can generate a PNG of a given height using the following:

```
rsvg-convert -h 512 static/images/logo/aloha-org-logo.svg -o /tmp/aloha-org-logo-512.png
```
