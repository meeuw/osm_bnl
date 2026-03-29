#!/usr/bin/env python
import json
import textwrap

with open('downloads.json') as f:
    downloads = json.load(f)

with open('regions.json') as f:
    regions = json.load(f)

#        "steps": [
#            {
#                "name": "Check out repository code",
#                "uses": "actions/checkout@v3",
#            }
#        ] + [
action = {
    "name": "Generate OpenStreetMap Garmin maps",
    "runs": {
        "using": "composite",
        "steps": [
            {
                "id": name,
                "uses": "./.github/actions/cached-download",
                "with": {
                    "filename": download["filename"],
                    "url": download["url"]
                }
            } for name, download in downloads.items()
        ] + [
            {
                "uses": "actions/setup-java@v5",
                "with": {
                    "distribution": 'oracle',
                    "java-version": '17',
                }
            },
            {
                "name": "Extract osmosis",
                "shell": "bash",
                "run": "unzip -d osmosis ${{ steps.osmosis.outputs.filename }}",
            },
            {
                "name": "merge",
                "id": "merged",
                "shell": "bash",
                "run": (
                    'echo filename=$(cat '
                    '${{ steps.osmosis.outputs.filename }} '
                ) +
                "".join(f'${{{{ steps.geofabrik-{country}.outputs.filename }}}} ' for country in regions["countries"]) +
                "".join(f'${{{{ steps.Hoehendaten_Freizeitkarte_{hoehendaten}.outputs.filename }}}} ' for hoehendaten in regions["hoehendaten"]) +
                (
                    '|md5sum|cut -c-32'
                    ').osm.pbf >> $GITHUB_OUTPUT'
                )
            },
            {
                "id": "cache-merge",
                "uses": "actions/cache/restore@v5",
                "with": {
                    "path": "${{ steps.merged.outputs.filename }}",
                    "key": "${{ steps.merged.outputs.filename }}",
                }
            },
            {
                "name": "Merge extracts",
                "if": "steps.cache-merge.outputs.cache-hit != 'true'",
                "shell": "bash",
                "run": (
                    "scripts/osmosis.sh "
                    "${{ steps.merged.outputs.filename }} "
                ) +
                    "".join(f"${{{{ steps.geofabrik-{country}.outputs.filename }}}} " for country in regions['countries']) +
                    "".join(f"${{{{ steps.Hoehendaten_Freizeitkarte_{hoehendaten}.outputs.filename }}}} " for hoehendaten in regions["hoehendaten"])
            },
            {
                "uses": "actions/cache/save@v5",
                "with": {
                    "path": "${{ steps.merged.outputs.filename }}",
                    "key": "${{ steps.merged.outputs.filename }}",
                }
            },
            {
                "name": "Extract splitter",
                "shell": "bash",
                "run": "unzip -d splitter ${{ steps.splitter.outputs.filename }}",
            },
            {
                "name": "Extract cities",
                "shell": "bash",
                "run": "unzip ${{ steps.cities15000.outputs.filename }}",
            },
            {
                "name": "Splitter",
                "shell": "bash",
                "run": (
                    "java "
                    "-Xmx4096m "
                    "-jar splitter/*/splitter.jar "
                    "--output=pbf "
                    "--output-dir=splitted "
                    "--max-nodes=1400000 "
                    "--mapid=10010001 "
                    "--geonames-file=cities15000.txt "
                    "--polygon-file=resources/benelux.poly "
                    "${{ steps.merged.outputs.filename }}"
                )
            },
            {
                "name": "Extract mkgmap",
                "shell": "bash",
                "run": "unzip -d mkgmap ${{ steps.mkgmap.outputs.filename }}"
            },
            {
                "name": "Extract dem files",
                "shell": "bash",
                "run": "for Z in " +
                "".join(f"${{{{ steps.{dem}.outputs.filename }}}} " for dem in regions["DEM"]) + (
                    "; do "
                    "unzip -d map_with_dem_files $Z ;"
                    "done"
                )
            },
            {
                "name": "Move DEM files",
                "shell": "bash",
                "run": "mv map_with_dem_files/???/*.hgt map_with_dem_files/",
            },
            {
                "name": "Rename sea.zip",
                "shell": "bash",
                "run": "mv ${{ steps.sea.outputs.filename }} sea.zip",
            },
            {
                "name": "Rename bounds.zip",
                "shell": "bash",
                "run": "mv ${{ steps.bounds.outputs.filename }} bounds.zip",
            },
            {
                "name": "mkgmap",
                "shell": "bash",
                "run": (
                    "echo "
                    "java "
                    "-Xms4096m "
                    "-Xmx4096m "
                    "-jar mkgmap/*/mkgmap.jar "
                    "-c 'styles/Openfietsmap full/mkgmap.args' "
                    "-c 'splitted/template.args' "
                    "-c 'typ/Openfietsmap lite/20011.txt' "
                )
            },
            {
                "name": "Rename sea.zip",
                "shell": "bash",
                "run": "mv sea.zip ${{ steps.sea.outputs.filename }}",
            },
            {
                "name": "Rename bounds.zip",
                "shell": "bash",
                "run": "mv bounds.zip ${{ steps.bounds.outputs.filename }}"
            },
           #{
           #    "uses": "marvinpinto/action-automatic-releases@v1.2.1",
           #    "with": {
           #        "repo_token": "${{ '{{ secrets.PAT }}' }}",
           #        "automatic_release_tag": "latest",
           #        "prerelease": False,
           #        "files": "gmapsupp.img"
           #    }
           #}
        ]
    }
}

print(json.dumps(action, indent=4))
