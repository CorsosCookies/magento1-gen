
# Port based local host installer
**Prerequisites**
- Password-less root@localhost mysql account
- Apache with the web server
  - with a http.conf `IncludeOptional /pathtogitrepo/http-conf.d/*.conf` line
- A tar.bz2 magento 1.X archive
- Optional: A tar.bz2 magento-sample-data 1.X archive

# Features
- Installs Magento 1.9.3 in less than 30 seconds, without sample data
  - 2 minutes and 20 seconds with sample data, on an SSD
- Parallelizeable, can be run multiple times simultaneously

# Warning
This is for development purposes only, do not use in production.

# How to use
- run with `./newlocalmage.sh`
- thats it. The username is `admin` and the password is `password1`
