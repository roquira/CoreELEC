# Maintaining

Kodi changes live in [roquira/xbmc](https://github.com/roquira/xbmc); build configuration and releases live in [roquira/CoreELEC](https://github.com/roquira/CoreELEC). Both use `piers/customizations`.

Both branches are maintained as rebased patch stacks. Update them with `git push --force-with-lease`; published release tags preserve released states and must not be moved.

## Updating the build

1. Make and commit the Kodi changes. When moving to a new CoreELEC base, rebase the CoreELEC stack onto it and the Kodi stack onto the Kodi revision it uses. Drop patches already included upstream. If upstream has advanced the database schema, renumber local migrations as needed and preserve upgrade paths from previously released schemas.
2. Push the Kodi branch.
3. Update `PKG_VERSION` in [the Kodi package](../projects/Amlogic-ce/packages/mediacenter/kodi/package.mk). Fold pin updates into the existing `kodi: build from roquira/xbmc` commit: release-note generation takes the Kodi base from its parent.
4. Push CoreELEC and check that the `Check` workflow passes.

Use clear Kodi commit subjects: they become the release notes.

## Testing and releasing

Run the `Release` workflow manually on `piers/customizations` to build a test image without publishing. Test installation and upgrade on the target hardware, plus the behavior affected by the changes. Back up Kodi userdata before upgrade testing.

Release tags follow `<CoreELEC version>[-<stage>]-roquira.<n>`, for example `22.0-beta1-roquira.1` or `22.0-roquira.1`. Match the upstream version and stage, and increase `<n>` for each release. Tags with a stage are published as prereleases.

1. Tag the pinned Kodi commit and push the tag.
2. Apply the same tag to the tested CoreELEC commit and push it. This starts the build and publishes the release automatically.
3. Check that the workflow succeeded and the expected downloads are available.

## Build runner

Image builds require a dedicated self-hosted Linux runner with CoreELEC's build dependencies. Keep it isolated from personal data and credentials, and do not expose it to unapproved workflows from forks or use `pull_request_target` to execute repository code on it.

Runner labels and build settings are defined in [the Release workflow](workflows/release.yml).
