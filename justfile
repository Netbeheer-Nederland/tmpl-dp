set dotenv-required
set dotenv-load
set shell := ["bash", "-uc"]
set windows-shell := ["bash", "-uc"]

_default:
    @just --list --justfile {{justfile()}}

# Generate everything
[group("generators")]
gen-all: clean gen-json-schema gen-docs show-output

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
show-output:
    @if [ -x "$(which tree)" ]; then \
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
get-def uri:
    @yq '.classes.* | select(.class_uri == "{{uri}}")' "$DP_PROJECT_SCHEMA"

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
