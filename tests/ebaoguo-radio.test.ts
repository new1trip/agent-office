import test from 'node:test';
import assert from 'node:assert/strict';
import { CLASSIC_RADIO, STREAM, checkStreamUrl, trackTitle } from '../src/shared/jukebox.js';

test('classic radio uses a validated HTTPS stream and a readable title', () => {
  assert.deepEqual(checkStreamUrl(CLASSIC_RADIO.url), { url: CLASSIC_RADIO.url });
  assert.equal(new URL(CLASSIC_RADIO.url).protocol, 'https:');
  assert.equal(trackTitle({ track: STREAM, url: CLASSIC_RADIO.url }), CLASSIC_RADIO.title);
  assert.match(trackTitle({ track: STREAM, url: 'https://example.com/live' }), /example.com/);
  assert.ok('error' in checkStreamUrl('javascript:alert(1)'));
});
