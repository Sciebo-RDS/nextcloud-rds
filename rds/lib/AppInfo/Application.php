<?php
declare(strict_types=1);
// SPDX-FileCopyrightText: SUNET <eperez@emergya.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

namespace OCA\RDS\AppInfo;

use OCP\AppFramework\App;

class Application extends App {
	public const APP_ID = 'rds';

	public function __construct() {
		parent::__construct(self::APP_ID);
	}
}
