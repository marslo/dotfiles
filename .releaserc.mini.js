// Minimal semantic-release config — no custom templates.
// Uses the conventionalcommits preset (feat/fix/BREAKING …) via plugin defaults.
//
// NOTE: with conventional-changelog-conventionalcommits v9/v10, section grouping
// in the changelog may flatten (the Handlebars->render migration is not consumed
// by release-notes-generator's writer). If grouping disappears, use the full
// ~/.releaserc.js which inlines the Handlebars writerOpts to restore it.
module.exports = {
  branches: ["main"],
  plugins: [
    ["@semantic-release/commit-analyzer",         { preset: "conventionalcommits" }],
    ["@semantic-release/release-notes-generator", { preset: "conventionalcommits" }],
    "@semantic-release/changelog",   // writes/updates CHANGELOG.md
    "@semantic-release/git"          // commits the updated CHANGELOG.md
  ]
};
