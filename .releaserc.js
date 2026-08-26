// =============================================================================
// Self-contained changelog config.
//
// WHY THE TEMPLATES ARE INLINED HERE:
//   @semantic-release/release-notes-generator renders with the Handlebars-based conventional-changelog-writer.
//   conventional-changelog-conventionalcommits >= 9 dropped its Handlebars writerOpts in favour of @conventional-changelog/ template, which release-notes-generator does NOT use — so with preset >= 9 the section grouping silently disappears (flat list, no "### Features").
//   To stay compatible with ANY preset version (8, 9, 10, …) we supply the full Handlebars writerOpts (mainTemplate / headerPartial / commitPartial) and the grouping ourselves; the preset is then only used for its commit PARSER.
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

// ── Handlebars templates (writer-8 compatible; vendored from the conventional-commits preset so they work regardless of the installed preset major) ──
const mainTemplate = `{{> header}}
{{#if noteGroups}}
{{#each noteGroups}}

### ⚠ {{title}}

{{#each notes}}
* {{#if commit.scope}}**{{commit.scope}}:** {{/if}}{{text}}
{{/each}}
{{/each}}
{{/if}}
{{#each commitGroups}}

{{#if title}}
### {{title}}

{{/if}}
{{#each commits}}
{{> commit root=@root}}
{{/each}}
{{/each}}
`;

const headerPartial = `## {{#if @root.linkCompare~}}
  [{{version}}]({{~@root.host}}/{{#if this.owner}}{{~this.owner}}{{else}}{{~@root.owner}}{{/if}}/{{#if this.repository}}{{~this.repository}}{{else}}{{~@root.repository}}{{/if}}/compare/{{previousTag}}...{{currentTag}})
{{~else}}
  {{~version}}
{{~/if}}
{{~#if date}} ({{date}})
{{/if}}
`;

// commit line: bold the scope as **scope:** and keep the subject. PR commits carry an inline "(#N)" that GitHub auto-links, so leave them link-free; only direct pushes (no "(#N)") get an appended ([shortHash](…/commit/<hash>)) link. body/footer follow (built in transform)
const commitPartial =
  '*{{#if scope}} **{{scope}}:**{{/if}} {{#if subject}}{{subject}}{{else}}{{header}}{{/if}}' +
  '{{#unless hasIssueRef}}{{#if @root.linkReferences}} ([{{shortHash}}]({{@root.host}}/{{@root.owner}}/{{@root.repository}}/commit/{{hash}})){{/if}}{{/unless}}' +
  '\n{{#if body}}\n{{body}}\n{{/if}}\n{{#if footer}}\n\n{{footer}}\n{{/if}}\n';

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
        "mainTemplate": mainTemplate,
        "headerPartial": headerPartial,
        "commitPartial": commitPartial,
        "footerPartial": "",
        "transform": (commit) => {
          const c = { ...commit };

          // type -> section label (drives the "### <section>" grouping)
          if (TYPE_TO_SECTION[c.type]) {
            c.type = TYPE_TO_SECTION[c.type];
          }

          // preset's default transform (overridden here) normally sets shortHash; restore it so the commit link text isn't empty ("[](…/commit/<hash>)")
          if (typeof c.hash === 'string') {
            c.shortHash = c.hash.substring(0, 7);
          }

          // PR commits carry an inline "(#N)" that GitHub auto-links; keep it verbatim and skip the sha link. direct pushes (no "(#N)") get the commit-sha link (see commitPartial)
          c.hasIssueRef = /\(#\d+\)/.test(c.subject || '');

          // the parser may split trailing body lines into `footer` (e.g. a bullet containing an issue-like "#N"); fold body + footer back together and drop Signed-off-by
          const detail = [c.body, c.footer]
            .filter(Boolean)
            .join('\n')
            .split('\n')
            .filter(l => !isSignoff(l));
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
