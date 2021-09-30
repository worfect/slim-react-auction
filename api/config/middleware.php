<?php

declare(strict_types=1);

use Psr\Container\ContainerInterface;
use Slim\App;

return static function (App $app, ContainerInterface $container): void {
    $app->addRoutingMiddleware();
    /** @psalm-var array{debug:bool} */
    $config = $container->get('config');

    $app->addErrorMiddleware($config['debug'], true, true);
};
