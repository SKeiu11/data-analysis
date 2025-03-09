# data-analysis

# Data Analysis Pipeline

## 📂 ディレクトリ構成
.
├── README.md
├── config
│   ├── bigquery_config.json
│   ├── data_sources.yaml
│   └── settings.yaml
├── data
│   ├── processed
│   ├── raw
│   └── results
├── git_auto_push.sh
├── notebooks
│   └── python_basic
│       └── matplotlib_literature_setting.ipynb
├── run_all.sh
├── scripts
├── setup_env.sh
└── sql_code
    ├── geofece_sql
    │   ├── aggregate_geofence_counts.sql
    │   ├── assign_geofence.sql
    │   ├── create_geofence_table.sql
    │   ├── export_results.sql
    │   ├── filter_valid_stay_records.sql
    │   ├── geofence_cut.sql
    │   ├── geofence_threshold.sql
    │   └── import_csv_data.sql
    └── worker_sql
        ├── calculate_stay_time_sequence.sql
        ├── calculate_stay_time_st_fin.sql
        ├── create_visiter_list.sql
        ├── extract_worker_list.sql
        ├── filtered_visitor_data.sql
        ├── filtered_worker_data.sql
        └── sql_config.yaml