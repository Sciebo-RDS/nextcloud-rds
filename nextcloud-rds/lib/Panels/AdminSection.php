<?php

namespace OCA\RDS\Panels;

use OCP\IL10N;
use OCP\Settings\IIconSection;

class AdminSection implements IIconSection {
	/** @var IL10N  $l*/
	protected $l;

	public function __construct(IL10N $l) {
		$this->l = $l;
	}

	public function getPriority() {
		return 40;
	}

	public function getIcon() {
		return 'research-black';
	}

	public function getID() {
		return 'rds';
	}

	public function getName() {
		return $this->l->t('Research data services');
	}
}
