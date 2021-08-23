<?php

declare(strict_types=1);

use App\Console\TestCommand;

return [
    'config' => [
        'console' => [
            'commands' => [
                TestCommand::class,
            ],
        ],
    ],
];
