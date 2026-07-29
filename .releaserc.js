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

// {{header}} keeps the original "feat: ..." prefix; body/footer follow (signoff stripped in transform)
const commitPartial = "* {{header}}\n{{#if body}}\n{{body}}\n{{/if}}\n{{#if footer}}\n\n{{footer}}\n{{/if}}\n";

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

          // the parser may split trailing body lines into `footer` (e.g. a bullet containing an issue-like "#N");
          // fold body + footer back together, drop Signed-off-by, and indent non-empty lines so every detail stays in the commit's sub-list (blank lines kept empty to avoid trailing whitespace)
          const detail = [c.body, c.footer]
            .filter(Boolean)
            .join('\n')
            .split('\n')
            .filter(l => !isSignoff(l));
          c.body = detail.some(l => l.trim() !== '')
            ? detail.map(l => l.trim() === '' ? '' : '  ' + l).join('\n')
            : null;
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
    ["@semantic-release/changelog", { "changelogFile": "CHANGELOG.md" }],
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
