# Data seeding utilities

`scripts/seed_recipe_database.py` generates the structured SQL dump that backs the recipe categories.

## Running the seeder

```bash
python3 scripts/seed_recipe_database.py
```

The script creates/overwrites `assets/database/recipes.sql` with:

- `categories` — the six high-level recipe categories already exposed in the UI.
- `recipes` — one representative recipe per category with per-serving macro targets.
- `ingredients` — a normalized list of ingredients with nutrient values per default unit.
- `recipe_ingredients` — ingredient quantities and computed macro totals for each recipe.

You can load the dump into a SQLite database locally with:

```bash
sqlite3 recipes.db < assets/database/recipes.sql
```

You can safely rerun the script after adjusting the catalog or adding new recipes; the dump is rebuilt on every execution.
