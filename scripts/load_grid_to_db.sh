#!/bin/bash

#./load_grid_to_db.sh /media/duvi/Extreme/temp localhost postgres /media/duvi/Extreme/temp/loading.log

if [ "$#" -lt 4 ]; then
    echo "Illegal number of parameters. The following parameters are required: input shp directory, postgres host, user and log path."
    exit 1
fi

shp_dir=$1
host=$2
user=$3
log_path=$4

echo START `date` >> $log_path
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
# define try_and_log function
. $SCRIPTPATH/try_and_log.sh

for zip_file in $shp_dir/*.zip
do
    base_name=`basename $zip_file`
    output_folder=${shp_dir}/${base_name%.zip}
    try_and_log unzip $zip_file -d $output_folder
    shp=${output_folder}/${base_name%.zip}.shp

    # convert 
    try_and_log ogr2ogr -explodecollections -update -append -fieldmap "`python get_field_map.py $shp`" -t_srs EPSG:3857 -f PostgreSQL "PG:dbname=grid host=$host user=$user" $shp -nln planet_osm_polygon
    try_and_log rm -r -f $output_folder
done
echo END `date` >> $log_path