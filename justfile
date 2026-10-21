set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

docs_dir := "docs"
site_dir := "docs/_site"
bundle_path := "vendor/bundle"

default:
    @just --list

require-command command:
    @if ! command -v "{{command}}" >/dev/null 2>&1; then       echo "Required command not found: {{command}}" >&2;       exit 127;     fi

# Install the local Jekyll/GitHub Pages toolchain without using system gem paths.
install:
    just require-command ruby
    @if ! command -v bundle >/dev/null 2>&1; then       echo "Bundler is required. Install it with: gem install bundler" >&2;       exit 127;     fi
    bundle config set --local path "{{bundle_path}}"
    bundle install

# Build exactly from the same source directory GitHub Pages uses.
build:
    just require-command ruby
    just require-command bundle
    @if ! bundle check >/dev/null 2>&1; then       echo "Ruby dependencies are not installed. Run 'just install' first." >&2;       exit 2;     fi
    rm -rf "{{site_dir}}"
    bundle exec jekyll build --source "{{docs_dir}}" --destination "{{site_dir}}" --trace
    @for file in       "{{site_dir}}/index.html"       "{{site_dir}}/docs/index.html"       "{{site_dir}}/docs/architecture/index.html"       "{{site_dir}}/docs/retrieval-rag/index.html"       "{{site_dir}}/css/style.css"       "{{site_dir}}/assets/images/architecture.svg"; do         if [[ ! -f "$file" ]]; then           echo "Expected build artifact missing: $file" >&2;           exit 1;         fi;       done
    @echo "Jekyll build verified: {{site_dir}}"

# Serve the locally built documentation with the repository base URL.
serve:
    just require-command bundle
    @if ! bundle check >/dev/null 2>&1; then       echo "Ruby dependencies are not installed. Run 'just install' first." >&2;       exit 2;     fi
    bundle exec jekyll serve --source "{{docs_dir}}" --destination "{{site_dir}}" --baseurl "/boersenfuehrerschein-videoanalyzer-public" --livereload

clean:
    rm -rf "{{site_dir}}" "{{bundle_path}}" .bundle
