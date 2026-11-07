<?php
// JSON API for game servers running MRVN.Surf.
//   POST api.php?action=submit   header X-Surf-Key: <server key>
//        body {"map": "mp_source_surf_utopia", "name": "Pilot", "uid": "1000123", "time": 83.25}
//   GET  api.php?action=top&map=mp_source_surf_utopia&limit=10
//   GET  api.php?action=maps
//   POST api.php?action=check   header X-Surf-Key: <server key>   (200 if the key is known, else 403)
require __DIR__ . '/lib.php';

header('Content-Type: application/json; charset=utf-8');

function reply(int $status, $data): void
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRESERVE_ZERO_FRACTION);
    exit;
}

try {
    $action = $_GET['action'] ?? '';
    if ($action === 'top') {
        $map = (string) ($_GET['map'] ?? '');
        if (!surf_valid_map($map)) {
            reply(400, ['error' => 'bad map']);
        }
        $limit = max(1, min(100, (int) ($_GET['limit'] ?? 10)));
        reply(200, surf_top($map, $limit));
    }
    if ($action === 'maps') {
        reply(200, surf_maps());
    }
    if ($action !== 'submit' && $action !== 'check') {
        reply(404, ['error' => 'unknown action']);
    }
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        reply(405, ['error' => 'use POST']);
    }

    $config = surf_config();
    $key = (string) ($_SERVER['HTTP_X_SURF_KEY'] ?? '');
    $server = null;
    foreach ($config['server_keys'] as $name => $known) {
        if ($key !== '' && hash_equals((string) $known, $key)) {
            $server = (string) $name;
        }
    }
    if ($server === null) {
        reply(403, ['error' => 'unknown server key']);
    }
    if ($action === 'check') {
        reply(200, ['ok' => true, 'server' => $server]);
    }

    $body = json_decode(file_get_contents('php://input'), true);
    if (!is_array($body)) {
        reply(400, ['error' => 'body must be JSON']);
    }
    $map = (string) ($body['map'] ?? '');
    $name = trim((string) ($body['name'] ?? ''));
    $uid = (string) ($body['uid'] ?? '');
    $time = $body['time'] ?? null;
    if (!surf_valid_map($map)) {
        reply(400, ['error' => 'bad map']);
    }
    if ($name === '' || mb_strlen($name) > 64) {
        reply(400, ['error' => 'bad name']);
    }
    if (!preg_match('/^[0-9]{1,32}$/', $uid)) {
        reply(400, ['error' => 'bad uid']);
    }
    if (!is_numeric($time) || $time < $config['min_time'] || $time > $config['max_time']) {
        reply(400, ['error' => 'time out of range']);
    }

    $db = surf_db();
    // One run per player every few seconds is plenty; more is a script or a bug.
    $recent = $db->prepare('SELECT COUNT(*) FROM runs WHERE uid = :uid AND created > :since');
    $recent->execute([':uid' => $uid, ':since' => time() - 3]);
    if ((int) $recent->fetchColumn() > 0) {
        reply(429, ['error' => 'too many submissions']);
    }

    $insert = $db->prepare('INSERT INTO runs (map, uid, name, time, server, created)
                            VALUES (:map, :uid, :name, :time, :server, :created)');
    $insert->execute([
        ':map' => $map, ':uid' => $uid, ':name' => $name, ':time' => (float) $time,
        ':server' => $server, ':created' => time(),
    ]);
    $rank = $db->prepare('SELECT COUNT(*) + 1 FROM (SELECT uid, MIN(time) AS best FROM runs WHERE map = :map GROUP BY uid) WHERE best < CAST(:time AS REAL)');
    $rank->execute([':map' => $map, ':time' => (float) $time]);
    reply(200, ['ok' => true, 'rank' => (int) $rank->fetchColumn()]);
} catch (Throwable $e) {
    error_log('surf api: ' . $e->getMessage());
    reply(500, ['error' => 'server error']);
}
