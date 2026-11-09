<?php
// Copy to config.php and edit. Keep config.php and the database out of version control.
return [
    // SQLite database file. Put it outside the web root if you can.
    // Requires the pdo_sqlite PHP extension (Windows php.ini: extension=php_pdo_sqlite).
    'database' => __DIR__ . '/data/surf.sqlite',

    // One key per game server allowed to submit times. Set the same key on that server with
    //   surf_leaderboard_key "<key>"   and   surf_leaderboard_url "https://your.site/surf"
    // Generate keys with: php -r "echo bin2hex(random_bytes(24)), PHP_EOL;"
    'server_keys' => [
        // 'My server' => 'replace-with-a-long-random-key',
    ],

    // Times outside this range (seconds) are rejected as errors or cheats.
    'min_time' => 5.0,
    'max_time' => 3600.0,

    'site_title' => 'Titanfall 2 Surf Leaderboard',
];
