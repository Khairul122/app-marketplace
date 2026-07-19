<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'role' => \App\Http\Middleware\EnsureRole::class,
        ]);

        // Authenticated users hitting a `guest`-only route (ex. /admin/login while
        // already logged in) should go straight to the dashboard, never back to `/`
        // (which itself redirects to login) — avoids an infinite redirect loop.
        $middleware->redirectUsersTo(fn () => route('admin.dashboard'));

        // Trust the reverse-proxy headers from dev tunnels (localtonet, ngrok, etc.)
        // so Laravel knows the original request was HTTPS and generates https:// asset
        // URLs — otherwise @vite() emits http:// links that get blocked as mixed
        // content on a page loaded over https, breaking all CSS/JS.
        $middleware->trustProxies(at: '*');
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*'),
        );
    })->create();
