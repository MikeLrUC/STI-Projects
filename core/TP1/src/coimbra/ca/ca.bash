#!/bin/bash
filedir=`dirname "$0"`

# Generate new CA
bash $filedir/scripts/load_config.bash     # Load config/openssl.cnf openssl configuration file
bash $filedir/scripts/clean_ca.bash        # Clean any previous generated CA
bash $filedir/scripts/create_ca.bash       # Generate a Private CA

# Generate CRTs
bash $filedir/scripts/generate_crt.bash   coimbra   PT  Coimbra   UC   DEI   CoimbraVPN           # Generate Coimbra/OCSP CRT
bash $filedir/scripts/generate_crt.bash   lisboa    PT  Lisboa    UL   FCT   tp1.ul.pt            # Generate Lisboa/Apache CRT
bash $filedir/scripts/generate_crt.bash   warrior   PT  Porto     UP   DEI   ClientVPN            # Generate Warrior CRT
