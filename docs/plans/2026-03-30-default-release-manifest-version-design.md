# Default Release Manifest Version Design

**Date:** 2026-03-30

## Goal

When `deploy.sh` runs without `--version`, aggregate products should default to the latest embedded release manifest version instead of mixing repo-latest charts with a fixed SQL default.

## Problem

Current behavior is inconsistent:

- App charts install from the Helm repo latest version when `--version` is omitted.
- SQL initialization falls back to `DEFAULT_SQL_VERSION` (`0.5.0`).

This can install one release's charts with another release's SQL.

## Design

Add a shared shell resolver that scans `deploy/release-manifests/`, finds the latest semantic version directory, and uses that version as the implicit aggregate version when:

- the target product is `isf`, `kweaver-core`, or `kweaver-dip`
- `--version` is not provided
- no explicit `--version_file` is provided

Once resolved, the scripts set `HELM_CHART_VERSION` to that version and then reuse the existing embedded-manifest path resolution. This keeps:

- chart versions
- dependency manifest versions
- SQL initialization paths

on the same aggregate release version.

## Fallback

If no embedded release manifests exist for the target product, keep the old behavior:

- charts use Helm repo latest
- SQL uses `DEFAULT_SQL_VERSION`

## Validation

Add shell tests that prove:

1. the latest embedded manifest version resolves to `0.5.0` in the current tree
2. `download_core` and `download_dip` auto-fill `HELM_CHART_VERSION` from that latest version when `--version` is omitted
3. SQL path resolution follows the same inferred version
