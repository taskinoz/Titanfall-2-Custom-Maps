<?php
// Public leaderboard page.
require __DIR__ . '/lib.php';

$config = surf_config();
$db_error = null;
$maps = [];
$map = (string) ($_GET['map'] ?? '');
$scores = [];
try {
    $maps = surf_maps();
    if ($map === '') {
        $map = (string) ($maps[0]['map'] ?? '');
    }
    $scores = surf_valid_map($map) ? surf_top($map, 100) : [];
} catch (RuntimeException $e) {
    error_log('surf leaderboard: ' . $e->getMessage());
    $db_error = $e->getMessage();
}
$e = fn ($s) => htmlspecialchars((string) $s, ENT_QUOTES, 'UTF-8');
?><!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= $e($config['site_title']) ?></title>
<style>
  :root { --bg: #f6f7f9; --panel: #fff; --text: #1d2330; --muted: #677085; --line: #e2e5eb; --accent: #c2410c; }
  @media (prefers-color-scheme: dark) {
    :root { --bg: #12151b; --panel: #1b2029; --text: #e6e9ef; --muted: #98a1b3; --line: #2b313d; --accent: #fb923c; }
  }
  * { box-sizing: border-box; }
  body { margin: 0; background: var(--bg); color: var(--text); font: 15px/1.5 system-ui, sans-serif; }
  main { max-width: 820px; margin: 0 auto; padding: 24px 16px 48px; }
  h1 { font-size: 24px; margin: 0 0 4px; }
  p.lede { color: var(--muted); margin: 0 0 20px; }
  nav { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }
  nav a { padding: 6px 12px; border: 1px solid var(--line); border-radius: 999px; color: var(--text); text-decoration: none; background: var(--panel); }
  nav a.on { border-color: var(--accent); color: var(--accent); }
  .wrap { overflow-x: auto; }
  table { width: 100%; border-collapse: collapse; background: var(--panel); border: 1px solid var(--line); border-radius: 8px; overflow: hidden; }
  th, td { padding: 8px 12px; text-align: left; border-bottom: 1px solid var(--line); white-space: nowrap; }
  th { color: var(--muted); font-weight: 600; font-size: 13px; }
  td.n, th.n { text-align: right; font-variant-numeric: tabular-nums; }
  tr:last-child td { border-bottom: 0; }
  tr.top td:first-child { color: var(--accent); font-weight: 700; }
  .empty { padding: 24px; text-align: center; color: var(--muted); background: var(--panel); border: 1px solid var(--line); border-radius: 8px; }
</style>
</head>
<body>
<main>
  <h1><?= $e($config['site_title']) ?></h1>
  <p class="lede">Fastest runs from servers playing the MRVN.Surf mode: each pilot's best time per map.</p>
  <?php if ($maps): ?>
  <nav>
    <?php foreach ($maps as $m): ?>
      <a class="<?= $m['map'] === $map ? 'on' : '' ?>" href="?map=<?= urlencode($m['map']) ?>"><?= $e(preg_replace('/^mp_(source_|minecraft_)?/', '', $m['map'])) ?> · <?= (int) $m['players'] ?></a>
    <?php endforeach; ?>
  </nav>
  <?php endif; ?>
  <?php if ($db_error !== null): ?>
  <div class="empty"><?= $e($db_error) ?></div>
  <?php elseif ($scores): ?>
  <div class="wrap">
  <table>
    <thead><tr><th class="n">#</th><th>Pilot</th><th class="n">Time</th><th>Date</th><th>Server</th></tr></thead>
    <tbody>
    <?php foreach ($scores as $i => $s): ?>
      <tr class="<?= $i < 3 ? 'top' : '' ?>">
        <td class="n"><?= $i + 1 ?></td>
        <td><?= $e($s['name']) ?></td>
        <td class="n"><?= $e(surf_format_time($s['time'])) ?></td>
        <td><?= $e(substr($s['date'], 0, 10)) ?></td>
        <td><?= $e($s['server']) ?></td>
      </tr>
    <?php endforeach; ?>
    </tbody>
  </table>
  </div>
  <?php else: ?>
  <div class="empty">No runs yet<?= $map ? ' on ' . $e($map) : '' ?>.</div>
  <?php endif; ?>
</main>
</body>
</html>
