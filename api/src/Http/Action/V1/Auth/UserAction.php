<?php

declare(strict_types=1);

namespace App\Http\Action\V1\Auth;

use App\Http\JsonResponse;
use App\Http\Middleware\Auth\Authenticate;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Slim\Exception\HttpUnauthorizedException;

final class UserAction implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request): ResponseInterface
    {
        $identity = Authenticate::identity($request);

        if ($identity === null) {
            throw new HttpUnauthorizedException($request);
        }

        return new JsonResponse([
            'id' => $identity->id,
        ]);
    }
}
