#!/usr/bin/env python3
"""Seed a SQLite database with categorized recipes and macro-nutrient data."""
from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Tuple

OUTPUT_PATH = Path(__file__).resolve().parent.parent / "assets" / "database" / "recipes.sql"

SCHEMA = """
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS recipe_ingredients;
DROP TABLE IF EXISTS recipes;
DROP TABLE IF EXISTS ingredients;
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE recipes (
    id INTEGER PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    instructions TEXT NOT NULL,
    servings INTEGER NOT NULL,
    calories_per_serving REAL NOT NULL,
    protein_per_serving REAL NOT NULL,
    fat_per_serving REAL NOT NULL,
    carbs_per_serving REAL NOT NULL,
    image_url TEXT NOT NULL,
    prep_minutes REAL NOT NULL,
    cook_minutes REAL NOT NULL,
    review_count REAL NOT NULL,
    is_popular INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE ingredients (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    default_unit TEXT NOT NULL,
    calories_per_unit REAL NOT NULL,
    protein_per_unit REAL NOT NULL,
    fat_per_unit REAL NOT NULL,
    carbs_per_unit REAL NOT NULL
);

CREATE TABLE recipe_ingredients (
    recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    ingredient_id INTEGER NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    quantity REAL NOT NULL,
    unit TEXT NOT NULL,
    calories REAL NOT NULL,
    protein REAL NOT NULL,
    fat REAL NOT NULL,
    carbs REAL NOT NULL,
    notes TEXT,
    PRIMARY KEY (recipe_id, ingredient_id)
);
"""

CATEGORY_DESCRIPTIONS = {
    "Breakfast": "Quick meals to jump-start the morning with balanced macros.",
    "Lunch": "Midday plates designed to refuel with a mix of carbs, protein, and healthy fats.",
    "Dinner": "Heartier entrees that keep macro targets on track without sacrificing flavor.",
    "Snack": "Grab-and-go bites that satisfy between meals while supporting macro goals.",
    "Desert": "Sweet treats engineered with mindful macro and calorie targets.",
    "Beverage": "Smoothies and drinks that deliver hydration and nutrients in one serving.",
}


@dataclass(frozen=True)
class Ingredient:
    name: str
    default_unit: str
    calories_per_unit: float
    protein_per_unit: float
    fat_per_unit: float
    carbs_per_unit: float

    def scaled_macros(self, quantity: float) -> Tuple[float, float, float, float]:
        """Return calories, protein, fat, carbs for the given quantity."""
        return (
            round(self.calories_per_unit * quantity, 3),
            round(self.protein_per_unit * quantity, 3),
            round(self.fat_per_unit * quantity, 3),
            round(self.carbs_per_unit * quantity, 3),
        )


INGREDIENT_CATALOG: Dict[str, Ingredient] = {
    "Rolled oats": Ingredient("Rolled oats", "g", 3.89, 0.169, 0.069, 0.663),
    "Unsweetened almond milk": Ingredient("Unsweetened almond milk", "ml", 0.15, 0.006, 0.013, 0.007),
    "Chia seeds": Ingredient("Chia seeds", "g", 4.86, 0.17, 0.31, 0.42),
    "Banana": Ingredient("Banana", "g", 0.89, 0.011, 0.003, 0.23),
    "Vanilla whey protein": Ingredient("Vanilla whey protein", "scoop", 120.0, 24.0, 1.5, 3.0),
    "Quinoa": Ingredient("Quinoa", "g", 3.68, 0.14, 0.06, 0.64),
    "Cherry tomatoes": Ingredient("Cherry tomatoes", "g", 0.18, 0.009, 0.002, 0.039),
    "Cucumber": Ingredient("Cucumber", "g", 0.16, 0.007, 0.001, 0.036),
    "Chickpeas": Ingredient("Chickpeas", "g", 1.64, 0.089, 0.027, 0.27),
    "Feta cheese": Ingredient("Feta cheese", "g", 2.64, 0.14, 0.21, 0.04),
    "Olive oil": Ingredient("Olive oil", "ml", 8.84, 0.0, 0.998, 0.0),
    "Salmon fillet": Ingredient("Salmon fillet", "g", 2.08, 0.2, 0.13, 0.0),
    "Sweet potato": Ingredient("Sweet potato", "g", 0.86, 0.016, 0.003, 0.2),
    "Broccoli florets": Ingredient("Broccoli florets", "g", 0.34, 0.028, 0.004, 0.07),
    "Garlic": Ingredient("Garlic", "g", 1.49, 0.062, 0.005, 0.33),
    "Lemon juice": Ingredient("Lemon juice", "ml", 0.22, 0.004, 0.0, 0.006),
    "Greek yogurt": Ingredient("Greek yogurt", "g", 0.59, 0.1, 0.029, 0.036),
    "Mixed berries": Ingredient("Mixed berries", "g", 0.57, 0.007, 0.003, 0.14),
    "Honey": Ingredient("Honey", "g", 3.04, 0.0, 0.0, 0.82),
    "Granola": Ingredient("Granola", "g", 4.71, 0.08, 0.18, 0.6),
    "Chopped almonds": Ingredient("Chopped almonds", "g", 5.75, 0.212, 0.493, 0.214),
    "Avocado": Ingredient("Avocado", "g", 1.6, 0.02, 0.15, 0.09),
    "Cocoa powder": Ingredient("Cocoa powder", "g", 2.28, 0.19, 0.14, 0.58),
    "Maple syrup": Ingredient("Maple syrup", "g", 2.6, 0.0, 0.0, 0.67),
    "Coconut milk": Ingredient("Coconut milk", "ml", 0.75, 0.007, 0.076, 0.009),
    "Dark chocolate (70%)": Ingredient("Dark chocolate (70%)", "g", 5.98, 0.08, 0.43, 0.46),
    "Vanilla extract": Ingredient("Vanilla extract", "ml", 2.88, 0.0, 0.0, 0.13),
    "Spinach": Ingredient("Spinach", "g", 0.23, 0.029, 0.004, 0.036),
    "Kale": Ingredient("Kale", "g", 0.35, 0.029, 0.005, 0.07),
    "Green apple": Ingredient("Green apple", "g", 0.52, 0.003, 0.002, 0.14),
    "Ginger": Ingredient("Ginger", "g", 0.8, 0.018, 0.007, 0.18),
    "Water": Ingredient("Water", "ml", 0.0, 0.0, 0.0, 0.0),
    "Egg": Ingredient("Egg", "g", 1.55, 0.13, 0.11, 0.01),
    "Red bell pepper": Ingredient("Red bell pepper", "g", 0.31, 0.01, 0.003, 0.06),
    "Baking powder": Ingredient("Baking powder", "g", 0.53, 0.0, 0.0, 0.27),
    "Smoked salmon": Ingredient("Smoked salmon", "g", 1.17, 0.18, 0.04, 0.0),
    "Whole grain bread": Ingredient("Whole grain bread", "slice", 70.0, 3.6, 1.1, 12.0),
    "Chicken breast": Ingredient("Chicken breast", "g", 1.65, 0.31, 0.037, 0.0),
    "Whole wheat tortilla": Ingredient("Whole wheat tortilla", "piece", 130.0, 4.0, 3.5, 22.0),
    "Cooked lentils": Ingredient("Cooked lentils", "g", 1.16, 0.09, 0.004, 0.2),
    "Carrot": Ingredient("Carrot", "g", 0.41, 0.009, 0.002, 0.095),
    "Turkey breast": Ingredient("Turkey breast", "g", 1.35, 0.29, 0.016, 0.0),
    "Firm tofu": Ingredient("Firm tofu", "g", 0.76, 0.08, 0.048, 0.018),
    "Brown rice": Ingredient("Brown rice", "g", 1.11, 0.024, 0.009, 0.23),
    "Soy sauce": Ingredient("Soy sauce", "ml", 0.53, 0.008, 0.0, 0.1),
    "Sesame oil": Ingredient("Sesame oil", "ml", 8.84, 0.0, 0.998, 0.0),
    "Ground turkey": Ingredient("Ground turkey", "g", 1.6, 0.23, 0.09, 0.0),
    "Zucchini": Ingredient("Zucchini", "g", 0.17, 0.012, 0.003, 0.035),
    "Tomato sauce": Ingredient("Tomato sauce", "g", 0.29, 0.013, 0.008, 0.06),
    "Parmesan cheese": Ingredient("Parmesan cheese", "g", 4.31, 0.38, 0.29, 0.04),
    "Flank steak": Ingredient("Flank steak", "g", 2.0, 0.26, 0.11, 0.0),
    "Mushrooms": Ingredient("Mushrooms", "g", 0.22, 0.03, 0.003, 0.033),
    "Miso paste": Ingredient("Miso paste", "g", 1.98, 0.12, 0.06, 0.26),
    "Cod": Ingredient("Cod", "g", 0.82, 0.18, 0.007, 0.0),
    "Bok choy": Ingredient("Bok choy", "g", 0.13, 0.009, 0.002, 0.021),
    "Curry paste": Ingredient("Curry paste", "g", 1.6, 0.03, 0.09, 0.17),
    "Peanut butter": Ingredient("Peanut butter", "g", 5.9, 0.25, 0.5, 0.2),
    "Hummus": Ingredient("Hummus", "g", 1.66, 0.075, 0.089, 0.142),
    "Paprika": Ingredient("Paprika", "g", 2.82, 0.14, 0.13, 0.54),
    "Garlic powder": Ingredient("Garlic powder", "g", 3.3, 0.17, 0.01, 0.73),
    "Gelatin": Ingredient("Gelatin", "g", 3.23, 0.82, 0.0, 0.0),
    "Cinnamon": Ingredient("Cinnamon", "g", 2.47, 0.04, 0.012, 0.81),
    "Almond flour": Ingredient("Almond flour", "g", 5.7, 0.21, 0.5, 0.21),
    "Mango": Ingredient("Mango", "g", 0.6, 0.009, 0.004, 0.15),
    "Lime juice": Ingredient("Lime juice", "ml", 0.25, 0.004, 0.0, 0.008),
    "Beet": Ingredient("Beet", "g", 0.43, 0.016, 0.002, 0.096),
    "Orange juice": Ingredient("Orange juice", "ml", 0.45, 0.007, 0.0, 0.11),
    "Matcha powder": Ingredient("Matcha powder", "g", 3.24, 0.31, 0.05, 0.38),
    "Coconut water": Ingredient("Coconut water", "ml", 0.19, 0.004, 0.0, 0.044),
}

RecipeIngredient = Dict[str, float | str | None]


@dataclass
class Recipe:
    name: str
    category: str
    description: str
    instructions: str
    servings: int
    ingredient_rows: List[RecipeIngredient]
    image_url: str
    prep_minutes: float
    cook_minutes: float
    review_count: float
    is_popular: bool

    def total_macros(self) -> Tuple[float, float, float, float]:
        totals = [0.0, 0.0, 0.0, 0.0]
        for row in self.ingredient_rows:
            totals[0] += row["calories"]
            totals[1] += row["protein"]
            totals[2] += row["fat"]
            totals[3] += row["carbs"]
        return tuple(round(value, 2) for value in totals)

    def per_serving(self) -> Tuple[float, float, float, float]:
        total_cals, total_protein, total_fat, total_carbs = self.total_macros()
        divisor = float(self.servings)
        return (
            round(total_cals / divisor, 2),
            round(total_protein / divisor, 2),
            round(total_fat / divisor, 2),
            round(total_carbs / divisor, 2),
        )


def build_recipe(
    name: str,
    category: str,
    description: str,
    instructions: Iterable[str],
    servings: int,
    image_url: str,
    prep_minutes: float,
    cook_minutes: float,
    review_count: float,
    is_popular: bool,
    ingredients: Iterable[Tuple[str, float, str, str | None]],
) -> Recipe:
    """Create a recipe with computed macro data for each ingredient."""
    rows: List[RecipeIngredient] = []
    for ingredient_name, quantity, unit, notes in ingredients:
        ingredient = INGREDIENT_CATALOG[ingredient_name]
        if unit != ingredient.default_unit:
            raise ValueError(
                f"Unit mismatch for {ingredient_name}: expected {ingredient.default_unit}, got {unit}"
            )
        calories, protein, fat, carbs = ingredient.scaled_macros(quantity)
        rows.append(
            {
                "ingredient": ingredient.name,
                "quantity": quantity,
                "unit": unit,
                "calories": calories,
                "protein": protein,
                "fat": fat,
                "carbs": carbs,
                "notes": notes,
            }
        )
    instructions_text = "\n".join(f"{idx + 1}. {step}" for idx, step in enumerate(instructions))
    return Recipe(
        name,
        category,
        description,
        instructions_text,
        servings,
        rows,
        image_url,
        float(prep_minutes),
        float(cook_minutes),
        float(review_count),
        is_popular,
    )


RECIPES: List[Recipe] = [
    # Breakfast
    build_recipe(
        name="Protein Oatmeal Bowl",
        category="Breakfast",
        description="Creamy oats layered with fruit, healthy fats, and a protein boost to anchor the morning.",
        instructions=[
            "Bring the almond milk to a gentle simmer and stir in the oats.",
            "Cook for 5 minutes until thickened, then fold in chia seeds and whey protein.",
            "Transfer to bowls, top with sliced banana, and finish with remaining toppings.",
        ],
        servings=2,
        image_url="https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=10,
        cook_minutes=5,
        review_count=128,
        is_popular=True,
        ingredients=[
            ("Rolled oats", 80.0, "g", None),
            ("Unsweetened almond milk", 240.0, "ml", "Warm but do not boil to maintain creaminess."),
            ("Chia seeds", 15.0, "g", None),
            ("Banana", 100.0, "g", "Slice just before serving to prevent browning."),
            ("Vanilla whey protein", 1.0, "scoop", "Whisk in off the heat to avoid clumping."),
        ],
    ),
    build_recipe(
        name="Veggie Egg Scramble",
        category="Breakfast",
        description="Fluffy eggs folded with colorful vegetables and tangy feta for a savory start.",
        instructions=[
            "Whisk eggs with a pinch of salt and pepper until frothy.",
            "Sauté garlic, peppers, tomatoes, and spinach in olive oil until tender.",
            "Pour in eggs, scramble gently, and finish with crumbled feta.",
        ],
        servings=2,
        image_url="https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=10,
        cook_minutes=8,
        review_count=102,
        is_popular=False,
        ingredients=[
            ("Egg", 180.0, "g", "About 3 large eggs."),
            ("Olive oil", 10.0, "ml", "Heat just until shimmering."),
            ("Garlic", 5.0, "g", "Minced."),
            ("Red bell pepper", 70.0, "g", "Diced."),
            ("Cherry tomatoes", 80.0, "g", "Halved."),
            ("Spinach", 50.0, "g", "Roughly chopped."),
            ("Feta cheese", 40.0, "g", "Crumbled before serving."),
        ],
    ),
    build_recipe(
        name="Greek Yogurt Pancakes",
        category="Breakfast",
        description="High-protein pancakes with a tender crumb and naturally sweet berry topping.",
        instructions=[
            "Blend yogurt, oats, eggs, and baking powder into a smooth batter.",
            "Ladle onto a preheated skillet and cook until bubbles form and flip once.",
            "Serve warm with honey drizzle and fresh berries.",
        ],
        servings=3,
        image_url="https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=12,
        cook_minutes=15,
        review_count=89,
        is_popular=True,
        ingredients=[
            ("Greek yogurt", 180.0, "g", "Use thick strained yogurt."),
            ("Rolled oats", 60.0, "g", "Pulse into flour if preferred."),
            ("Egg", 120.0, "g", "About 2 large eggs."),
            ("Baking powder", 5.0, "g", None),
            ("Honey", 20.0, "g", "Reserve half for serving."),
            ("Mixed berries", 80.0, "g", "Fresh or thawed."),
        ],
    ),
    build_recipe(
        name="Smoked Salmon Avocado Toast",
        category="Breakfast",
        description="Whole-grain toast layered with creamy avocado and protein-rich smoked salmon.",
        instructions=[
            "Toast bread slices until crisp and golden.",
            "Mash avocado with lemon juice and spread evenly over toast.",
            "Top with smoked salmon, yogurt dollops, and baby spinach.",
        ],
        servings=2,
        image_url="https://images.pexels.com/photos/5665661/pexels-photo-5665661.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=8,
        cook_minutes=2,
        review_count=75,
        is_popular=False,
        ingredients=[
            ("Whole grain bread", 2.0, "slice", "Toast for extra crunch."),
            ("Avocado", 100.0, "g", "Mash with a fork."),
            ("Lemon juice", 10.0, "ml", "Mix into the avocado."),
            ("Smoked salmon", 90.0, "g", "Slice thinly."),
            ("Greek yogurt", 40.0, "g", "Dollop on top."),
            ("Spinach", 30.0, "g", "Use baby leaves."),
        ],
    ),
    build_recipe(
        name="Sweet Potato Breakfast Hash",
        category="Breakfast",
        description="A hearty skillet hash with caramelized sweet potatoes and soft scrambled eggs.",
        instructions=[
            "Sauté diced sweet potatoes in olive oil until tender and golden.",
            "Add peppers, garlic, and spinach; cook until wilted.",
            "Fold in whisked eggs and cook just until softly set.",
        ],
        servings=3,
        image_url="https://images.pexels.com/photos/803963/pexels-photo-803963.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=15,
        cook_minutes=20,
        review_count=68,
        is_popular=False,
        ingredients=[
            ("Sweet potato", 300.0, "g", "Dice into 1 cm cubes."),
            ("Olive oil", 12.0, "ml", "Divide for sautéing."),
            ("Red bell pepper", 80.0, "g", "Diced."),
            ("Garlic", 6.0, "g", "Minced."),
            ("Spinach", 60.0, "g", None),
            ("Egg", 180.0, "g", "Whisked lightly."),
        ],
    ),
    # Lunch
    build_recipe(
        name="Mediterranean Quinoa Lunch Bowl",
        category="Lunch",
        description="A high-fiber grain bowl with plant protein, fresh vegetables, and tangy feta.",
        instructions=[
            "Cook quinoa according to package instructions and let it cool slightly.",
            "Combine quinoa with chickpeas, tomatoes, cucumber, and feta in a large bowl.",
            "Dress with olive oil and lemon juice, tossing to coat evenly before serving.",
        ],
        servings=3,
        image_url="https://images.pexels.com/photos/6107787/pexels-photo-6107787.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
        prep_minutes=15,
        cook_minutes=20,
        review_count=96,
        is_popular=True,
        ingredients=[
            ("Quinoa", 90.0, "g", "Rinse well to remove bitterness."),
            ("Chickpeas", 150.0, "g", "Use cooked or canned chickpeas, drained."),
            ("Cherry tomatoes", 120.0, "g", "Halve for easier bites."),
            ("Cucumber", 100.0, "g", "Dice into small cubes."),
            ("Feta cheese", 60.0, "g", "Crumbled."),
            ("Olive oil", 15.0, "ml", None),
            ("Lemon juice", 20.0, "ml", "Freshly squeezed for best flavor."),
        ],
    ),
    build_recipe(
        name="Grilled Chicken Power Salad",
        category="Lunch",
        description="Lean grilled chicken over crisp greens with creamy avocado and citrus dressing.",
        instructions=[
            "Season chicken and grill until cooked through, then slice thinly.",
            "Toss spinach, cucumber, and tomatoes in a large bowl.",
            "Top with avocado and chicken, then drizzle with olive oil and lemon juice.",
        ],
        servings=2,
        image_url="https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=15,
        cook_minutes=14,
        review_count=110,
        is_popular=True,
        ingredients=[
            ("Chicken breast", 220.0, "g", "Grill and rest before slicing."),
            ("Spinach", 80.0, "g", None),
            ("Cucumber", 80.0, "g", "Sliced thin."),
            ("Cherry tomatoes", 100.0, "g", "Halved."),
            ("Avocado", 100.0, "g", "Diced."),
            ("Olive oil", 15.0, "ml", "Whisk with lemon for dressing."),
            ("Lemon juice", 20.0, "ml", None),
        ],
    ),
    build_recipe(
        name="Lentil Veggie Wrap",
        category="Lunch",
        description="Protein-packed lentils and crunchy vegetables wrapped in a whole wheat tortilla.",
        instructions=[
            "Warm tortillas until pliable.",
            "Mix lentils with hummus, peppers, carrots, and spinach.",
            "Fill each tortilla, roll tightly, and slice in half.",
        ],
        servings=2,
        image_url="https://images.pexels.com/photos/1640770/pexels-photo-1640770.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=12,
        cook_minutes=5,
        review_count=64,
        is_popular=False,
        ingredients=[
            ("Whole wheat tortilla", 2.0, "piece", "Gently warm to prevent cracking."),
            ("Cooked lentils", 180.0, "g", "Drain well."),
            ("Hummus", 80.0, "g", None),
            ("Red bell pepper", 70.0, "g", "Slice into strips."),
            ("Carrot", 80.0, "g", "Julienned."),
            ("Spinach", 60.0, "g", None),
        ],
    ),
    build_recipe(
        name="Turkey Avocado Sandwich",
        category="Lunch",
        description="A satisfying layered sandwich with lean turkey, creamy avocado, and leafy greens.",
        instructions=[
            "Toast bread lightly for structure.",
            "Mash avocado with a squeeze of lemon and spread on bread.",
            "Layer turkey, spinach, and yogurt spread, then slice to serve.",
        ],
        servings=1,
        image_url="https://images.pexels.com/photos/1600711/pexels-photo-1600711.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=10,
        cook_minutes=3,
        review_count=71,
        is_popular=False,
        ingredients=[
            ("Whole grain bread", 2.0, "slice", "Toast to your liking."),
            ("Turkey breast", 120.0, "g", "Thinly sliced."),
            ("Avocado", 80.0, "g", "Mashed."),
            ("Spinach", 30.0, "g", "Use baby leaves."),
            ("Greek yogurt", 30.0, "g", "Spread for tang."),
            ("Lemon juice", 5.0, "ml", "Mix into the avocado."),
        ],
    ),
    build_recipe(
        name="Tofu Veggie Stir-Fry",
        category="Lunch",
        description="Seared tofu with crisp vegetables tossed in a savory soy-sesame glaze over rice.",
        instructions=[
            "Press and cube tofu, then sear until golden on all sides.",
            "Stir-fry broccoli, peppers, and mushrooms until tender-crisp.",
            "Combine with tofu, soy sauce, and sesame oil; serve over warm brown rice.",
        ],
        servings=3,
        image_url="https://images.pexels.com/photos/3026800/pexels-photo-3026800.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=15,
        cook_minutes=18,
        review_count=83,
        is_popular=False,
        ingredients=[
            ("Firm tofu", 240.0, "g", "Press to remove excess moisture."),
            ("Broccoli florets", 120.0, "g", None),
            ("Red bell pepper", 90.0, "g", "Slice into strips."),
            ("Mushrooms", 100.0, "g", "Sliced."),
            ("Soy sauce", 30.0, "ml", "Add toward the end."),
            ("Sesame oil", 10.0, "ml", "Drizzle for finishing flavor."),
            ("Brown rice", 180.0, "g", "Cooked."),
        ],
    ),
    # Dinner
    build_recipe(
        name="Citrus Herb Salmon Plate",
        category="Dinner",
        description="Roasted salmon with vibrant vegetables and a bright citrus glaze.",
        instructions=[
            "Preheat the oven to 200°C and line a baking sheet with parchment.",
            "Toss sweet potato, broccoli, and garlic with half the olive oil and roast for 15 minutes.",
            "Add salmon to the tray, brush with remaining oil and lemon juice, then roast 12 more minutes.",
        ],
        servings=2,
        image_url="https://images.unsplash.com/photo-1607118750694-1469a22ef45d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=987&q=80",
        prep_minutes=15,
        cook_minutes=25,
        review_count=87,
        is_popular=True,
        ingredients=[
            ("Salmon fillet", 360.0, "g", "Use skin-on fillets for better moisture."),
            ("Sweet potato", 200.0, "g", "Cut into 2 cm cubes."),
            ("Broccoli florets", 120.0, "g", None),
            ("Garlic", 6.0, "g", "Thinly sliced."),
            ("Olive oil", 10.0, "ml", None),
            ("Lemon juice", 10.0, "ml", "Drizzle over salmon before serving."),
        ],
    ),
    build_recipe(
        name="Turkey Meatballs with Zoodles",
        category="Dinner",
        description="Lean turkey meatballs simmered in tomato sauce over zucchini noodles.",
        instructions=[
            "Mix ground turkey with egg, garlic, and parmesan; form into meatballs.",
            "Sear meatballs until browned, then simmer in tomato sauce until cooked through.",
            "Toss spiralized zucchini in the sauce just before serving.",
        ],
        servings=3,
        image_url="https://images.pexels.com/photos/3296273/pexels-photo-3296273.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=20,
        cook_minutes=25,
        review_count=92,
        is_popular=False,
        ingredients=[
            ("Ground turkey", 300.0, "g", "Use lean 93/7."),
            ("Egg", 60.0, "g", "Lightly beaten."),
            ("Garlic", 8.0, "g", "Minced."),
            ("Parmesan cheese", 30.0, "g", "Finely grated."),
            ("Tomato sauce", 240.0, "g", None),
            ("Olive oil", 10.0, "ml", "For searing."),
            ("Zucchini", 260.0, "g", "Spiralized into noodles."),
        ],
    ),
    build_recipe(
        name="Steak Quinoa Pilaf",
        category="Dinner",
        description="Seared flank steak over herbed quinoa with mushrooms and wilted greens.",
        instructions=[
            "Cook quinoa until fluffy and set aside.",
            "Sear flank steak to preferred doneness and rest before slicing.",
            "Sauté mushrooms, spinach, and garlic, toss with quinoa, and top with steak.",
        ],
        servings=2,
        image_url="https://images.pexels.com/photos/5737249/pexels-photo-5737249.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=18,
        cook_minutes=22,
        review_count=78,
        is_popular=False,
        ingredients=[
            ("Flank steak", 260.0, "g", "Slice against the grain."),
            ("Quinoa", 90.0, "g", "Cooked in low-sodium broth if desired."),
            ("Mushrooms", 100.0, "g", "Sliced."),
            ("Spinach", 80.0, "g", None),
            ("Garlic", 6.0, "g", None),
            ("Olive oil", 15.0, "ml", "Divide for steak and vegetables."),
            ("Lemon juice", 10.0, "ml", "Finish with a squeeze."),
        ],
    ),
    build_recipe(
        name="Miso Cod with Bok Choy",
        category="Dinner",
        description="Oven-baked cod glazed with miso and sesame, served alongside tender bok choy.",
        instructions=[
            "Whisk miso paste with sesame oil and lemon juice to form a glaze.",
            "Brush over cod fillets and bake until flaky.",
            "Sauté bok choy with ginger until just wilted and serve with cod.",
        ],
        servings=2,
        image_url="https://images.pexels.com/photos/6287529/pexels-photo-6287529.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=12,
        cook_minutes=15,
        review_count=66,
        is_popular=False,
        ingredients=[
            ("Cod", 320.0, "g", "Use skinless fillets."),
            ("Miso paste", 40.0, "g", None),
            ("Sesame oil", 10.0, "ml", None),
            ("Lemon juice", 15.0, "ml", "Whisk into glaze."),
            ("Bok choy", 200.0, "g", "Halve lengthwise."),
            ("Ginger", 10.0, "g", "Julienned."),
        ],
    ),
    build_recipe(
        name="Chickpea Coconut Curry",
        category="Dinner",
        description="A creamy chickpea curry with sweet potato and spinach served over brown rice.",
        instructions=[
            "Sauté garlic and curry paste until fragrant.",
            "Stir in sweet potato, chickpeas, and coconut milk; simmer until tender.",
            "Fold in spinach and serve over warm brown rice.",
        ],
        servings=4,
        image_url="https://images.pexels.com/photos/1640773/pexels-photo-1640773.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=15,
        cook_minutes=30,
        review_count=91,
        is_popular=True,
        ingredients=[
            ("Garlic", 8.0, "g", None),
            ("Curry paste", 25.0, "g", "Adjust heat to taste."),
            ("Sweet potato", 220.0, "g", "Diced."),
            ("Chickpeas", 200.0, "g", None),
            ("Coconut milk", 200.0, "ml", None),
            ("Spinach", 80.0, "g", None),
            ("Brown rice", 200.0, "g", "Cooked for serving."),
        ],
    ),
    # Snack
    build_recipe(
        name="Berry Crunch Yogurt Jar",
        category="Snack",
        description="Layered Greek yogurt parfait with berries, honey, and crunchy toppings.",
        instructions=[
            "Whisk honey into the yogurt until smooth.",
            "Layer yogurt, berries, and granola in jars.",
            "Top with chopped almonds just before serving for crunch.",
        ],
        servings=2,
        image_url="https://images.pexels.com/photos/8963959/pexels-photo-8963959.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500",
        prep_minutes=10,
        cook_minutes=0,
        review_count=54,
        is_popular=False,
        ingredients=[
            ("Greek yogurt", 200.0, "g", "Use 2% or 5% depending on fat goals."),
            ("Mixed berries", 80.0, "g", "A mix of blueberries, raspberries, and strawberries."),
            ("Honey", 15.0, "g", None),
            ("Granola", 30.0, "g", "Choose a low-sugar variety."),
            ("Chopped almonds", 15.0, "g", "Lightly toasted."),
        ],
    ),
    build_recipe(
        name="Spicy Roasted Chickpeas",
        category="Snack",
        description="Crunchy roasted chickpeas coated in smoky paprika and garlic.",
        instructions=[
            "Pat chickpeas dry and toss with oil and spices.",
            "Roast, shaking the pan occasionally, until crisp.",
            "Cool slightly before serving for maximum crunch.",
        ],
        servings=4,
        image_url="https://images.pexels.com/photos/4110404/pexels-photo-4110404.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=8,
        cook_minutes=35,
        review_count=63,
        is_popular=False,
        ingredients=[
            ("Chickpeas", 160.0, "g", "Cooked and drained."),
            ("Olive oil", 10.0, "ml", None),
            ("Paprika", 6.0, "g", "Smoked for depth."),
            ("Garlic powder", 3.0, "g", None),
        ],
    ),
    build_recipe(
        name="Peanut Butter Apple Slices",
        category="Snack",
        description="Fresh apple wedges topped with protein-rich peanut butter and chia sprinkle.",
        instructions=[
            "Slice apples into wedges and arrange on a plate.",
            "Spread peanut butter over each slice.",
            "Dust with chia seeds and cinnamon before serving.",
        ],
        servings=2,
        image_url="https://images.pexels.com/photos/1351238/pexels-photo-1351238.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=5,
        cook_minutes=0,
        review_count=58,
        is_popular=False,
        ingredients=[
            ("Green apple", 160.0, "g", "Leave skin on for fiber."),
            ("Peanut butter", 40.0, "g", "Natural style."),
            ("Chia seeds", 10.0, "g", None),
            ("Cinnamon", 2.0, "g", "Sprinkle evenly."),
        ],
    ),
    build_recipe(
        name="Veggie Hummus Cups",
        category="Snack",
        description="Crunchy veggie sticks served with creamy hummus for dipping.",
        instructions=[
            "Slice cucumber, carrots, and peppers into sticks.",
            "Portion hummus into small cups.",
            "Serve vegetables upright in hummus cups with a squeeze of lemon.",
        ],
        servings=3,
        image_url="https://images.pexels.com/photos/1640775/pexels-photo-1640775.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=10,
        cook_minutes=0,
        review_count=47,
        is_popular=False,
        ingredients=[
            ("Cucumber", 80.0, "g", "Cut into batons."),
            ("Carrot", 80.0, "g", "Slice into sticks."),
            ("Red bell pepper", 70.0, "g", "Slice into strips."),
            ("Hummus", 90.0, "g", None),
            ("Lemon juice", 10.0, "ml", "Drizzle over veggies."),
        ],
    ),
    build_recipe(
        name="Chocolate Protein Energy Bites",
        category="Snack",
        description="No-bake bites packed with oats, peanut butter, and dark chocolate chips.",
        instructions=[
            "Stir oats, peanut butter, honey, and chia seeds until evenly combined.",
            "Fold in chopped dark chocolate.",
            "Roll into bite-sized balls and chill to set.",
        ],
        servings=4,
        image_url="https://images.pexels.com/photos/1633525/pexels-photo-1633525.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=12,
        cook_minutes=0,
        review_count=88,
        is_popular=True,
        ingredients=[
            ("Rolled oats", 120.0, "g", None),
            ("Peanut butter", 80.0, "g", "Creamy."),
            ("Honey", 40.0, "g", None),
            ("Chia seeds", 20.0, "g", None),
            ("Dark chocolate (70%)", 40.0, "g", "Chopped."),
        ],
    ),
    # Desert
    build_recipe(
        name="Dark Chocolate Avocado Mousse",
        category="Desert",
        description="Silky, dairy-free dessert with heart-healthy fats and antioxidant-rich cocoa.",
        instructions=[
            "Blend avocado, coconut milk, cocoa powder, and maple syrup until smooth.",
            "Add melted dark chocolate and vanilla extract; blend again until glossy.",
            "Chill for at least 30 minutes before serving with optional toppings.",
        ],
        servings=4,
        image_url="https://images.unsplash.com/photo-1609355109553-3bb67c76b1f7?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=987&q=80",
        prep_minutes=15,
        cook_minutes=0,
        review_count=67,
        is_popular=False,
        ingredients=[
            ("Avocado", 150.0, "g", "Very ripe for the smoothest texture."),
            ("Coconut milk", 60.0, "ml", "Full-fat canned coconut milk."),
            ("Cocoa powder", 20.0, "g", None),
            ("Maple syrup", 30.0, "g", None),
            ("Dark chocolate (70%)", 25.0, "g", "Melt gently over a bain-marie."),
            ("Vanilla extract", 5.0, "ml", None),
        ],
    ),
    build_recipe(
        name="Coconut Yogurt Panna Cotta",
        category="Desert",
        description="A light panna cotta made with coconut milk and Greek yogurt topped with berries.",
        instructions=[
            "Bloom gelatin in a small amount of coconut milk.",
            "Warm remaining coconut milk with honey, then whisk in gelatin and yogurt.",
            "Pour into cups, chill until set, and top with berries.",
        ],
        servings=4,
        image_url="https://images.pexels.com/photos/3026801/pexels-photo-3026801.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=15,
        cook_minutes=5,
        review_count=59,
        is_popular=False,
        ingredients=[
            ("Coconut milk", 200.0, "ml", None),
            ("Honey", 30.0, "g", None),
            ("Gelatin", 8.0, "g", "Powdered."),
            ("Greek yogurt", 150.0, "g", "Room temperature."),
            ("Vanilla extract", 5.0, "ml", None),
            ("Mixed berries", 90.0, "g", "For topping."),
        ],
    ),
    build_recipe(
        name="Baked Cinnamon Apples",
        category="Desert",
        description="Warm baked apples with a cinnamon oat crumble and nutty crunch.",
        instructions=[
            "Core and slice apples, then toss with cinnamon and maple syrup.",
            "Top with oats and almonds and bake until tender.",
            "Serve warm with a dollop of yogurt if desired.",
        ],
        servings=3,
        image_url="https://images.pexels.com/photos/4109991/pexels-photo-4109991.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=12,
        cook_minutes=25,
        review_count=72,
        is_popular=False,
        ingredients=[
            ("Green apple", 300.0, "g", "Sliced."),
            ("Cinnamon", 4.0, "g", None),
            ("Maple syrup", 30.0, "g", None),
            ("Rolled oats", 40.0, "g", None),
            ("Chopped almonds", 20.0, "g", None),
        ],
    ),
    build_recipe(
        name="Protein Cheesecake Cups",
        category="Desert",
        description="No-bake cheesecake cups made creamy with Greek yogurt and whey protein.",
        instructions=[
            "Whisk yogurt with whey protein, honey, and vanilla until smooth.",
            "Stir in almond flour to thicken.",
            "Spoon into cups and chill, topping with berries before serving.",
        ],
        servings=4,
        image_url="https://images.pexels.com/photos/4109952/pexels-photo-4109952.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=15,
        cook_minutes=0,
        review_count=81,
        is_popular=True,
        ingredients=[
            ("Greek yogurt", 200.0, "g", "Room temperature."),
            ("Vanilla whey protein", 1.0, "scoop", None),
            ("Honey", 25.0, "g", None),
            ("Almond flour", 40.0, "g", None),
            ("Mixed berries", 80.0, "g", "For topping."),
        ],
    ),
    build_recipe(
        name="Mango Lime Sorbet",
        category="Desert",
        description="A dairy-free frozen sorbet with bright mango and zesty lime.",
        instructions=[
            "Blend mango with coconut milk, honey, and lime juice until silky.",
            "Churn or freeze, stirring occasionally, until scoopable.",
            "Serve immediately or store frozen for up to one week.",
        ],
        servings=4,
        image_url="https://images.pexels.com/photos/775031/pexels-photo-775031.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=10,
        cook_minutes=0,
        review_count=60,
        is_popular=False,
        ingredients=[
            ("Mango", 250.0, "g", "Frozen chunks work well."),
            ("Coconut milk", 100.0, "ml", None),
            ("Honey", 30.0, "g", None),
            ("Lime juice", 20.0, "ml", None),
        ],
    ),
    # Beverage
    build_recipe(
        name="Green Detox Smoothie",
        category="Beverage",
        description="A refreshing blend of leafy greens, citrus, and fiber-rich fruit for hydration and recovery.",
        instructions=[
            "Add all ingredients to a high-speed blender.",
            "Blend until completely smooth, adding extra water if needed.",
            "Serve immediately over ice for the crispest flavor.",
        ],
        servings=1,
        image_url="https://images.unsplash.com/photo-1588857756087-281f8cceb865?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=984&q=80",
        prep_minutes=5,
        cook_minutes=0,
        review_count=112,
        is_popular=False,
        ingredients=[
            ("Spinach", 60.0, "g", None),
            ("Kale", 50.0, "g", "Remove tough stems."),
            ("Green apple", 120.0, "g", "Core and chop."),
            ("Cucumber", 100.0, "g", "Peeled if waxed."),
            ("Lemon juice", 15.0, "ml", None),
            ("Ginger", 10.0, "g", "Grate before blending."),
            ("Water", 200.0, "ml", "Chilled."),
        ],
    ),
    build_recipe(
        name="Chocolate Recovery Shake",
        category="Beverage",
        description="A post-workout shake with protein, carbs, and healthy fats for recovery.",
        instructions=[
            "Combine almond milk, banana, cocoa, and protein in a blender.",
            "Blend until smooth.",
            "Add peanut butter and blend briefly to incorporate.",
        ],
        servings=1,
        image_url="https://images.pexels.com/photos/5926393/pexels-photo-5926393.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=5,
        cook_minutes=0,
        review_count=94,
        is_popular=True,
        ingredients=[
            ("Unsweetened almond milk", 300.0, "ml", None),
            ("Banana", 120.0, "g", "Frozen for thickness."),
            ("Cocoa powder", 15.0, "g", None),
            ("Vanilla whey protein", 1.0, "scoop", None),
            ("Peanut butter", 30.0, "g", None),
        ],
    ),
    build_recipe(
        name="Beet Citrus Booster",
        category="Beverage",
        description="A vibrant juice packed with beets, carrots, and citrus for natural energy.",
        instructions=[
            "Blend beet, carrot, and ginger with orange juice.",
            "Strain if desired for a smoother texture.",
            "Stir in lemon juice and water before serving.",
        ],
        servings=2,
        image_url="https://images.pexels.com/photos/2280551/pexels-photo-2280551.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=8,
        cook_minutes=0,
        review_count=58,
        is_popular=False,
        ingredients=[
            ("Beet", 120.0, "g", "Peeled."),
            ("Carrot", 100.0, "g", "Roughly chopped."),
            ("Orange juice", 200.0, "ml", "Fresh squeezed."),
            ("Ginger", 8.0, "g", None),
            ("Lemon juice", 15.0, "ml", None),
            ("Water", 100.0, "ml", None),
        ],
    ),
    build_recipe(
        name="Matcha Protein Latte",
        category="Beverage",
        description="A creamy matcha latte fortified with whey protein for a steady energy boost.",
        instructions=[
            "Heat almond milk until steaming but not boiling.",
            "Whisk matcha with a splash of milk to form a paste.",
            "Blend remaining milk with matcha, protein, and honey until frothy.",
        ],
        servings=1,
        image_url="https://images.pexels.com/photos/1028716/pexels-photo-1028716.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=6,
        cook_minutes=2,
        review_count=65,
        is_popular=False,
        ingredients=[
            ("Unsweetened almond milk", 250.0, "ml", None),
            ("Matcha powder", 5.0, "g", "Sift to avoid clumps."),
            ("Vanilla whey protein", 0.5, "scoop", None),
            ("Honey", 15.0, "g", None),
        ],
    ),
    build_recipe(
        name="Berry Electrolyte Refresher",
        category="Beverage",
        description="A hydrating drink with berries, coconut water, and chia for natural electrolytes.",
        instructions=[
            "Muddle berries with honey and lemon juice in a pitcher.",
            "Stir in coconut water and chia seeds.",
            "Chill for 10 minutes before serving to let the chia hydrate.",
        ],
        servings=2,
        image_url="https://images.pexels.com/photos/1105166/pexels-photo-1105166.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        prep_minutes=10,
        cook_minutes=0,
        review_count=52,
        is_popular=False,
        ingredients=[
            ("Mixed berries", 120.0, "g", "Lightly crushed."),
            ("Honey", 15.0, "g", None),
            ("Lemon juice", 15.0, "ml", None),
            ("Coconut water", 300.0, "ml", None),
            ("Chia seeds", 12.0, "g", None),
        ],
    ),
]


def seed_database() -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(":memory:") as conn:
        cursor = conn.cursor()
        cursor.executescript(SCHEMA)

        for idx, (name, description) in enumerate(CATEGORY_DESCRIPTIONS.items(), start=1):
            cursor.execute(
                "INSERT INTO categories(id, name, description) VALUES (?, ?, ?)",
                (idx, name, description),
            )

        ingredient_ids: Dict[str, int] = {}
        for idx, ingredient in enumerate(INGREDIENT_CATALOG.values(), start=1):
            ingredient_ids[ingredient.name] = idx
            cursor.execute(
                """
                INSERT INTO ingredients(id, name, default_unit, calories_per_unit, protein_per_unit, fat_per_unit, carbs_per_unit)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    idx,
                    ingredient.name,
                    ingredient.default_unit,
                    ingredient.calories_per_unit,
                    ingredient.protein_per_unit,
                    ingredient.fat_per_unit,
                    ingredient.carbs_per_unit,
                ),
            )

        for recipe_idx, recipe in enumerate(RECIPES, start=1):
            per_serving = recipe.per_serving()
            category_id = list(CATEGORY_DESCRIPTIONS).index(recipe.category) + 1
            cursor.execute(
                """
                INSERT INTO recipes(
                    id, category_id, name, description, instructions, servings,
                    calories_per_serving, protein_per_serving, fat_per_serving, carbs_per_serving,
                    image_url, prep_minutes, cook_minutes, review_count, is_popular
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    recipe_idx,
                    category_id,
                    recipe.name,
                    recipe.description,
                    recipe.instructions,
                    recipe.servings,
                    *per_serving,
                    recipe.image_url,
                    recipe.prep_minutes,
                    recipe.cook_minutes,
                    recipe.review_count,
                    1 if recipe.is_popular else 0,
                ),
            )

            for row in recipe.ingredient_rows:
                cursor.execute(
                    """
                    INSERT INTO recipe_ingredients(
                        recipe_id, ingredient_id, quantity, unit, calories, protein, fat, carbs, notes
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        recipe_idx,
                        ingredient_ids[row["ingredient"]],
                        row["quantity"],
                        row["unit"],
                        row["calories"],
                        row["protein"],
                        row["fat"],
                        row["carbs"],
                        row["notes"],
                    ),
                )

        conn.commit()

        schema_statements: List[str] = []
        for raw_statement in SCHEMA.split(';'):
            cleaned = raw_statement.strip()
            if not cleaned or cleaned.upper() == 'PRAGMA FOREIGN_KEYS = ON':
                continue
            schema_statements.append(cleaned)

        insert_statements: Dict[str, List[str]] = {
            'categories': [],
            'ingredients': [],
            'recipes': [],
            'recipe_ingredients': [],
        }

        for raw_statement in conn.iterdump():
            statement = raw_statement.strip()
            if not statement or statement in {'BEGIN TRANSACTION;', 'COMMIT;'}:
                continue

            upper = statement.upper()
            if upper.startswith('INSERT INTO "CATEGORIES"'):
                insert_statements['categories'].append(statement)
            elif upper.startswith('INSERT INTO "INGREDIENTS"'):
                insert_statements['ingredients'].append(statement)
            elif upper.startswith('INSERT INTO "RECIPES"'):
                insert_statements['recipes'].append(statement)
            elif upper.startswith('INSERT INTO "RECIPE_INGREDIENTS"'):
                insert_statements['recipe_ingredients'].append(statement)

        dump_lines: List[str] = ['PRAGMA foreign_keys=ON;', 'BEGIN TRANSACTION;']
        dump_lines.extend(f"{statement};" for statement in schema_statements)
        for table in ('categories', 'ingredients', 'recipes', 'recipe_ingredients'):
            dump_lines.extend(insert_statements[table])
        dump_lines.append('COMMIT;')

    OUTPUT_PATH.write_text('\n'.join(dump_lines) + '\n', encoding='utf-8')
    print(f"Seeded SQL dump at {OUTPUT_PATH}")


if __name__ == "__main__":
    seed_database()
