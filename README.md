# Free OSM B(enelux)NL cycling map for Garmin GPS

## Download

The generated map can be downloaded from the releases of this project.

## Used resources

This repository hosts a GitHub action which generate a Garmin GPS map from:

- https://github.com/ligfietser/mkgmap-style-sheets
- http://www.viewfinderpanoramas.org/dem3/
- http://develop.freizeitkarte-osm.de/
- http://download.geonames.org/
- https://download.geofabrik.de/
- http://osm.thkukuk.de/data

It uses the following utilities:

- https://www.mkgmap.org.uk/download/splitter.html
- https://www.mkgmap.org.uk/download/mkgmap.html
- https://github.com/openstreetmap/osmosis

## How does it work?

The (generated) GitHub action workflow can be found here:
[.github/workflows/mkgmap.yml](.github/workflows/mkgmap.yml)

It is my intend to use versioned URLs (not "-latest") so files can by properly cached.

This was a bit cumbersome to manage so I created a script to generated the workflow files:
[https://github.com/meeuw/mkgmap-github-action](https://github.com/meeuw/mkgmap-github-action)

The mkgmap-github-action is executed by a workflow on a daily timer:
[.github/workflows/update-github-action.yml](.github/workflows/update-github-action.yml)

All configuration settings for generating the map are included in this repository:

| Configuration | Description |
| ------------- | ----------- |
| [regions.json](regions.json) | Input parameters for downloading the map (included countries) |
| [resources/benelux.poly](resources/benelux.poly) | Bounding polygon of the calculated areas |
| [typ/Openfietsmap lite/20011.txt](typ/Openfietsmap%20lite/20011.txt) | Typ file |
| [styles/Openfietsmap full/mkgmap.args](styles/Openfietsmap%20full/mkgmap.args) | mkgmap arguments |
| [styles/Openfietsmap full](/styles/Openfietsmap%20full) | Full style |
