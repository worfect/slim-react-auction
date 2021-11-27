<?php

declare(strict_types=1);

namespace App\Http\Action;

use League\OAuth2\Server\AuthorizationServer;
use League\OAuth2\Server\Exception\OAuthServerException;
use Psr\Http\Message\ResponseFactoryInterface;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Psr\Log\LoggerInterface;

final class TokenAction implements RequestHandlerInterface
{
    private AuthorizationServer $server;
    private LoggerInterface $logger;
    private ResponseFactoryInterface $response;

    public function __construct(
        AuthorizationServer $server,
        LoggerInterface $logger,
        ResponseFactoryInterface $response,
    ) {
        $this->server = $server;
        $this->logger = $logger;
        $this->response = $response;
    }

    public function handle(ServerRequestInterface $request): ResponseInterface
    {
        $response = $this->response->createResponse();
        try {
            return $this->server->respondToAccessTokenRequest($request, $response);
        } catch (OAuthServerException $exception) {
            $this->logger->warning($exception->getMessage(), ['exception' => $exception]);
            return $exception->generateHttpResponse($response);
        }
    }
}
