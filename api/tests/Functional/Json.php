<?php

declare(strict_types=1);

namespace Test\Functional;

class Json
{
    /**
     * @throws \JsonException
     */
    public static function decode(string $data): array
    {
        /** @var array */
        return json_decode($data, true, 512, JSON_THROW_ON_ERROR);
    }
}
