# Source attribution

**Brazilian E-Commerce Public Dataset by Olist**, provided by **Olist and collaborators**, contains anonymised marketplace order data from Brazil. The public data card describes orders from 2016–2018 and explains the customer identifier relationship.

- [Official Kaggle dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- [CC BY-NC-SA 4.0 license](https://creativecommons.org/licenses/by-nc-sa/4.0/)

The eight supplied CSV files were copied unchanged. Their row counts, byte sizes and SHA-256 fingerprints are recorded in [manifest.json](manifest.json). Raw files live in `data/raw/`, which is excluded from Git. Download the official ZIP and run `scripts/prepare_data.py` to reproduce the project.

The geolocation CSV is not required for the state-level analysis. The project uses the location fields already attached to customer and seller records.

Project-created aggregate snapshots, findings and charts are transformations of the Olist data and are shared under **CC BY-NC-SA 4.0**, with attribution to Olist and collaborators. The `docs/findings.md`, `results/` and chart outputs use that data license. The project does not imply Olist endorsement.
