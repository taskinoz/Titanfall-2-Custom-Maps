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
    $drivers = class_exists('PDO') ? PDO::getAvailableDrivers() : [];
    if (!in_array('sqlite', $drivers, true)) {
        throw new RuntimeException(
            'Missing PDO SQLite driver. Enable the pdo_sqlite extension in php.ini (Windows: php_pdo_sqlite).'
        );
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

// Rank all pilots before filtering, so a name search retains the global map rank.
// Pick an actual best run deterministically; its server and date stay together.
function surf_ranked_query(): string
{
    return 'WITH candidates AS (
        SELECT *, ROW_NUMBER() OVER (
            PARTITION BY map, uid ORDER BY time, created, id
        ) AS personal_run FROM runs
    ), ranked AS (
        SELECT *, RANK() OVER (PARTITION BY map ORDER BY time) AS global_rank
        FROM candidates WHERE personal_run = 1
    ) ';
}

function surf_leaderboard(string $map, string $search, int $limit = 50, int $offset = 0): array
{
    $where = "WHERE (:map = '' OR map = :map)
        AND (:search = '' OR INSTR(LOWER(name), LOWER(:search)) > 0)";
    $db = surf_db();
    $count = $db->prepare(surf_ranked_query() . 'SELECT COUNT(*) FROM ranked ' . $where);
    $count->execute([':map' => $map, ':search' => $search]);
    $stmt = $db->prepare(surf_ranked_query() . 'SELECT * FROM ranked ' . $where . '
        ORDER BY map, time, created, uid LIMIT :limit OFFSET :offset');
    $stmt->bindValue(':map', $map);
    $stmt->bindValue(':search', $search);
    $stmt->bindValue(':limit', max(1, min(100, $limit)), PDO::PARAM_INT);
    $stmt->bindValue(':offset', max(0, $offset), PDO::PARAM_INT);
    $stmt->execute();
    $rows = array_map(fn ($row) => [
        'name' => $row['name'], 'uid' => $row['uid'], 'map' => $row['map'],
        'rank' => (int) $row['global_rank'], 'time' => (float) $row['time'],
        'date' => gmdate('c', (int) $row['created']), 'server' => $row['server'],
    ], $stmt->fetchAll());
    return ['scores' => $rows, 'total' => (int) $count->fetchColumn()];
}

// Existing game-server API: each pilot's best time on one map.
function surf_top(string $map, int $limit): array
{
    return surf_leaderboard($map, '', $limit)['scores'];
}

function surf_map_label(string $map): string
{
    $no_jump = str_ends_with($map, '__no_double_jump');
    $name = preg_replace('/__no_double_jump$/', '', $map);
    $name = preg_replace('/^mp_(source_|minecraft_)?/', '', $name);
    return ucwords(str_replace('_', ' ', $name)) . ($no_jump ? ' (double jump off)' : '');
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
