import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { loadSettings } from '../src/client/state/persist.js';

test('entry pages include the official brand without changing auth scripts', () => {
  for (const page of ['index', 'login', 'join', 'claim', 'lite']) {
    const html = readFileSync(new URL(`../src/client/${page}.html`, import.meta.url), 'utf8');
    assert.match(html, /alt="易包裹 EBAOGUO"/);
    assert.match(html, /href="https:\/\/ebaoguo.com"/);
    assert.match(html, new RegExp(`src="\\./${page === 'index' ? 'main' : page}\\.ts"`));
  }
});
test('first visit has music muted', () => {
  assert.equal(loadSettings().musicMuted, true);
});
