# ncappc

Installation

You need to have R installed. Download the latest version of R from www.r-project.org. Install ncappc in R from Github. Note that the command below installs the "master" (development) branch; if you want the release branch from Github add ref="release" to theinstall_github() call. The install_github() approach requires that you build from source, i.e. make and compilers must be installed on your system -- see the R FAQ for your operating system; you may also need to install dependencies manually.

devtools::install_github(“ncappc",username=“cacha0227")