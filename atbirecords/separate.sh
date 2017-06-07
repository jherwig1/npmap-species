#!/bin/bash

rm -fr ATBI_files Geojsons
#. /usr/share/modules/init/bash
python separate.py ATBI_records.csv > output.log
