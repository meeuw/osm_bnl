
FROM alpine:3.22.0 AS downloader
RUN apk add wget

FROM alpine:3.22.0 AS extractor
RUN apk add unzip

FROM alpine:3.22.0 AS openjdk17
RUN apk add openjdk17

FROM downloader AS download-osmosis
RUN wget -O osmosis-0.49.2.zip https://github.com/openstreetmap/osmosis/releases/download/0.49.2/osmosis-0.49.2.zip
#SAVE ARTIFACT osmosis-0.49.2.zip

FROM downloader AS download-geofabrik-belgium
RUN wget -O belgium-250712.osm.pbf https://download.geofabrik.de/europe/belgium-250712.osm.pbf
#SAVE ARTIFACT belgium-250712.osm.pbf

FROM downloader AS download-geofabrik-netherlands
RUN wget -O netherlands-250712.osm.pbf https://download.geofabrik.de/europe/netherlands-250712.osm.pbf
#SAVE ARTIFACT netherlands-250712.osm.pbf

FROM downloader AS download-geofabrik-luxembourg
RUN wget -O luxembourg-250712.osm.pbf https://download.geofabrik.de/europe/luxembourg-250712.osm.pbf
#SAVE ARTIFACT luxembourg-250712.osm.pbf

FROM downloader AS download-bounds
RUN wget -O bounds-20250711.zip http://osm.thkukuk.de/data/bounds-20250711.zip
#SAVE ARTIFACT bounds-20250711.zip

FROM downloader AS download-sea
RUN wget -O sea-20250713001500.zip http://osm.thkukuk.de/data/sea-20250713001500.zip
#SAVE ARTIFACT sea-20250713001500.zip

FROM downloader AS download-mkgmap
RUN wget -O mkgmap-r4923.zip https://www.mkgmap.org.uk/download/mkgmap-r4923.zip
#SAVE ARTIFACT mkgmap-r4923.zip

FROM downloader AS download-splitter
RUN wget -O splitter-r654.zip https://www.mkgmap.org.uk/download/splitter-r654.zip
#SAVE ARTIFACT splitter-r654.zip

FROM downloader AS download-m31
RUN wget -O 114a217-611d29fea4a00.zip https://www.viewfinderpanoramas.org/dem3/M31.zip
#SAVE ARTIFACT 114a217-611d29fea4a00.zip

FROM downloader AS download-m32
RUN wget -O 1bb1c19-611e21623f400.zip https://www.viewfinderpanoramas.org/dem3/M32.zip
#SAVE ARTIFACT 1bb1c19-611e21623f400.zip

FROM downloader AS download-n31
RUN wget -O 1f5128-611e1d8bf6680.zip https://www.viewfinderpanoramas.org/dem3/N31.zip
#SAVE ARTIFACT 1f5128-611e1d8bf6680.zip

FROM downloader AS download-n32
RUN wget -O a3ea25-611e1c9ba2f80.zip https://www.viewfinderpanoramas.org/dem3/N32.zip
#SAVE ARTIFACT a3ea25-611e1c9ba2f80.zip

FROM downloader AS download-hoehendaten-freizeitkarte-bel
RUN wget -O 5c4402-62ed305a14a16.zip http://develop.freizeitkarte-osm.de/ele_20_100_500/Hoehendaten_Freizeitkarte_BEL.osm.pbf
#SAVE ARTIFACT 5c4402-62ed305a14a16.zip

FROM downloader AS download-hoehendaten-freizeitkarte-nld
RUN wget -O 3d557b-62ed30b3b735d.zip http://develop.freizeitkarte-osm.de/ele_20_100_500/Hoehendaten_Freizeitkarte_NLD.osm.pbf
#SAVE ARTIFACT 3d557b-62ed30b3b735d.zip

FROM downloader AS download-hoehendaten-freizeitkarte-lux
RUN wget -O 17dc23-62ed30c666547.zip http://develop.freizeitkarte-osm.de/ele_20_100_500/Hoehendaten_Freizeitkarte_LUX.osm.pbf
#SAVE ARTIFACT 17dc23-62ed30c666547.zip

FROM downloader AS download-cities15000
RUN wget -O 2d0525-639c5e998bf12.zip http://download.geonames.org/export/dump/cities15000.zip
#SAVE ARTIFACT 2d0525-639c5e998bf12.zip

FROM extractor AS extract-osmosis
COPY --from=download-osmosis osmosis-0.49.2.zip ./
RUN unzip -d osmosis osmosis-0.49.2.zip
#SAVE ARTIFACT osmosis/*

FROM extractor AS extract-splitter
COPY --from=download-splitter splitter-r654.zip ./
RUN unzip -d splitter splitter-r654.zip
#SAVE ARTIFACT splitter/*

FROM extractor AS extract-cities15000
COPY --from=download-cities15000 2d0525-639c5e998bf12.zip ./
RUN unzip -d cities15000 2d0525-639c5e998bf12.zip
#SAVE ARTIFACT cities15000/*

FROM extractor AS extract-mkgmap
COPY --from=download-mkgmap mkgmap-r4923.zip ./
RUN unzip -d mkgmap mkgmap-r4923.zip
#SAVE ARTIFACT mkgmap/*

FROM extractor AS extract-dem-files
COPY --from=download-m31 114a217-611d29fea4a00.zip ./
COPY --from=download-m32 1bb1c19-611e21623f400.zip ./
COPY --from=download-n31 1f5128-611e1d8bf6680.zip ./
COPY --from=download-n32 a3ea25-611e1c9ba2f80.zip ./
RUN sh -c 'for Z in 114a217-611d29fea4a00.zip 1bb1c19-611e21623f400.zip 1f5128-611e1d8bf6680.zip a3ea25-611e1c9ba2f80.zip ; do unzip -d map_with_dem_files $Z ; done'
#SAVE ARTIFACT map_with_dem_files/???/*.hgt

FROM openjdk17 AS merge-extracts
COPY --from=download-geofabrik-belgium belgium-*.osm.pbf ./
COPY --from=download-geofabrik-luxembourg luxembourg-*.osm.pbf ./
COPY --from=download-geofabrik-netherlands netherlands-*.osm.pbf ./
COPY --from=download-hoehendaten-freizeitkarte-bel *.zip ./bel.zip
COPY --from=download-hoehendaten-freizeitkarte-nld *.zip ./nld.zip
COPY --from=download-hoehendaten-freizeitkarte-lux *.zip ./lux.zip
COPY --from=extract-osmosis osmosis/* osmosis/
RUN sh -c "osmosis/bin/osmosis   --rbf belgium-*.osm.pbf   --rbf netherlands-*.osm.pbf   --rbf luxembourg-*.osm.pbf   --rbf bel.zip   --rbf nld.zip   --rbf lux.zip   --merge   --merge   --merge   --merge   --merge   --wb merged.osm.pbf"
#SAVE ARTIFACT merged.osm.pbf

FROM openjdk17 AS splitter
COPY --from=extract-splitter /splitter/* ./splitter/
COPY --from=merge-extracts /merged.osm.pbf ./
COPY --from=extract-cities15000 /cities15000/cities15000.txt ./
COPY resources/benelux.poly resources/
RUN java \
  -Xmx4096m \
  -jar splitter/splitter.jar \
  --output=pbf \
  --output-dir=splitted \
  --max-nodes=1400000 \
  --mapid=10010001 \
  --geonames-file=cities15000.txt \
  --polygon-file=resources/benelux.poly \
  merged.osm.pbf
#SAVE ARTIFACT splitted/*

FROM openjdk17 AS mkgmap
COPY --from=download-sea sea-*.zip sea.zip
COPY --from=download-bounds bounds-*.zip bounds.zip
COPY --from=extract-mkgmap mkgmap/* mkgmap/
COPY --from=extract-dem-files *.hgt map_with_dem_files/
COPY styles/ styles/
COPY --from=splitter /splitted/* splitted/
COPY ["typ/Openfietsmap lite/20011.txt", "typ/Openfietsmap lite/20011.txt"]
RUN java \
   -Xms4096m \
   -Xmx4096m \
   -jar mkgmap/mkgmap.jar \
   -c "styles/Openfietsmap full/mkgmap.args" \
   -c splitted/template.args \
   "typ/Openfietsmap lite/20011.txt"
#SAVE ARTIFACT gmapsupp.img
