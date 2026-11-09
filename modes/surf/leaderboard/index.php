<?php
// Public leaderboard page.
require __DIR__ . '/lib.php';

$config = surf_config();
$db_error = null;
$maps = [];
$map = is_string($_GET['map'] ?? null) ? $_GET['map'] : '';
$search = is_string($_GET['q'] ?? null) ? mb_substr(trim($_GET['q']), 0, 64) : '';
$page = max(1, min(1000000, (int) (is_scalar($_GET['page'] ?? null) ? $_GET['page'] : 1)));
$per_page = 50;
$scores = [];
$total = 0;
try {
    $maps = surf_maps();
    if ($map !== '' && !surf_valid_map($map)) {
        $map = '';
    }
    $result = surf_leaderboard($map, $search, $per_page, ($page - 1) * $per_page);
    $total = $result['total'];
    $last_page = max(1, (int) ceil($total / $per_page));
    if ($page > $last_page) {
        $page = $last_page;
        $result = surf_leaderboard($map, $search, $per_page, ($page - 1) * $per_page);
    }
    $scores = $result['scores'];
} catch (RuntimeException $ex) {
    error_log('surf leaderboard: ' . $ex->getMessage());
    $db_error = 'The leaderboard is temporarily unavailable. Please try again later.';
}
$page_url = fn ($n) => '?' . http_build_query(['q' => $search, 'map' => $map, 'page' => $n]);
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
  .filters { display: flex; flex-wrap: wrap; gap: 12px; align-items: end; margin: 20px 0 12px; }
  label { display: grid; gap: 5px; flex: 1 1 220px; font-weight: 600; }
  input, select, button { font: inherit; padding: 9px 12px; border: 1px solid var(--line); border-radius: 6px; background: var(--panel); color: var(--text); min-height: 42px; }
  button { cursor: pointer; background: var(--accent); color: var(--bg); font-weight: 600; }
  a { color: var(--accent); }
  input:focus-visible, select:focus-visible, button:focus-visible, a:focus-visible { outline: 2px solid var(--accent); outline-offset: 3px; }
  .summary, .scope { color: var(--muted); }
  .pagination { justify-content: space-between; margin-top: 16px; align-items: center; }
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
  <p class="lede">Each pilot's best time, ranked across every server contributing to this leaderboard.</p>
  <form class="filters" method="get">
    <label for="pilot-search">Pilot name
      <input id="pilot-search" type="search" name="q" maxlength="64" value="<?= $e($search) ?>" placeholder="Search pilot names" autocomplete="off">
    </label>
    <label for="map-filter">Map
      <select id="map-filter" name="map">
        <option value="">All maps</option>
        <?php foreach ($maps as $m): ?>
          <option value="<?= $e($m['map']) ?>" <?= $m['map'] === $map ? 'selected' : '' ?>><?= $e(surf_map_label($m['map'])) ?> (<?= (int) $m['players'] ?> pilots)</option>
        <?php endforeach; ?>
      </select>
    </label>
    <button type="submit">Search</button>
    <a href="?">Clear filters</a>
  </form>
  <p class="scope">Global rank is per map and double-jump rule on this site. Searching does not change anyone's rank.</p>
  <?php if ($db_error === null): ?>
    <p class="summary" role="status"><?= $total ?> <?= $total === 1 ? 'result' : 'results' ?><?= $search !== '' ? ' matching ?' . $e($search) . '?' : '' ?></p>
  <?php endif; ?>
  <?php if ($db_error !== null): ?>
  <div class="empty"><?= $e($db_error) ?></div>
  <?php elseif ($scores): ?>
  <div class="wrap">
  <table>
    <thead><tr><th class="n">Global rank</th><th>Pilot</th><th>Map</th><th class="n">Time</th><th>Date</th><th>Server</th></tr></thead>
    <tbody>
    <?php foreach ($scores as $i => $s): ?>
      <tr class="<?= $s['rank'] <= 3 ? 'top' : '' ?>">
        <td class="n"><?= $s['rank'] ?></td>
        <td><?= $e($s['name']) ?></td>
        <td><?= $e(surf_map_label($s['map'])) ?></td>
        <td class="n"><?= $e(surf_format_time($s['time'])) ?></td>
        <td><?= $e(substr($s['date'], 0, 10)) ?></td>
        <td><?= $e($s['server']) ?></td>
      </tr>
    <?php endforeach; ?>
    </tbody>
  </table>
  </div>
  <?php if ($total > $per_page): ?>
    <nav class="pagination" aria-label="Leaderboard pages">
      <?php if ($page > 1): ?><a href="<?= $e($page_url($page - 1)) ?>">Previous</a><?php else: ?><span></span><?php endif; ?>
      <span>Page <?= $page ?> of <?= $last_page ?></span>
      <?php if ($page < $last_page): ?><a href="<?= $e($page_url($page + 1)) ?>">Next</a><?php else: ?><span></span><?php endif; ?>
    </nav>
  <?php endif; ?>
  <?php else: ?>
  <div class="empty"><?= $search !== '' ? 'No pilots match your search.' : 'No runs yet' . ($map !== '' ? ' on ' . $e(surf_map_label($map)) : '') . '.' ?></div>
  <?php endif; ?>
</main>
</body>
</html>
