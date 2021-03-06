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
[https://github.com/meeuw/mkgmaps-github-action](https://github.com/meeuw/mkgmaps-github-action)

The mkgmaps-github-action is executed by a workflow on a daily timer:
[.github/workflows/update-github-action.yml](.github/workflows/update-github-action.yml)

All configuration settings for generating the map are included in this repository:

| Configuration | Description |
| ------------- | ----------- |
| [regions.json](regions.json) | Input parameters for downloading the map (included countries) |
| [benelux.poly](benelux.poly) | Bounding polygon of the calculated areas |
| [10010.txt](10010.txt) | Typ file |
| [osm_bnl.args](osm_bnl.args) | mkgmap arguments |
| [/Styles/Openfietsmap full](/Styles/Openfietsmap%20full) | Full style |
