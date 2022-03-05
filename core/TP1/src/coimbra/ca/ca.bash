#!/bin/bash
filedir=`dirname "$0"`

bash $filedir/scripts/load_config.bash     # Load config/openssl.cnf openssl configuration file
bash $filedir/scripts/clean_ca.bash        # Clean any previous generated CA
bash $filedir/scripts/create_ca.bash       # Generate a Private CA