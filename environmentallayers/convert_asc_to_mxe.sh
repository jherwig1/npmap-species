#!/bin/bash

rm -rf mxe
mkdir mxe
#. /usr/share/modules/init/bash
java -cp ../backend/maxent/maxent.jar density.Convert . asc mxe mxe

