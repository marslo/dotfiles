module.exports = {
  "branches": ["main"],
  "tagFormat": "v${version}",
  "plugins": [
    ["@semantic-release/commit-analyzer", {
      "preset": "angular",
      "releaseRules": [
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

          // change type: this directly determines the ## header in CHANGELOG
          if (sectionMap[clonedCommit.type]) {
            clonedCommit.type = sectionMap[clonedCommit.type];
          }

          // body indentation (keep two spaces for sub-list alignment)
          if (clonedCommit.body) {
            clonedCommit.body = clonedCommit.body
              .split('\n')
              .map(line => '  ' + line)
              .join('\n');
          }

          // return the modified commit object, note: we did not change the subject,
          return clonedCommit;
        },
        // using {{header}} to ensure the original "feat: ..." is fully preserved
        "commitPartial": "* {{header}}\n{{#if body}}\n{{body}}\n{{/if}}\n{{#if footer}}\n\n{{footer}}\n{{/if}}\n"
      }
    }],
    ["@semantic-release/changelog", { "changelogFile": "CHANGELOG.md" }],
    ["@semantic-release/git", {
      "assets": ["CHANGELOG.md"],
      "message": "chore(release): v${nextRelease.version}"
    }],
    "@semantic-release/github"
  ]
};
