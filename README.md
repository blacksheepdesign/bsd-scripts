# Blacksheepdesign useful scripts

## Installation
Run the following command to install (MacOS only)
```
curl -s https://raw.githubusercontent.com/blacksheepdesign/bsd-scripts/master/install.sh | bash -s
```
You can rerun this command to updgrade at any time.

## Copy site
This command creates a directory with the `site-slug` argument and moves a production site & database into your local environment.
```
bsd copy-site [production-domain] [site-slug]
```
