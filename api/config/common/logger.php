<?php

declare(strict_types=1);

use Monolog\Formatter\JsonFormatter;
use Monolog\Handler\StreamHandler;
use Monolog\Logger;
use Psr\Container\ContainerInterface;
use Psr\Log\LoggerInterface;
use function App\env;

return [
    LoggerInterface::class => function (ContainerInterface $container): LoggerInterface {
        /**
         * @psalm-suppress MixedArrayAccess
         * @psalm-var array{
         *     debug:bool,
         *     stderr:bool,
         *     file:string
         * } $config
         */
        $config = $container->get('config')['logger'];

        $level = $config['debug'] ? Logger::DEBUG : Logger::INFO;

        $log = new Logger('API');

        $stream = 'php://stderr';
        if ($config['file']) {
            $stream = $config['file'];
        }

        $handler = new StreamHandler($stream, $level);
        $handler->setFormatter(new JsonFormatter());
        $log->pushHandler($handler);

        return $log;
    },

    'config' => [
        'logger' => [
            'debug' => (bool)env('APP_DEBUG'),
            'file' => null,
        ],
    ],
];
