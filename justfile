set dotenv-required
set dotenv-load
set shell := ["bash", "-uc"]
set windows-shell := ["bash", "-uc"]

_default:
    @just --list --justfile {{justfile()}}

# Generate everything
[group("generators")]
gen-all: clean gen-json-schema gen-docs

# Generate JSON Schema
[group("generators")]
gen-json-schema:
    @echo "Generating JSON Schema…"
    @echo -en "\t"
    mkdir -p "$DP_PROJECT_SCHEMAS_DIR"/json_schema
    @echo -en "\t"
    poetry run gen-json-schema \
        --not-closed \
        "$DP_PROJECT_SCHEMA" \
        > "$DP_PROJECT_SCHEMAS_DIR/json_schema/$DP_PROJECT_FILENAME.json_schema.json"
    @echo -n "… "
    @echo "OK."
    @echo
    @echo -e "Generated JSON Schema at: $DP_PROJECT_SCHEMAS_DIR/json_schema/$DP_PROJECT_FILENAME.json_schema.json"
    @echo

# Generate schema documentation (as an Antora module)
[group("generators")]
gen-docs:
    @echo "Generating documentation…"
    @echo -en "\t"
    mkdir -p "$DP_PROJECT_DOCS_IM_MODULE_DIR"
    @echo -en "\t"
    poetry run python -m linkml_asciidoc_generator.main \
        "$DP_PROJECT_SCHEMA" \
        "$DP_PROJECT_DOCS_IM_MODULE_DIR"
    @echo -n "… "
    @echo "OK."
    @echo
    @echo -e "Generated documentation files at: $DP_PROJECT_DOCS_IM_MODULE_DIR"
    @echo

# Clean up the output directory
[group("general")]
clean:
    @echo "Cleaning up generated artifacts…"
    @echo -e "\tCleaning up: $DP_PROJECT_SCHEMAS_DIR"
    @if [ -d "$DP_PROJECT_SCHEMAS_DIR" ]; then \
        ( shopt -s dotglob; rm -rf "$DP_PROJECT_SCHEMAS_DIR"/* ); \
    else \
        mkdir -p "$DP_PROJECT_SCHEMAS_DIR"; \
    fi
    @echo -e "\tCleaning up: $DP_PROJECT_DOCS_IM_MODULE_DIR "
    @if [ -d "$DP_PROJECT_DOCS_DIR" ]; then \
        ( shopt -s dotglob; rm -rf "$DP_PROJECT_DOCS_IM_MODULE_DIR"/* ); \
    else \
        mkdir -p "$DP_PROJECT_DOCS_IM_MODULE_DIR"; \
    fi
    @echo "… OK."
    @echo

# Show the contents of the output directory
[group("general")]
show-schemas:
    @if [ ! -d "$DP_PROJECT_SCHEMAS_DIR" ]; then \
        exit 0; \
    elif [ -x "$(which tree)" ]; then \
        tree "$DP_PROJECT_SCHEMAS_DIR"; \
    else \
        find "$DP_PROJECT_SCHEMAS_DIR"; \
    fi

# Edit the information model
[group("schema")]
edit-schema:
    @${VISUAL:-${EDITOR:-nano}} "$DP_PROJECT_SCHEMA"

# Show class hierarchy in information model
[group("schema")]
show-schema-classes:
    yq '.classes.* | key' "$DP_PROJECT_SCHEMA"

# Show class hierarchy in information model
[group("schema")]
get-def curie:
    @yq '.classes.* | select(.class_uri == "{{curie}}")' "$DP_PROJECT_SCHEMA"

# Release new major version
[group("vcs")]
release-major-version:
    @echo "Releasing new major version…"
    @echo -en "\t"
    gh workflow run release_major_version.yaml --ref $(git rev-parse --abbrev-ref HEAD)
    @echo "… OK."
    @echo

# Release new minor version
[group("vcs")]
release-minor-version:
    @echo "Releasing new minor version…"
    @echo -en "\t"
    gh workflow run release_minor_version.yaml --ref $(git rev-parse --abbrev-ref HEAD)
    @echo "… OK."
    @echo

# Release new patch version
[group("vcs")]
release-patch-version:
    @echo "Releasing new patch version…"
    @echo -en "\t"
    gh workflow run release_patch_version.yaml --ref $(git rev-parse --abbrev-ref HEAD)
    @echo "… OK."
    @echo

# Preview version
[group("vcs")]
preview-version:
    @echo "Generating preview of version…"
    @echo -en "\t"
    gh workflow run preview_release.yaml --ref $(git rev-parse --abbrev-ref HEAD)
    @echo "… OK."
    @echo

# Add GitHub branch protection rules for documentation branches
[group("vcs")]
_protect-docs-branches:
    @echo "Adding ruleset to protect documentation branches…"
    @echo -en "\t"
    gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        /repos/Netbeheer-Nederland/$(basename `git config --get remote.origin.url` | cut -d . -f -1)/rulesets \
        --input "scripts/protect-docs-branches-ruleset-def.json"
    @echo "… OK."
    @echo

# Add GitHub branch protection rules for major branches
[group("vcs")]
_protect-major-branches:
    @echo "Adding ruleset to protect major branches…"
    @echo -en "\t"
    gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        /repos/Netbeheer-Nederland/$(basename `git config --get remote.origin.url` | cut -d . -f -1)/rulesets \
        --input "scripts/protect-major-branches-ruleset-def.json"
    @echo "… OK."
    @echo

# Add GitHub branch protection rules
[group("vcs")]
add-branch-protections: _protect-docs-branches _protect-major-branches
