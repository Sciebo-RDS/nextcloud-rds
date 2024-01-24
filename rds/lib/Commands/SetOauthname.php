<?php

namespace OCA\RDS\Commands;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use \OCP\IConfig;
use \OCA\RDS\Service\RDSService;


class SetOauthname extends Command
{

    private $config;
    private $appName;
    private $rdsService;

    public function __construct($AppName, IConfig $config, RDSService $rdsService)
    {
        parent::__construct();
        $this->appName = $AppName;
        $this->config = $config;
        $this->rdsService = $rdsService;
    }


    protected function configure()
    {
        $this
            ->setName('rds:set-oauthname')
            ->setDescription('Sets the name of oauth client used by RDS app.')
            ->addArgument(
                'oauthname',
                InputArgument::REQUIRED,
                'The name of the oauth2 client for the RDS app.'
            );
    }

    /**
     * @param InputInterface $input
     * @param OutputInterface $output
     * @return int|void
     * @throws \OCP\AppFramework\Db\MultipleObjectsReturnedException
     */
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $oauthname = $input->getArgument('oauthname');
        $this->config->setAppValue($this->appName, $this->rdsService->getOauthAppField(), $oauthname);
        $output->writeln("Set <$oauthname> as oauthname successful.");
        return 0;
    }
}
