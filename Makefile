# SPDX-FileCopyrightText: Bernhard Posselt <dev@bernhard-posselt.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Generic Makefile for building and packaging a Nextcloud app which uses npm and
# Composer.
#
# Dependencies:
# * make
# * which
# * curl: used if phpunit and composer are not installed to fetch them from the web
# * tar: for building the archive
# * npm: for building and testing everything JS
#
# If no composer.json is in the app root directory, the Composer step
# will be skipped. The same goes for the package.json which can be located in
# the app root or the js/ directory.
#
# The npm command by launches the npm build script:
#
#    npm run build
#
# The npm test command launches the npm test script:
#
#    npm run test
#
# The idea behind this is to be completely testing and build tool agnostic. All
# build tools and additional package managers should be installed locally in
# your project, since this won't pollute people's global namespace.
#
# The following npm scripts in your package.json install and update the bower
# and npm dependencies and use gulp as build system (notice how everything is
# run from the node_modules folder):
#
#    "scripts": {
#        "test": "node node_modules/gulp-cli/bin/gulp.js karma",
#        "prebuild": "npm install && node_modules/bower/bin/bower install && node_modules/bower/bin/bower update",
#        "build": "node node_modules/gulp-cli/bin/gulp.js"
#    },
version=0.0.2
app_name=rds
app_dir=$(CURDIR)/$(app_name)
build_tools_directory=$(CURDIR)/$(app_name)/build/tools
source_build_directory=$(CURDIR)/$(app_name)/build/artifacts/source
source_package_name=$(source_build_directory)/$(app_name)
appstore_build_directory=$(CURDIR)/$(app_name)/build/artifacts/appstore
appstore_package_name=$(app_name)-$(version)
npm=$(shell which npm 2> /dev/null)
composer=$(shell which composer 2> /dev/null)

all: build

# Fetches the PHP and JS dependencies and compiles the JS. If no composer.json
# is present, the composer step is skipped, if no package.json or js/package.json
# is present, the npm step is skipped
.PHONY: build
build:
ifneq (,$(wildcard $(app_dir)/composer.json))
	make composer
endif
ifneq (,$(wildcard $(app_dir)/package.json))
	make js
endif
ifneq (,$(wildcard $(app_dir)/js/package.json))
	make js
endif

# Installs and updates the composer dependencies. If composer is not installed
# a copy is fetched from the web
.PHONY: composer
composer:
ifeq (, $(composer))
	@echo "No composer command available, downloading a copy from the web"
	mkdir -p $(build_tools_directory)
	curl -sS https://getcomposer.org/installer | php
	mv composer.phar $(build_tools_directory)
	php $(build_tools_directory)/composer.phar install --prefer-dist
else
	cd $(app_dir) && composer install --prefer-dist
endif

# Installs npm dependencies
.PHONY: js
js: jsinstall npm

.PHONY: jsinstall
jsinstall:
	cd $(app_dir)/js && $(npm) install

.PHONY: npm
npm: npmbuild npminstall

.PHONY: npmbuild
npmbuild:
	cd $(app_dir)/js && $(npm) run build

.PHONY: npminstall
npminstall:
	mv $(app_dir)/js/dist/js/app.js $(app_dir)/js/ && mv $(app_dir)/js/dist/css/app.css $(app_dir)/css/

# Removes the appstore build
.PHONY: clean
clean:
	rm -rf $(app_dir)/build
	rm -rf $(app_dir)/js/dist

# Same as clean but also removes dependencies installed by composer, bower and
# npm
.PHONY: distclean
distclean: clean
	rm -rf $(app_dir)/vendor
	rm -rf $(app_dir)/node_modules
	rm -rf $(app_dir)/js/vendor
	rm -rf $(app_dir)/js/node_modules
	rm $(app_dir)/js/app.js
	rm $(app_dir)/css/app.css

# Bui$(app_dir)/lds the source and appstore package
.PHONY: dist
dist:
	make source
	make appstore

# Builds the source package
.PHONY: source
source:
	rm -rf $(source_build_directory)
	mkdir -p $(source_build_directory)
	cd $(app_dir) && tar cvzf $(source_package_name).tar.gz ../$(app_name) \
	--exclude-vcs \
	--exclude="../$(app_name)/build" \
	--exclude="../$(app_name)/js/node_modules" \
	--exclude="../$(app_name)/node_modules" \
	--exclude="../$(app_name)/*.log" \
	--exclude="../$(app_name)/js/*.log"

# Builds the source package for the app store, ignores php and js tests
.PHONY: package
package: build
	rm -rf $(appstore_build_directory)
	mkdir -p $(appstore_build_directory)
	cd $(app_dir) && tar cvzf $(appstore_build_directory)/$(appstore_package_name).tar.gz \
	--exclude-vcs \
	--exclude="./build" \
	--exclude="./*.tar.gz" \
	--exclude="./tests" \
	--exclude="./Makefile" \
	--exclude="./*.log" \
	--exclude="./phpunit*xml" \
	--exclude="./composer.*" \
	--exclude="./js/node_modules" \
	--exclude="./js/tests" \
	--exclude="./js/test" \
	--exclude="./js/*.log" \
	--exclude="./js/package.json" \
	--exclude="./js/bower.json" \
	--exclude="./js/karma.*" \
	--exclude="./js/protractor.*" \
	--exclude="./package.json" \
	--exclude="./bower.json" \
	--exclude="./karma.*" \
	--exclude="./protractor\.*" \
	--exclude="./.*" \
	--exclude="./js/.*" \
	--transform 's,^\.,rds,' \
  .

sign: package
	docker run --rm --volume $(cert_dir):/certificates --detach --name nextcloud nextcloud:latest
	sleep 5
	docker cp $(appstore_build_directory)/$(app_name)-$(version).tar.gz nextcloud:/var/www/html/custom_apps
	docker exec -u www-data nextcloud /bin/bash -c "mkdir -p /var/www/html/custom_apps && cd /var/www/html/custom_apps && tar -xzf $(app_name)-$(version).tar.gz && rm $(app_name)-$(version).tar.gz"
	docker exec -u www-data nextcloud /bin/bash -c "php /var/www/html/occ integrity:sign-app --certificate /certificates/$(app_name).crt --privateKey /certificates/$(app_name).key --path /var/www/html/custom_apps/$(app_name)"
	docker exec -u www-data nextcloud /bin/bash -c "cd /var/www/html/custom_apps && tar pzcf $(app_name)-$(version).tar.gz $(app_name)"
	docker cp nextcloud:/var/www/html/custom_apps/$(app_name)-$(version).tar.gz $(appstore_build_directory)/$(app_name)-$(version).tar.gz
	sleep 3
	docker kill nextcloud

appstore: sign
