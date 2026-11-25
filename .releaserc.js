// =============================================================================
// Self-contained changelog config.
//
// WHY THE TEMPLATES ARE INLINED HERE:
//   semantic-release >= 26 bundles @semantic-release/release-notes-generator >= 15, which renders with conventional-changelog-writer >= 9: `writerOpts.template` and the `*Partial` options are plain functions ( no Handlebars; `mainTemplate` is ignored ).
//   the preset ( conventional-changelog-conventionalcommits >= 9 ) ships function templates too, but they render the stock layout; passing Handlebars strings for `headerPartial` / `commitPartial` made the preset's `template()` throw "headerPartial is not a function".
//   so we supply our own function `template` / `headerPartial` / `commitPartial` and the grouping ourselves; the preset is then only used for its commit PARSER.
//   requires writer >= 9 ( semantic-release >= 26 ); for semantic-release <= 25 ( Handlebars writer 8 ) the old string templates are needed instead.
// =============================================================================

const SECTIONS = [
  { type: 'feat',     section: 'Features' },
  { type: 'fix',      section: 'Bug Fixes' },
  { type: 'refactor', section: 'Code Refactoring' },
  { type: 'style',    section: 'Styles' },
  { type: 'chore',    section: 'Others' },
  { type: 'docs',     section: 'Documentation' },
  { type: 'perf',     section: 'Performance' },
  { type: 'test',     section: 'Tests' },
  { type: 'ci',       section: 'CI/CD' }
];
const TYPE_TO_SECTION = Object.fromEntries(SECTIONS.map(s => [s.type, s.section]));
const SECTION_ORDER   = SECTIONS.map(s => s.section);
const isSignoff       = (line) => /^\s*Signed-off-by:/i.test(line);
const stripSignoff    = (text) => (text || '').split('\n').filter(l => !isSignoff(l)).join('\n').trim();
// `BREAKING CHANGE:` / `BREAKING-CHANGE:` footer; already rendered from `notes` under "### ⚠ BREAKING CHANGES"
const isNoteStart     = (line) => /^\s*BREAKING[ -]CHANGES?:/.test(line);
// git trailer line, e.g. "Closes #12", "Refs: …", "Co-authored-by: …"
const isTrailer       = (line) => /^\s*[\w-]+(?::\s|\s#)/.test(line);
// drop each note block (keyword line + continuation lines, up to a blank line or the next trailer)
const stripNotes      = (lines) => {
  let inNote = false;
  return lines.filter(l => {
    if (isNoteStart(l)) { inNote = true; return false; }
    if (inNote && (l.trim() === '' || isTrailer(l))) { inNote = false; }
    return !inNote;
  });
};

// ── function templates (conventional-changelog-writer >= 9; plain string building, no Handlebars) ──
// version header: `## [x.y.z](<host>/<owner>/<repo>/compare/<prev>...<cur>) (<date>)`; plain version when there is no previous tag
const headerPartial = (ctx) => {
  const { linkCompare, version, host, owner, repository, previousTag, currentTag, date } = ctx;
  const ver = linkCompare
    ? `[${version}](${host}/${owner}/${repository}/compare/${previousTag}...${currentTag})`
    : version;
  return `## ${ver}${date ? ` (${date})` : ''}`;
};

// commit line: bold each comma-split scope as **scope:** (built as scopeFmt in transform) and keep the subject. PR commits carry an inline "(#N)" that GitHub auto-links, so leave them link-free; only direct pushes (no "(#N)") get an appended ([shortHash](…/commit/<hash>)) link. body (built in transform) follows on the next line(s)
const commitPartial = (ctx, c) => {
  let line = `*${c.scopeFmt ? ` ${c.scopeFmt}:` : ''} ${c.subject || c.header}`;
  if (!c.hasIssueRef && ctx.linkReferences) {
    line += ` ([${c.shortHash}](${ctx.host}/${ctx.owner}/${ctx.repository}/commit/${c.hash}))`;
  }
  return c.body ? `${line}\n${c.body}` : line;
};

const preamblePartial = () => '';
const footerPartial   = () => '';

// release block: header, breaking-change notes ("### ⚠ <title>"), then one "### <section>" per commit group; blocks separated by a blank line
const template = (ctx) => {
  const blocks = [ ctx.headerPartial(ctx) ];

  (ctx.noteGroups || []).forEach(group => {
    const items = group.notes.map(n => `* ${n.commit && n.commit.scope ? `**${n.commit.scope}:** ` : ''}${n.text}`);
    blocks.push([ `### ⚠ ${group.title}`, '', ...items ].join('\n'));
  });

  (ctx.commitGroups || []).forEach(group => {
    const items = group.commits.map(c => ctx.commitPartial(ctx, c));
    blocks.push([ ...(group.title ? [ `### ${group.title}`, '' ] : []), ...items ].join('\n'));
  });

  return blocks.join('\n\n');
};

// ── dynamic changelog title ──
// reuse an existing level-1 header (`# ...`) at the very top of CHANGELOG.md so new releases are inserted BELOW it; if there is none, leave changelogTitle unset so semantic-release just prepends (no title is forced onto title-less changelogs)
const fs = require('fs');
const path = require('path');
const CHANGELOG_FILE = 'CHANGELOG.md';
function detectChangelogTitle(file) {
  try {
    const text = fs.readFileSync(path.resolve(process.cwd(), file), 'utf8');
    const first = text.split('\n').find(l => l.trim() !== '');
    // a single '#' ATX header (rejects '##', '###', …) with actual text
    if (first && /^#\s+\S/.test(first)) { return first.trim(); }
  } catch (e) { /* missing or unreadable → treat as no title */ }
  return null;
}
const CHANGELOG_TITLE = detectChangelogTitle(CHANGELOG_FILE);

module.exports = {
  "branches": ["main"],
  "tagFormat": "v${version}",
  "plugins": [
    ["@semantic-release/commit-analyzer", {
      "preset": "conventionalcommits",
      "releaseRules": [
        // { "breaking": true,   "release": "minor" },
        { "breaking": true,   "release": "major" },
        // { "type": "feat",     "release": "patch" },
        { "type": "chore",    "release": "patch" },
        { "type": "refactor", "release": "patch" },
        { "type": "style",    "release": "patch" },
        { "type": "docs",     "release": "patch" },
        { "type": "ci",       "release": "patch" }
      ]
    }],
    ["@semantic-release/release-notes-generator", {
      "preset": "conventionalcommits",
      "presetConfig": { "types": SECTIONS },
      "writerOpts": {
        "groupBy": "type",
        // order sections as listed in SECTIONS (not alphabetically); unknown types go last
        "commitGroupsSort": (a, b) => {
          const rank = (t) => { const i = SECTION_ORDER.indexOf(t); return i === -1 ? SECTION_ORDER.length : i; };
          return rank(a.title) - rank(b.title);
        },
        "commitsSort": ["header", "subject"],
        "noteGroupsSort": "title",
        "template": template,
        "headerPartial": headerPartial,
        "preamblePartial": preamblePartial,
        "commitPartial": commitPartial,
        "footerPartial": footerPartial,
        "transform": (commit) => {
          const c = { ...commit };

          // type -> section label (drives the "### <section>" grouping)
          // commits without a conventional `type:` prefix (e.g. "Initial commit") would render ungrouped under the previous section; file them under "Others" with the chore commits
          if (TYPE_TO_SECTION[c.type]) {
            c.type = TYPE_TO_SECTION[c.type];
          } else if (!c.type) {
            c.type = TYPE_TO_SECTION.chore;
          }

          // preset's default transform (overridden here) normally sets shortHash; restore it so the commit link text isn't empty ("[](…/commit/<hash>)")
          if (typeof c.hash === 'string') {
            c.shortHash = c.hash.substring(0, 7);
          }

          // PR commits carry an inline "(#N)" that GitHub auto-links; keep it verbatim and skip the sha link. direct pushes (no "(#N)") get the commit-sha link (see commitPartial)
          c.hasIssueRef = /\(#\d+\)/.test(c.subject || '');

          // comma-split the scope and bold each part -> "**a**, **b**" (rendered via scopeFmt)
          if (c.scope) {
            c.scopeFmt = c.scope.split(',').map(s => '**' + s.trim() + '**').join(', ');
          }

          // the parser may split trailing body lines into `footer` (e.g. a bullet containing an issue-like "#N"); fold body + footer back together, drop Signed-off-by and BREAKING CHANGE notes (rendered from `notes`), collapse repeated blank lines and trim trailing ones
          // joined by a blank line: conventional-commits-parser >= 7 moves trailers ( "Co-authored-by: …" ) into `footer` without the blank line before them; the collapse below drops it again when the body already ends blank
          const detail = stripNotes(
            [c.body, c.footer]
              .filter(Boolean)
              .join('\n\n')
              .split('\n')
              .filter(l => !isSignoff(l))
          ).filter((l, i, a) => !(l.trim() === '' && i > 0 && a[i - 1].trim() === ''));
          // trailing blank lines and a GitHub squash-merge "---------" separator ( left over once the Signed-off-by trailers around it are dropped )
          while (detail.length && /^\s*(-{3,})?\s*$/.test(detail[detail.length - 1])) { detail.pop(); }
          if (detail.some(l => l.trim() !== '')) {
            // bullet body (`- ...`) -> 2-space sub-list right under the subject; free-form body (no bullets) -> blank line + 4-space verbatim block
            const hasBullets = detail.some(l => /^\s*-\s+\S/.test(l));
            const indent = hasBullets ? '  ' : '    ';
            const block = detail.map(l => l.trim() === '' ? '' : indent + l).join('\n');
            c.body = hasBullets ? block : '\n' + block;
          } else {
            c.body = null;
          }
          c.footer = null;

          // drop Signed-off-by trailers from notes
          if (Array.isArray(c.notes)) {
            c.notes = c.notes
              .map(n => ({ ...n, text: stripSignoff(n.text) }))
              .filter(n => n.text);
          }

          return c;
        }
      }
    }],
    ["@semantic-release/changelog", Object.assign(
      { "changelogFile": CHANGELOG_FILE },
      CHANGELOG_TITLE ? { "changelogTitle": CHANGELOG_TITLE } : {}
    )],
    ["@semantic-release/exec", {
      "prepareCmd": "pre-commit run --files CHANGELOG.md || true"
    }],
    ["@semantic-release/git", {
      "assets": ["CHANGELOG.md"],
      "message": "chore(release): v${nextRelease.version}"
    }],
    "@semantic-release/github"
  ]
};
