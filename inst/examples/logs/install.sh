###############
# R
###############

# update indices
sudo apt update -qq
# install two helper packages we need
sudo apt install --no-install-recommends software-properties-common dirmngr
# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
# Fingerprint: E298A3A825C0D65DFD57CBB651716619E084DAB9
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

sudo apt install --no-install-recommends r-base -y
sudo add-apt-repository ppa:c2d4u.team/c2d4u4.0+
sudo apt install --no-install-recommends r-cran-tidyverse r-cran-shiny r-cran-shinyjs r-cran-bsicons r-cran-devtools r-cran-odbc r-cran-pool r-cran-yaml

sudo /bin/usr/R -e 'devtools::install_github("https://github.com/zekrom-vale/ShinySQLBrowser")'

# Rstudio
curl https://download1.rstudio.org/electron/jammy/amd64/rstudio-2023.12.1-402-amd64.deb rstudio.deb
sudo dpkg -i rstudio.deb

###############
# Mariadb
###############

sudo apt update
sudo apt-get install mariadb-server mariadb-client libmariadb3 mariadb-backup mariadb-common -y
sudo mysql_secure_installation

# https://mariadb.com/docs/server/connect/command-line/
mariadb --host 127.0.0.1 --port 3306 --user root --password 'RayLVM' < tableData.sql

