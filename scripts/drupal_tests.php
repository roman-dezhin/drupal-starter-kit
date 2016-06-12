<?php
/**
 * @file
 * This script file is executed on the Zen.ci platform for running tests.
 *
 * This essentially just wraps around the run-tests.sh script and uses the
 * result to post the response back to Zen.ci.
 */

$home = getenv('DOCROOT');
$deploy_dir = getenv('ZENCI_DEPLOY_DIR');
chdir($home);

/*
 * TableSortTests are failing if theme_registry get called by l() function in
 * modules/simpletest/tests/tablesort.test:60
 *
 * $this->verbose(strtr('$ts: <pre>!ts</pre>', array('!ts' => check_plain(var_export($ts, TRUE)))));
 *
 * To fix false failure, disable theme for links for this test.
 */
exec('drush vset theme_link 0');

$data = array(
  'state' => 'pending',
  'message' => 'Processing Tests',
);

zenci_put_request($data);

$tests = getenv('TESTS');

if(empty($tests)) {
  $tests = '--all';
}

$cmd = 'php ' . $deploy_dir . '/scripts/run-tests.sh --url http://localhost --verbose --concurrency 10 --color --summary /tmp/summary ' .$tests;

$proc = popen($cmd, 'r');

while (!feof($proc)) {
  echo fread($proc, 4096);
  @flush();
}

$status = pclose($proc);

$content = file_get_contents('/tmp/summary');

if ($status) {
  $content = explode("\n", $content);

  $message = $content[0];
  unset($content[0]);
  $summary = implode("\n", $content);
  // Test failed.
  $data = array(
    'state' => 'error',
    'message' => $message,
    'summary' => $summary,
  );
  zenci_put_request($data);
  exit(1);
}
else {
  // Success.
  $data = array(
    'state' => 'success',
    'message' => $content,
  );
  zenci_put_request($data);
  exit(0);
}


/**
 * Submit a POST request to Zen.ci updating its current status.
 *
 * @param array $data
 *   An array of data to push to Zen.ci. Should include the following:
 *   - state: One of "error", "success", or "pending".
 *   - message: A string summary of the state.
 *   - summary: Optional. A longer description of the state.
 */
function zenci_put_request($data) {
  $token = getenv('ZENCI_API_TOKEN');
  $status_url = getenv('ZENCI_STATUS_URL');

  $data = json_encode($data);

  $ch = curl_init();

  curl_setopt($ch, CURLOPT_URL, $status_url);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($ch, CURLOPT_POST, true);
  curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT"); // Note the PUT here.

  curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
  curl_setopt($ch, CURLOPT_HEADER, true);

  curl_setopt($ch, CURLOPT_HTTPHEADER, array(
      'Content-Type: application/json',
      'Token: ' . $token,
      'Content-Length: ' . strlen($data)
  ));
  curl_exec($ch);
  curl_close($ch);
}
