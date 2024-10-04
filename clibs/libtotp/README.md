# Libtotp

Libtotp is a simple lua wrapper around `libcotp` that allows for generating time-based one time passcodes (OTP) for use in 2 factor authentication systems.

# Building and Installation

First, install the required dependencies

- libcotp

On Ubuntu, this can be installed with the following command:

`sudo apt install libcotp-dev`

Then build and install the library with the following commands:

```sh
cd libtotp
make
sudo make install
```

Note, this assumes that the current lua installation is 5.1, and is installed to `/usr/local/lib/lua/5.1`. If this isn't the case, modify the `PREFIX` variable so that the lua interpreter is able to find the resulting shared object file.