<?php
/**
 * Create your routes in here. The name is the lowercase name of the controller
 * without the controller part, the stuff after the hash is the method.
 * e.g. page#index -> OCA\NcRDS\Controller\PageController->index()
 *
 * The controller class has to be registered in the application.php file since
 * it's instantiated in there
 */
return [
    'routes' => [
        # template endpoints
        ['name' => 'page#index',                'url' => '/',                       'verb' => 'GET'],
        ['name' => 'rds_api#informations',      'url' => '/api/1.0/informations',   'verb' => 'GET'],
        ['name' => 'rds_api#publickey',         'url' => '/api/1.0/publickey',      'verb' => 'GET'],
        [
            'name' => 'rds_api#preflighted_cors',
            'url' => '/api/1.0/{path}',
            'verb' => 'OPTIONS',
            'requirements' => array('path' => '.+')
        ],
    ]
];
