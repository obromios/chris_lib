# Local Agent Notes

## Common Tasks

- Frequent request: fix `bundle-audit` findings for this gem with the smallest safe dependency update.
- Preferred workflow:
  1. Use the local Ruby version from `.ruby-version`, or the nearest installed compatible patch version if the exact patch is unavailable.
  2. Run `bundle-audit check` first to confirm the current findings.
  3. Apply the smallest safe dependency change in `chris_lib.gemspec` and `Gemfile.lock`.
  4. Re-run `bundle-audit check` until clean.
  5. Run the full test suite with `bundle exec rspec`.
  6. If asked, create a commit and push `master`.

## Release Guardrail

- Before advising the user to run `script/push_gem.rb`, first verify the latest published version on RubyGems or a reliable mirror.
- If the local version in `lib/chris_lib/version.rb` is not greater than the published version, do not advise running the release script yet.
- In that case, tell the user to bump the version first, then rebuild and release.

## Release Script

- `script/push_gem.rb` is intended for the final release steps only:
  - build `chris_lib.gemspec`
  - push the gem to RubyGems
  - create the `vX.Y.Z` tag if missing
  - push the tag to GitHub
- It assumes tests already passed and `master` is already pushed.
