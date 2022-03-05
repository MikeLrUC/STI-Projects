#!/bin/bash

bash ./scripts/load_config.bash     # Load config/openssl.cnf openssl configuration file
bash ./scripts/clean_ca.bash        # Clean any previous generated CA
bash ./scripts/create_ca.bash       # Generate a Private CA