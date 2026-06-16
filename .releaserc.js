module.exports = {
  "branches": ["main"],
  "tagFormat": "v${version}",
  "plugins": [
    ["@semantic-release/commit-analyzer", {
      "preset": "angular",
      "releaseRules": [
        // { "breaking": true,   "release": "minor" },
        { "type": "chore",    "release": "patch" },
        { "type": "refactor", "release": "patch" },
        { "type": "docs",     "release": "patch" },
        { "type": "ci",       "release": "patch" }
      ]
    }],
    ["@semantic-release/release-notes-generator", {
      "preset": "conventionalcommits",
      "presetConfig": {
        "types": [
          { "type": "Features",  "section": "Features" },
          { "type": "Bug Fixes", "section": "Bug Fixes" }
        ]
      },
      "writerOpts": {
        "commitsSort": ["header", "subject"],
        "transform": (commit) => {
          // clone object to avoid immutable error
          const clonedCommit = { ...commit };

          // mapping from original commit type to section title in CHANGELOG
          const sectionMap = {
            'feat': 'Features',
            'fix': 'Bug Fixes',
            'refactor': 'Code Refactoring',
            'chore': 'Others',
            'docs': 'Documentation',
            'perf': 'Performance',
            'ci': 'CI/CD'
          };

          const isSignoff = (line) => /^\s*Signed-off-by:/i.test(line);

          // commit body
          if (clonedCommit.body) {
            const cleanedBodyLines = clonedCommit.body.split('\n').filter(line => !isSignoff(line));
            clonedCommit.body = cleanedBodyLines.length > 0
              ? cleanedBodyLines.map(line => '  ' + line).join('\n')
              : null;
          }

          // footer
          if (clonedCommit.footer) {
            clonedCommit.footer = clonedCommit.footer
              .split('\n')
              .filter(line => !isSignoff(line))
              .join('\n').trim() || null;
          }

          // notes
          if (Array.isArray(clonedCommit.notes)) {
            clonedCommit.notes = clonedCommit.notes.filter(n => !isSignoff(n.text || n.title || ''));
          }

          // return the modified commit object, note: we did not change the subject,
          return clonedCommit;
        },
        // using {{header}} to ensure the original "feat: ..." is fully preserved
        "commitPartial": "* {{header}}\n{{#if body}}\n{{body}}\n{{/if}}\n{{#if footer}}\n\n{{footer}}\n{{/if}}\n"
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
