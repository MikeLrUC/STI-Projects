#!/bin/bash

sudo apt-get update

# Install Required Packages
sudo apt install libpcap-dev  libpcre2-dev  libdnet-dev  libdnet  libnetfilter-queue1 \
libnetfilter-queue-dev  zlib1g-dev  build-essential  flex  bison  libdumbnet-dev \
libdumbnet1 libpcre++-dev luajit libluajit-5.1-dev libssl-dev -y

# Download required sources for libdaq and Snort 2 
cd /usr/local/src 
sudo wget https://www.snort.org/downloads/snort/daq-2.0.7.tar.gz  
sudo wget https://www.snort.org/downloads/snort/snort-2.9.19.tar.gz 

# Compile and install libdaq with support for the “nfq” DAQ 
sudo tar zxvf daq-2.0.7.tar.gz 
cd daq-2.0.7 

# As the result of the following command you should make sure that the “nfq” module is enabled for compilation 
sudo ./configure --enable-sourcefire --enable-nfq

# Compile and install DAQ 
sudo make 
sudo make install

echo "/usr/local/lib/daq" | sudo tee -a /etc/ld.so.confldconfig
sudo ldconfig

# Configure Snort for compilation 
cd /usr/local/src 
sudo tar zxvf snort-2.9.19.tar.gz 
cd snort-2.9.19 
sudo ./configure --enable-sourcefire --with-daq-includes=/usr/local/lib --with-daq-libraries=/usr/local/lib --prefix=/usr/local/snort

# Compile and install Snort 
sudo make 
sudo make install 
sudo ln -s /usr/local/snort/bin/snort /usr/sbin/snort

# Set up the initial configuration of Snort 
sudo cp -R etc/ /etc/snort

# Create folders and files that are required for Snort  
sudo mkdir /etc/snort/rules 
sudo mkdir /etc/snort/preproc_rules 
sudo mkdir /usr/local/lib/snort_dynamicpreprocessor 
sudo mkdir /usr/local/lib/snort_dynamicrules 
sudo mkdir /usr/local/lib/snort_dynamicengine 
 
# Create necessary files 
sudo touch /etc/snort/rules/white_list.rules 
sudo touch /etc/snort/rules/black_list.rules 
 
# Copy necessary files for dynamic pre processors  
sudo cp src/dynamic-plugins/sf_engine/.libs/libsf_engine.* /usr/local/lib/snort_dynamicengine/ 
sudo cp src/dynamic-preprocessors/build/usr/local/snort/lib/snort_dynamicpreprocessor/* /usr/local/lib/snort_dynamicpreprocessor/

# Deactivate rule files 
sudo sed -i 's/include \$RULE\_PATH/#include \$RULE\_PATH/' /etc/snort/snort.conf

cd ~/Desktop
sudo mkdir snort
cd snort/
sudo mkdir logs
touch snort.conf

# Ataque SQLi 1
echo 'drop tcp any any -> 10.20.20.3 5432 (msg: "OR SQLI Detected"; content: "or"; nocase; sid:100000008;)' > snort.conf

# Ataque SQLi 2
echo 'drop tcp any any -> 10.20.20.3 5432 (msg: "COMMA SQLI Detected"; content: ";"; nocase; sid:100000009;)' >> snort.conf


# Attack XSS 1
echo 'drop tcp any any -> 10.10.10.3 80 (msg: "XSS <img src= tag Detected"; pcre: "/< *img +src *=/i"; sid:100000010;)' >> snort.conf

# Attack XSS 2
echo 'drop tcp any any -> 10.10.10.3 80 (msg: "XSS <script> Detected"; pcre: "/< *script *>/i"; sid:100000011;)' >> snort.conf


# Run Snort
sudo /usr/sbin/snort -Q --daq nfq --daq-var queue=0 -c snort.conf -K ascii -v -l logs/

