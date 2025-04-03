// CommonJS Syntax (most common)
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'header-max-length': [0]                    // disable the header-max-length rule
  }
};
