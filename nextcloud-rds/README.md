<!--
SPDX-FileCopyrightText: SUNET <eperez@emergya.com>
SPDX-License-Identifier: CC0-1.0
-->

# RDS
Place this app in **nextcloud/apps/**

## Building the app

The app can be built by using the provided Makefile by running:

    make

This requires the following things to be present:
* make
* which
* tar: for building the archive
* curl: used if phpunit and composer are not installed to fetch them from the web
* npm: for building and testing everything JS, only required if a package.json is placed inside the **js/** folder
* openssl
* mbstring extension enabled in PHP

The make command will install or update Composer dependencies if a
composer.json is present and also **npm run build** if a package.json is
present in the **js/** folder.


## Publish to App Store

First get an account for the [App Store](http://apps.nextcloud.com/) then run:

    make && make appstore

The archive is located in the directory above the one that contains the
Makefile, and can then be uploaded to the App Store.
