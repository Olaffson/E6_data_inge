# Repository Guidelines

## Project Structure & Module Organization
- Root Terraform config lives in `1_main.tf`, `2_variables.tf`, `3_providers.tf`, and `4_monitoring.tf`.
- Reusable Terraform modules are under `modules/` (e.g., `modules/sql_database`, `modules/event_hubs`).
- Data warehouse SQL artifacts are in `dwh_schema.sql` and `dwh_security_rls.sql`.
- RGPD scripts are under `RGPD/`.
- Event producer demo code is in `_events_producers/` (Python).
- Certification and documentation drafts are under `_certification/`.

## Build, Test, and Development Commands
- `./deploy.sh plan` runs `terraform init` and `terraform plan` (writes `tfplan`).
- `./deploy.sh apply` runs a plan then applies it (interactive by default).
- `./deploy.sh destroy` tears down infra (use with care).
- `terraform init` / `terraform plan` / `terraform apply` can be run directly if you do not want the script.
- `_events_producers`:
  - `pip install -r _events_producers/requirements.txt`
  - `EVENTHUB_CONNECTION_STR=... python _events_producers/producers.py`

## Coding Style & Naming Conventions
- Terraform: follow existing HCL style, align with module variable names in `modules/*/variables.tf`.
- Keep names descriptive and snake_case for variables/outputs when extending modules.
- Python: keep to PEP 8 basics (imports at top, 4-space indent, lowercase_with_underscores).
- SQL: prefer uppercase for keywords and snake_case for identifiers, consistent with existing files.

## Testing Guidelines
- No automated test framework is present. Validate changes via `terraform plan` and targeted manual checks.
- If adding tests, document how to run them in this file and in the module README (if added).

## Commit & Pull Request Guidelines
- Commit messages follow Conventional Commits (e.g., `feat: add log monitoring alert`, `fix: monitoring alert correction`).
- PRs should include a short description, the scope of Terraform changes, and relevant `terraform plan` output or summary.
- Link related issues or documentation updates when applicable.

## Security & Configuration Tips
- Do not commit secrets. Use `terraform.tfvars` locally and environment variables for sensitive values.
- Avoid editing `terraform.tfstate*` by hand; treat state as managed by Terraform.
