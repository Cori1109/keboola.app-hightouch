@echo off

echo Running component...
docker run -v %cd%:/data -e KBC_DATADIR=/data comp-tag