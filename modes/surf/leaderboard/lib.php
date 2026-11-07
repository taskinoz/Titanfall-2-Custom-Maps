<?php
// Shared helpers: configuration and the SQLite database.

function surf_config(): array
{
    static $config = null;
    if ($config === null) {
        $file = __DIR__ . '/config.php';
        $config = require (is_file($file) ? $file : __DIR__ . '/config.example.php');
    }
    return $config;
}

function surf_db(): PDO
{
    static $db = null;
    if ($db !== null) {
        return $db;
    }
    $path = surf_config()['database'];
    if (!is_dir(dirname($path))) {
        mkdir(dirname($path), 0770, true);
    }
    $db = new PDO('sqlite:' . $path, null, null, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    $db->exec('PRAGMA journal_mode = WAL');
    $db->exec('CREATE TABLE IF NOT EXISTS runs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        map TEXT NOT NULL,
        uid TEXT NOT NULL,
        name TEXT NOT NULL,
        time REAL NOT NULL,
        server TEXT NOT NULL,
        created INTEGER NOT NULL
    )');
    $db->exec('CREATE INDEX IF NOT EXISTS runs_map_time ON runs (map, time)');
    $db->exec('CREATE INDEX IF NOT EXISTS runs_uid ON runs (uid, created)');
    return $db;
}

// Each player's best time on a map, fastest first.
function surf_top(string $map, int $limit): array
{
    $stmt = surf_db()->prepare(
        'SELECT r.name, r.uid, MIN(r.time) AS time, MIN(r.created) AS created, r.server
         FROM runs r
         JOIN (SELECT uid, MIN(time) AS best FROM runs WHERE map = :map GROUP BY uid) b
           ON r.uid = b.uid AND r.time = b.best
         WHERE r.map = :map
         GROUP BY r.uid
         ORDER BY time ASC, created ASC
         LIMIT :limit'
    );
    $stmt->bindValue(':map', $map);
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();
    return array_map(fn ($row) => [
        'name' => $row['name'],
        'uid' => $row['uid'],
        'time' => (float) $row['time'],
        'date' => gmdate('c', (int) $row['created']),
        'server' => $row['server'],
    ], $stmt->fetchAll());
}

function surf_maps(): array
{
    return surf_db()->query(
        'SELECT map, COUNT(*) AS runs, COUNT(DISTINCT uid) AS players, MIN(time) AS record
         FROM runs GROUP BY map ORDER BY map'
    )->fetchAll();
}

function surf_valid_map(string $map): bool
{
    return (bool) preg_match('/^[a-z0-9_]{1,64}$/', $map);
}

function surf_format_time(float $time): string
{
    $minutes = intdiv((int) floor($time), 60);
    $seconds = $time - $minutes * 60;
    return $minutes > 0 ? sprintf('%d:%06.3f', $minutes, $seconds) : sprintf('%.3f s', $seconds);
}
