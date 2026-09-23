# NYC Payroll Employee Data Engineering Pipeline

A batch data engineering pipeline for NYC payroll data built on Databricks. The pipeline ingests raw CSV data, validates and quarantines bad records, performs SCD Type 2 merges, and archives processed files — all with full audit logging.

## Pipeline Architecture

The pipeline runs as a multi-task Databricks job with four sequential tasks:

1. **File Watch** (`notebooks/fwnb`) — Polls a landing zone for `payrolldata.csv`
2. **Ingest & Validate** (`notebooks/01_pvtnb`) — Reads the CSV, generates surrogate keys, validates records, quarantines invalid/duplicate rows, and writes clean data to a staging table
3. **SCD2 Merge** (`notebooks/02_scdnb`) — Performs a Slowly Changing Dimension Type 2 merge from staging into the target table using Delta `MERGE`
4. **Archive** (`notebooks/03_archivenb`) — Moves the processed file to an archive directory

A shared utility notebook (`notebooks/00_audit_utilsnb`) provides audit logging (run logs + execution step logs) and is called via `%run` from tasks 2 and 3.

## Project Structure

```
.
├── databricks.yml                 # Declarative Automation Bundle configuration
├── .github/workflows/deploy.yml   # GitHub Actions CI/CD workflow
├── notebooks/
│   ├── 00_audit_utilsnb.ipynb     # Shared audit logging utility (not a standalone task)
│   ├── 01_pvtnb.ipynb             # Ingest, validate, and write to staging
│   ├── 02_scdnb.ipynb             # SCD Type 2 merge into target table
│   ├── 03_archivenb.ipynb         # Archive processed file
│   └── fwnb.ipynb                 # File watcher — polls for incoming CSV
└── tables/
    └── Tables.sql                 # DDL for pipeline tables
```

## CI/CD Setup

This project uses **Declarative Automation Bundles** and **GitHub Actions** for CI/CD. A pull request triggers a deployment to the `dev` target; a push to `main` deploys to the `prod` target and optionally runs the pipeline.

### Prerequisites

1. **Install the Databricks CLI** locally:
   ```bash
   pip install databricks-cli
   ```

2. **Create a Databricks service principal** in your account:
   - Go to **Admin Settings -> Service Principals -> Add Service Principal**
   - Generate an OAuth secret for the service principal
   - Grant the service principal access to the workspace and the `workspace.shprod` schema

3. **Generate an access token** for the service principal using the OAuth secret and client ID.

4. **Add GitHub repository secrets** (Settings -> Secrets and variables -> Actions):

   | Secret Name          | Value                                      |
   | -------------------- | ------------------------------------------ |
   | `DATABRICKS_TOKEN`   | Personal access token for PR dev deploys   |
   | `SP_CLIENT_ID`       | The service principal client ID (UUID)     |
   | `SP_CLIENT_SECRET`   | The service principal OAuth client secret  |

   The workspace host is taken from `databricks.yml` (`targets.<target>.workspace.host`).

### How the CI/CD Pipeline Works

| Trigger                | Target | What Happens                                        |
| ---------------------- | ------ | --------------------------------------------------- |
| Pull request to `main` | `dev`  | `bundle validate` then `bundle deploy` (dev target) |
| Push to `main`         | `prod` | `bundle validate` then `bundle deploy` then `bundle run` (prod) |

### Local Development

Validate and deploy the bundle locally to the dev target:

```bash
# Set environment variables
export DATABRICKS_HOST=https://dbc-c7d9691f-c2c1.cloud.databricks.com
export DATABRICKS_TOKEN=<your-personal-access-token>

# Validate the bundle configuration
databricks bundle validate -t dev

# Deploy to the dev target
databricks bundle deploy -t dev

# Run the pipeline
databricks bundle run payroll_batch_pipeline -t dev
```

### Customization

- **Compute**: The bundle uses serverless compute by default. To use a classic cluster, add a `job_clusters` section to the job in `databricks.yml`.
- **Schedule**: Add a `schedule` block to the job definition in `databricks.yml` to run the pipeline on a cadence.
- **Production `run_as`**: For the `prod` target, set `run_as` to a service principal instead of your user account.
- **Catalog/Schema**: Adjust the `catalog` and `schema` variables in `databricks.yml` or override them per target.
