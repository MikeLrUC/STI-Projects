#!/bin/bash
filedir=`dirname "$0"`

# Generate new CA
bash $filedir/scripts/load_config.bash     # Load config/openssl.cnf openssl configuration file
bash $filedir/scripts/clean_ca.bash        # Clean any previous generated CA
bash $filedir/scripts/create_ca.bash       # Generate a Private CA

# Generate CRTs
bash $filedir/scripts/generate_crt.bash   coimbra-server   PT  Coimbra     UC   DEI   CoimbraServer 1      # Generate Coimbra/OCSP CRT
bash $filedir/scripts/generate_crt.bash   coimbra-client   PT  Coimbra     UP   DEI   CoimbraClient 0      # Generate Warrior CRT
bash $filedir/scripts/generate_crt.bash   lisboa-server    PT  Lisboa      UL   FCT   LisboaServer  1      # Generate Lisboa
bash $filedir/scripts/generate_crt.bash   apache           PT  Lisboa      UL   FCT   tp1.ul.pt     0      # Generate Apache CRT
bash $filedir/scripts/generate_crt.bash   warrior          PT  Porto       UP   DEI   ClientVPN     0      # Generate Warrior CRT

