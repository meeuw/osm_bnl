#!/bin/bash
set -xe
mkdir -p names

[ -f "$CACHE/osmosis-0.49.2.zip" ] || wcurl -o $CACHE/osmosis-0.49.2.zip https://github.com/openstreetmap/osmosis/releases/download/0.49.2/osmosis-0.49.2.zip
echo osmosis-0.49.2.zip > names/osmosis
[ -f "$CACHE/belgium-260416.osm.pbf" ] || wcurl -o $CACHE/belgium-260416.osm.pbf https://download.geofabrik.de/europe/belgium-260416.osm.pbf
echo belgium-260416.osm.pbf > names/geofabrik-belgium
[ -f "$CACHE/netherlands-260416.osm.pbf" ] || wcurl -o $CACHE/netherlands-260416.osm.pbf https://download.geofabrik.de/europe/netherlands-260416.osm.pbf
echo netherlands-260416.osm.pbf > names/geofabrik-netherlands
[ -f "$CACHE/luxembourg-260416.osm.pbf" ] || wcurl -o $CACHE/luxembourg-260416.osm.pbf https://download.geofabrik.de/europe/luxembourg-260416.osm.pbf
echo luxembourg-260416.osm.pbf > names/geofabrik-luxembourg
[ -f "$CACHE/bounds-20260410.zip" ] || wcurl -o $CACHE/bounds-20260410.zip http://osm.thkukuk.de/data/bounds-20260410.zip
echo bounds-20260410.zip > names/bounds
[ -f "$CACHE/sea-20260414220000.zip" ] || wcurl -o $CACHE/sea-20260414220000.zip http://osm.thkukuk.de/data/sea-20260414220000.zip
echo sea-20260414220000.zip > names/sea
[ -f "$CACHE/mkgmap-r4924.zip" ] || wcurl -o $CACHE/mkgmap-r4924.zip https://www.mkgmap.org.uk/download/mkgmap-r4924.zip
echo mkgmap-r4924.zip > names/mkgmap
[ -f "$CACHE/splitter-r654.zip" ] || wcurl -o $CACHE/splitter-r654.zip https://www.mkgmap.org.uk/download/splitter-r654.zip
echo splitter-r654.zip > names/splitter
[ -f "$CACHE/114a217-611d29fea4a00.zip" ] || wcurl -o $CACHE/114a217-611d29fea4a00.zip https://www.viewfinderpanoramas.org/dem3/M31.zip
echo 114a217-611d29fea4a00.zip > names/M31
[ -f "$CACHE/1bb1c19-611e21623f400.zip" ] || wcurl -o $CACHE/1bb1c19-611e21623f400.zip https://www.viewfinderpanoramas.org/dem3/M32.zip
echo 1bb1c19-611e21623f400.zip > names/M32
[ -f "$CACHE/1f5128-611e1d8bf6680.zip" ] || wcurl -o $CACHE/1f5128-611e1d8bf6680.zip https://www.viewfinderpanoramas.org/dem3/N31.zip
echo 1f5128-611e1d8bf6680.zip > names/N31
[ -f "$CACHE/a3ea25-611e1c9ba2f80.zip" ] || wcurl -o $CACHE/a3ea25-611e1c9ba2f80.zip https://www.viewfinderpanoramas.org/dem3/N32.zip
echo a3ea25-611e1c9ba2f80.zip > names/N32
[ -f "$CACHE/5c4402-62ed305a14a16.zip" ] || wcurl -o $CACHE/5c4402-62ed305a14a16.zip http://develop.freizeitkarte-osm.de/ele_20_100_500/Hoehendaten_Freizeitkarte_BEL.osm.pbf
echo 5c4402-62ed305a14a16.zip > names/Hoehendaten_Freizeitkarte_BEL
[ -f "$CACHE/3d557b-62ed30b3b735d.zip" ] || wcurl -o $CACHE/3d557b-62ed30b3b735d.zip http://develop.freizeitkarte-osm.de/ele_20_100_500/Hoehendaten_Freizeitkarte_NLD.osm.pbf
echo 3d557b-62ed30b3b735d.zip > names/Hoehendaten_Freizeitkarte_NLD
[ -f "$CACHE/17dc23-62ed30c666547.zip" ] || wcurl -o $CACHE/17dc23-62ed30c666547.zip http://develop.freizeitkarte-osm.de/ele_20_100_500/Hoehendaten_Freizeitkarte_LUX.osm.pbf
echo 17dc23-62ed30c666547.zip > names/Hoehendaten_Freizeitkarte_LUX
[ -f "$CACHE/31b44b-64f9dea9a0977.zip" ] || wcurl -o $CACHE/31b44b-64f9dea9a0977.zip http://download.geonames.org/export/dump/cities15000.zip
echo 31b44b-64f9dea9a0977.zip > names/cities15000
MERGED=$(cat \
  $CACHE/$(< names/osmosis) \
  $CACHE/$(< names/geofabrik-belgium) \
  $CACHE/$(< names/geofabrik-netherlands) \
  $CACHE/$(< names/geofabrik-luxembourg) \
  $CACHE/$(< names/Hoehendaten_Freizeitkarte_BEL) \
  $CACHE/$(< names/Hoehendaten_Freizeitkarte_NLD) \
  $CACHE/$(< names/Hoehendaten_Freizeitkarte_LUX) \
  |md5sum|cut -c-32
).osm.pbf
unzip -d osmosis $CACHE/$(< names/osmosis)
[ -f "$CACHE/$MERGED" ] || scripts/osmosis.sh \
  $CACHE/$MERGED \
  $CACHE/$(< names/geofabrik-belgium) \
  $CACHE/$(< names/geofabrik-netherlands) \
  $CACHE/$(< names/geofabrik-luxembourg) \
  $CACHE/$(< names/Hoehendaten_Freizeitkarte_BEL) \
  $CACHE/$(< names/Hoehendaten_Freizeitkarte_NLD) \
  $CACHE/$(< names/Hoehendaten_Freizeitkarte_LUX) \
;
unzip -d splitter $CACHE/$(< names/splitter)
unzip $CACHE/$(< names/cities15000)
SPLITTED_DIR=$(cat \
  $CACHE/$(< names/splitter) \
  $CACHE/$(< names/cities15000) \
  resources/benelux.poly \
  $CACHE/$MERGED \
  |md5sum|cut -c-32
)
[ -d "$CACHE/$SPLITTED_DIR" ] || java \
  -Xmx4096m \
  -jar splitter/*/splitter.jar \
  --output=pbf \
  --output-dir=$CACHE/$SPLITTED_DIR \
  --max-nodes=1400000 \
  --mapid=10010001 \
  --geonames-file=cities15000.txt \
  --polygon-file=resources/benelux.poly \
  $CACHE/$MERGED
cp -r $CACHE/$SPLITTED_DIR splitted
ls splitted
unzip -d mkgmap $CACHE/$(< names/mkgmap)
for Z in \
   $(< names/M31) \
   $(< names/M32) \
   $(< names/N31) \
   $(< names/N32) \
; do
  unzip -d map_with_dem_files $CACHE/$Z
done
mv map_with_dem_files/???/*.hgt map_with_dem_files/
cp $CACHE/$(< names/sea) sea.zip
cp $CACHE/$(< names/bounds) bounds.zip
java   -Xms4096m   -Xmx4096m   -jar mkgmap/*/mkgmap.jar   -c "styles/Openfietsmap full/mkgmap.args"   -c splitted/template.args   "typ/Openfietsmap lite/20011.txt"
