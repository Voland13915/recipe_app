PRAGMA foreign_keys=ON;
BEGIN TRANSACTION;
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
INSERT INTO "categories" VALUES(1,'Breakfast','Quick meals to jump-start the morning with balanced macros.');
INSERT INTO "categories" VALUES(2,'Lunch','Midday plates designed to refuel with a mix of carbs, protein, and healthy fats.');
INSERT INTO "categories" VALUES(3,'Dinner','Heartier entrees that keep macro targets on track without sacrificing flavor.');
INSERT INTO "categories" VALUES(4,'Snack','Grab-and-go bites that satisfy between meals while supporting macro goals.');
INSERT INTO "categories" VALUES(5,'Desert','Sweet treats engineered with mindful macro and calorie targets.');
INSERT INTO "categories" VALUES(6,'Beverage','Smoothies and drinks that deliver hydration and nutrients in one serving.');
INSERT INTO "ingredients" VALUES(1,'Rolled oats','g',3.89,0.169,0.069,0.663);
INSERT INTO "ingredients" VALUES(2,'Unsweetened almond milk','ml',0.15,0.006,0.013,0.007);
INSERT INTO "ingredients" VALUES(3,'Chia seeds','g',4.86,0.17,0.31,0.42);
INSERT INTO "ingredients" VALUES(4,'Banana','g',0.89,0.011,0.003,0.23);
INSERT INTO "ingredients" VALUES(5,'Vanilla whey protein','scoop',120.0,24.0,1.5,3.0);
INSERT INTO "ingredients" VALUES(6,'Quinoa','g',3.68,0.14,0.06,0.64);
INSERT INTO "ingredients" VALUES(7,'Cherry tomatoes','g',0.18,0.009,0.002,0.039);
INSERT INTO "ingredients" VALUES(8,'Cucumber','g',0.16,0.007,0.001,0.036);
INSERT INTO "ingredients" VALUES(9,'Chickpeas','g',1.64,0.089,0.027,0.27);
INSERT INTO "ingredients" VALUES(10,'Feta cheese','g',2.64,0.14,0.21,0.04);
INSERT INTO "ingredients" VALUES(11,'Olive oil','ml',8.84,0.0,0.998,0.0);
INSERT INTO "ingredients" VALUES(12,'Salmon fillet','g',2.08,0.2,0.13,0.0);
INSERT INTO "ingredients" VALUES(13,'Sweet potato','g',0.86,0.016,0.003,0.2);
INSERT INTO "ingredients" VALUES(14,'Broccoli florets','g',0.34,0.028,0.004,0.07);
INSERT INTO "ingredients" VALUES(15,'Garlic','g',1.49,0.062,0.005,0.33);
INSERT INTO "ingredients" VALUES(16,'Lemon juice','ml',0.22,0.004,0.0,0.006);
INSERT INTO "ingredients" VALUES(17,'Greek yogurt','g',0.59,0.1,0.029,0.036);
INSERT INTO "ingredients" VALUES(18,'Mixed berries','g',0.57,0.007,0.003,0.14);
INSERT INTO "ingredients" VALUES(19,'Honey','g',3.04,0.0,0.0,0.82);
INSERT INTO "ingredients" VALUES(20,'Granola','g',4.71,0.08,0.18,0.6);
INSERT INTO "ingredients" VALUES(21,'Chopped almonds','g',5.75,0.212,0.493,0.214);
INSERT INTO "ingredients" VALUES(22,'Avocado','g',1.6,0.02,0.15,0.09);
INSERT INTO "ingredients" VALUES(23,'Cocoa powder','g',2.28,0.19,0.14,0.58);
INSERT INTO "ingredients" VALUES(24,'Maple syrup','g',2.6,0.0,0.0,0.67);
INSERT INTO "ingredients" VALUES(25,'Coconut milk','ml',0.75,0.007,0.076,0.009);
INSERT INTO "ingredients" VALUES(26,'Dark chocolate (70%)','g',5.98,0.08,0.43,0.46);
INSERT INTO "ingredients" VALUES(27,'Vanilla extract','ml',2.88,0.0,0.0,0.13);
INSERT INTO "ingredients" VALUES(28,'Spinach','g',0.23,0.029,0.004,0.036);
INSERT INTO "ingredients" VALUES(29,'Kale','g',0.35,0.029,0.005,0.07);
INSERT INTO "ingredients" VALUES(30,'Green apple','g',0.52,0.003,0.002,0.14);
INSERT INTO "ingredients" VALUES(31,'Ginger','g',0.8,0.018,0.007,0.18);
INSERT INTO "ingredients" VALUES(32,'Water','ml',0.0,0.0,0.0,0.0);
INSERT INTO "ingredients" VALUES(33,'Egg','g',1.55,0.13,0.11,0.01);
INSERT INTO "ingredients" VALUES(34,'Red bell pepper','g',0.31,0.01,0.003,0.06);
INSERT INTO "ingredients" VALUES(35,'Baking powder','g',0.53,0.0,0.0,0.27);
INSERT INTO "ingredients" VALUES(36,'Smoked salmon','g',1.17,0.18,0.04,0.0);
INSERT INTO "ingredients" VALUES(37,'Whole grain bread','slice',70.0,3.6,1.1,12.0);
INSERT INTO "ingredients" VALUES(38,'Chicken breast','g',1.65,0.31,0.037,0.0);
INSERT INTO "ingredients" VALUES(39,'Whole wheat tortilla','piece',130.0,4.0,3.5,22.0);
INSERT INTO "ingredients" VALUES(40,'Cooked lentils','g',1.16,0.09,0.004,0.2);
INSERT INTO "ingredients" VALUES(41,'Carrot','g',0.41,0.009,0.002,0.095);
INSERT INTO "ingredients" VALUES(42,'Turkey breast','g',1.35,0.29,0.016,0.0);
INSERT INTO "ingredients" VALUES(43,'Firm tofu','g',0.76,0.08,0.048,0.018);
INSERT INTO "ingredients" VALUES(44,'Brown rice','g',1.11,0.024,0.009,0.23);
INSERT INTO "ingredients" VALUES(45,'Soy sauce','ml',0.53,0.008,0.0,0.1);
INSERT INTO "ingredients" VALUES(46,'Sesame oil','ml',8.84,0.0,0.998,0.0);
INSERT INTO "ingredients" VALUES(47,'Ground turkey','g',1.6,0.23,0.09,0.0);
INSERT INTO "ingredients" VALUES(48,'Zucchini','g',0.17,0.012,0.003,0.035);
INSERT INTO "ingredients" VALUES(49,'Tomato sauce','g',0.29,0.013,0.008,0.06);
INSERT INTO "ingredients" VALUES(50,'Parmesan cheese','g',4.31,0.38,0.29,0.04);
INSERT INTO "ingredients" VALUES(51,'Flank steak','g',2.0,0.26,0.11,0.0);
INSERT INTO "ingredients" VALUES(52,'Mushrooms','g',0.22,0.03,0.003,0.033);
INSERT INTO "ingredients" VALUES(53,'Miso paste','g',1.98,0.12,0.06,0.26);
INSERT INTO "ingredients" VALUES(54,'Cod','g',0.82,0.18,0.007,0.0);
INSERT INTO "ingredients" VALUES(55,'Bok choy','g',0.13,0.009,0.002,0.021);
INSERT INTO "ingredients" VALUES(56,'Curry paste','g',1.6,0.03,0.09,0.17);
INSERT INTO "ingredients" VALUES(57,'Peanut butter','g',5.9,0.25,0.5,0.2);
INSERT INTO "ingredients" VALUES(58,'Hummus','g',1.66,0.075,0.089,0.142);
INSERT INTO "ingredients" VALUES(59,'Paprika','g',2.82,0.14,0.13,0.54);
INSERT INTO "ingredients" VALUES(60,'Garlic powder','g',3.3,0.17,0.01,0.73);
INSERT INTO "ingredients" VALUES(61,'Gelatin','g',3.23,0.82,0.0,0.0);
INSERT INTO "ingredients" VALUES(62,'Cinnamon','g',2.47,0.04,0.012,0.81);
INSERT INTO "ingredients" VALUES(63,'Almond flour','g',5.7,0.21,0.5,0.21);
INSERT INTO "ingredients" VALUES(64,'Mango','g',0.6,0.009,0.004,0.15);
INSERT INTO "ingredients" VALUES(65,'Lime juice','ml',0.25,0.004,0.0,0.008);
INSERT INTO "ingredients" VALUES(66,'Beet','g',0.43,0.016,0.002,0.096);
INSERT INTO "ingredients" VALUES(67,'Orange juice','ml',0.45,0.007,0.0,0.11);
INSERT INTO "ingredients" VALUES(68,'Matcha powder','g',3.24,0.31,0.05,0.38);
INSERT INTO "ingredients" VALUES(69,'Coconut water','ml',0.19,0.004,0.0,0.044);
INSERT INTO "recipes" VALUES(1,1,'Protein Oatmeal Bowl','Creamy oats layered with fruit, healthy fats, and a protein boost to anchor the morning.','1. Bring the almond milk to a gentle simmer and stir in the oats.
2. Cook for 5 minutes until thickened, then fold in chia seeds and whey protein.
3. Transfer to bowls, top with sliced banana, and finish with remaining toppings.',2,314.55,21.3,7.54,43.51,'https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',10.0,5.0,128.0,1);
INSERT INTO "recipes" VALUES(2,1,'Veggie Egg Scramble','Fluffy eggs folded with colorful vegetables and tangy feta for a savory start.','1. Whisk eggs with a pinch of salt and pepper until frothy.
2. Sauté garlic, peppers, tomatoes, and spinach in olive oil until tender.
3. Pour in eggs, scramble gently, and finish with crumbled feta.',2,264.02,16.09,19.39,7.08,'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',10.0,8.0,102.0,0);
INSERT INTO "recipes" VALUES(3,1,'Greek Yogurt Pancakes','High-protein pancakes with a tender crumb and naturally sweet berry topping.','1. Blend yogurt, oats, eggs, and baking powder into a smooth batter.
2. Ladle onto a preheated skillet and cook until bubbles form and flip once.
3. Serve warm with honey drizzle and fresh berries.',3,211.55,14.77,7.6,25.47,'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',12.0,15.0,89.0,1);
INSERT INTO "recipes" VALUES(4,1,'Smoked Salmon Avocado Toast','Whole-grain toast layered with creamy avocado and protein-rich smoked salmon.','1. Toast bread slices until crisp and golden.
2. Mash avocado with lemon juice and spread evenly over toast.
3. Top with smoked salmon, yogurt dollops, and baby spinach.',2,219.0,15.15,11.04,17.79,'https://images.pexels.com/photos/5665661/pexels-photo-5665661.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',8.0,2.0,75.0,0);
INSERT INTO "recipes" VALUES(5,1,'Sweet Potato Breakfast Hash','A hearty skillet hash with caramelized sweet potatoes and soft scrambled eggs.','1. Sauté diced sweet potatoes in olive oil until tender and golden.
2. Add peppers, garlic, and spinach; cook until wilted.
3. Fold in whisked eggs and cook just until softly set.',3,230.21,10.37,11.06,23.58,'https://images.pexels.com/photos/803963/pexels-photo-803963.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',15.0,20.0,68.0,0);
INSERT INTO "recipes" VALUES(6,2,'Mediterranean Quinoa Lunch Bowl','A high-fiber grain bowl with plant protein, fresh vegetables, and tangy feta.','1. Cook quinoa according to package instructions and let it cool slightly.
2. Combine quinoa with chickpeas, tomatoes, cucumber, and feta in a large bowl.
3. Dress with olive oil and lemon juice, tossing to coat evenly before serving.',3,303.4,12.07,12.45,36.3,'https://images.pexels.com/photos/6107787/pexels-photo-6107787.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',15.0,20.0,96.0,1);
INSERT INTO "recipes" VALUES(7,2,'Grilled Chicken Power Salad','Lean grilled chicken over crisp greens with creamy avocado and citrus dressing.','1. Season chicken and grill until cooked through, then slice thinly.
2. Toss spinach, cucumber, and tomatoes in a large bowl.
3. Top with avocado and chicken, then drizzle with olive oil and lemon juice.',2,354.6,37.03,19.36,9.39,'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',15.0,14.0,110.0,1);
INSERT INTO "recipes" VALUES(8,2,'Lentil Veggie Wrap','Protein-packed lentils and crunchy vegetables wrapped in a whole wheat tortilla.','1. Warm tortillas until pliable.
2. Mix lentils with hummus, peppers, carrots, and spinach.
3. Fill each tortilla, roll tightly, and slice in half.',2,334.95,16.68,7.72,52.66,'https://images.pexels.com/photos/1640770/pexels-photo-1640770.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',12.0,5.0,64.0,0);
INSERT INTO "recipes" VALUES(9,2,'Turkey Avocado Sandwich','A satisfying layered sandwich with lean turkey, creamy avocado, and leafy greens.','1. Toast bread lightly for structure.
2. Mash avocado with a squeeze of lemon and spread on bread.
3. Layer turkey, spinach, and yogurt spread, then slice to serve.',1,455.7,47.49,17.11,33.39,'https://images.pexels.com/photos/1600711/pexels-photo-1600711.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',10.0,3.0,71.0,0);
INSERT INTO "recipes" VALUES(10,2,'Tofu Veggie Stir-Fry','Seared tofu with crisp vegetables tossed in a savory soy-sesame glaze over rice.','1. Press and cube tofu, then sear until golden on all sides.
2. Stir-fry broccoli, peppers, and mushrooms until tender-crisp.
3. Combine with tofu, soy sauce, and sesame oil; serve over warm brown rice.',3,192.4,10.34,8.06,21.94,'https://images.pexels.com/photos/3026800/pexels-photo-3026800.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',15.0,18.0,83.0,0);
INSERT INTO "recipes" VALUES(11,3,'Citrus Herb Salmon Plate','Roasted salmon with vibrant vegetables and a bright citrus glaze.','1. Preheat the oven to 200°C and line a baking sheet with parchment.
2. Toss sweet potato, broccoli, and garlic with half the olive oil and roast for 15 minutes.
3. Add salmon to the tray, brush with remaining oil and lemon juice, then roast 12 more minutes.',2,530.57,39.48,28.95,25.22,'https://images.unsplash.com/photo-1607118750694-1469a22ef45d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=987&q=80',15.0,25.0,87.0,1);
INSERT INTO "recipes" VALUES(12,3,'Turkey Meatballs with Zoodles','Lean turkey meatballs simmered in tomato sauce over zucchini noodles.','1. Mix ground turkey with egg, garlic, and parmesan; form into meatballs.
2. Sear meatballs until browned, then simmer in tomato sauce until cooked through.
3. Toss spiralized zucchini in the sauce just before serving.',3,305.47,31.65,18.34,9.31,'https://images.pexels.com/photos/3296273/pexels-photo-3296273.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',20.0,25.0,92.0,0);
INSERT INTO "recipes" VALUES(13,3,'Steak Quinoa Pilaf','Seared flank steak over herbed quinoa with mushrooms and wilted greens.','1. Cook quinoa until fluffy and set aside.
2. Sear flank steak to preferred doneness and rest before slicing.
3. Sauté mushrooms, spinach, and garlic, toss with quinoa, and top with steak.',2,517.67,42.97,24.81,32.91,'https://images.pexels.com/photos/5737249/pexels-photo-5737249.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',18.0,22.0,78.0,0);
INSERT INTO "recipes" VALUES(14,3,'Miso Cod with Bok Choy','Oven-baked cod glazed with miso and sesame, served alongside tender bok choy.','1. Whisk miso paste with sesame oil and lemon juice to form a glaze.
2. Brush over cod fillets and bake until flaky.
3. Sauté bok choy with ginger until just wilted and serve with cod.',2,233.65,32.22,7.54,8.24,'https://images.pexels.com/photos/6287529/pexels-photo-6287529.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',12.0,15.0,66.0,0);
INSERT INTO "recipes" VALUES(15,3,'Chickpea Coconut Curry','A creamy chickpea curry with sweet potato and spinach served over brown rice.','1. Sauté garlic and curry paste until fragrant.
2. Stir in sweet potato, chickpeas, and coconut milk; simmer until tender.
3. Fold in spinach and serve over warm brown rice.',4,239.88,7.77,6.42,38.89,'https://images.pexels.com/photos/1640773/pexels-photo-1640773.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',15.0,30.0,91.0,1);
INSERT INTO "recipes" VALUES(16,4,'Berry Crunch Yogurt Jar','Layered Greek yogurt parfait with berries, honey, and crunchy toppings.','1. Whisk honey into the yogurt until smooth.
2. Layer yogurt, berries, and granola in jars.
3. Top with chopped almonds just before serving for crunch.',2,218.38,13.07,9.42,25.95,'https://images.pexels.com/photos/8963959/pexels-photo-8963959.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',10.0,0.0,54.0,0);
INSERT INTO "recipes" VALUES(17,4,'Spicy Roasted Chickpeas','Crunchy roasted chickpeas coated in smoky paprika and garlic.','1. Pat chickpeas dry and toss with oil and spices.
2. Roast, shaking the pan occasionally, until crisp.
3. Cool slightly before serving for maximum crunch.',4,94.41,3.9,3.78,12.16,'https://images.pexels.com/photos/4110404/pexels-photo-4110404.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',8.0,35.0,63.0,0);
INSERT INTO "recipes" VALUES(18,4,'Peanut Butter Apple Slices','Fresh apple wedges topped with protein-rich peanut butter and chia sprinkle.','1. Slice apples into wedges and arrange on a plate.
2. Spread peanut butter over each slice.
3. Dust with chia seeds and cinnamon before serving.',2,186.37,6.13,11.72,18.11,'https://images.pexels.com/photos/1351238/pexels-photo-1351238.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',5.0,0.0,58.0,0);
INSERT INTO "recipes" VALUES(19,4,'Veggie Hummus Cups','Crunchy veggie sticks served with creamy hummus for dipping.','1. Slice cucumber, carrots, and peppers into sticks.
2. Portion hummus into small cups.
3. Serve vegetables upright in hummus cups with a squeeze of lemon.',3,72.97,2.92,2.82,9.17,'https://images.pexels.com/photos/1640775/pexels-photo-1640775.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',10.0,0.0,47.0,0);
INSERT INTO "recipes" VALUES(20,4,'Chocolate Protein Energy Bites','No-bake bites packed with oats, peanut butter, and dark chocolate chips.','1. Stir oats, peanut butter, honey, and chia seeds until evenly combined.
2. Fold in chopped dark chocolate.
3. Roll into bite-sized balls and chill to set.',4,349.2,11.72,17.92,38.79,'https://images.pexels.com/photos/1633525/pexels-photo-1633525.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',12.0,0.0,88.0,1);
INSERT INTO "recipes" VALUES(21,5,'Dark Chocolate Avocado Mousse','Silky, dairy-free dessert with heart-healthy fats and antioxidant-rich cocoa.','1. Blend avocado, coconut milk, cocoa powder, and maple syrup until smooth.
2. Add melted dark chocolate and vanilla extract; blend again until glossy.
3. Chill for at least 30 minutes before serving with optional toppings.',4,143.12,2.31,10.15,14.47,'https://images.unsplash.com/photo-1609355109553-3bb67c76b1f7?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=987&q=80',15.0,0.0,67.0,0);
INSERT INTO "recipes" VALUES(22,5,'Coconut Yogurt Panna Cotta','A light panna cotta made with coconut milk and Greek yogurt topped with berries.','1. Bloom gelatin in a small amount of coconut milk.
2. Warm remaining coconut milk with honey, then whisk in gelatin and yogurt.
3. Pour into cups, chill until set, and top with berries.',4,105.31,5.9,4.96,11.26,'https://images.pexels.com/photos/3026801/pexels-photo-3026801.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',15.0,5.0,59.0,0);
INSERT INTO "recipes" VALUES(23,5,'Baked Cinnamon Apples','Warm baked apples with a cinnamon oat crumble and nutty crunch.','1. Core and slice apples, then toss with cinnamon and maple syrup.
2. Top with oats and almonds and bake until tender.
3. Serve warm with a dollop of yogurt if desired.',3,171.49,4.02,4.42,32.05,'https://images.pexels.com/photos/4109991/pexels-photo-4109991.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',12.0,25.0,72.0,0);
INSERT INTO "recipes" VALUES(24,5,'Protein Cheesecake Cups','No-bake cheesecake cups made creamy with Greek yogurt and whey protein.','1. Whisk yogurt with whey protein, honey, and vanilla until smooth.
2. Stir in almond flour to thicken.
3. Spoon into cups and chill, topping with berries before serving.',4,146.9,13.24,6.88,12.57,'https://images.pexels.com/photos/4109952/pexels-photo-4109952.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',15.0,0.0,81.0,1);
INSERT INTO "recipes" VALUES(25,5,'Mango Lime Sorbet','A dairy-free frozen sorbet with bright mango and zesty lime.','1. Blend mango with coconut milk, honey, and lime juice until silky.
2. Churn or freeze, stirring occasionally, until scoopable.
3. Serve immediately or store frozen for up to one week.',4,80.3,0.76,2.15,15.79,'https://images.pexels.com/photos/775031/pexels-photo-775031.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',10.0,0.0,60.0,0);
INSERT INTO "recipes" VALUES(26,6,'Green Detox Smoothie','A refreshing blend of leafy greens, citrus, and fiber-rich fruit for hydration and recovery.','1. Add all ingredients to a high-speed blender.
2. Blend until completely smooth, adding extra water if needed.
3. Serve immediately over ice for the crispest flavor.',1,121.0,4.49,0.9,27.95,'https://images.unsplash.com/photo-1588857756087-281f8cceb865?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=984&q=80',5.0,0.0,112.0,0);
INSERT INTO "recipes" VALUES(27,6,'Chocolate Recovery Shake','A post-workout shake with protein, carbs, and healthy fats for recovery.','1. Combine almond milk, banana, cocoa, and protein in a blender.
2. Blend until smooth.
3. Add peanut butter and blend briefly to incorporate.',1,483.0,37.47,22.86,47.4,'https://images.pexels.com/photos/5926393/pexels-photo-5926393.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',5.0,0.0,94.0,1);
INSERT INTO "recipes" VALUES(28,6,'Beet Citrus Booster','A vibrant juice packed with beets, carrots, and citrus for natural energy.','1. Blend beet, carrot, and ginger with orange juice.
2. Strain if desired for a smoother texture.
3. Stir in lemon juice and water before serving.',2,96.15,2.21,0.25,22.27,'https://images.pexels.com/photos/2280551/pexels-photo-2280551.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',8.0,0.0,58.0,0);
INSERT INTO "recipes" VALUES(29,6,'Matcha Protein Latte','A creamy matcha latte fortified with whey protein for a steady energy boost.','1. Heat almond milk until steaming but not boiling.
2. Whisk matcha with a splash of milk to form a paste.
3. Blend remaining milk with matcha, protein, and honey until frothy.',1,159.3,15.05,4.25,17.45,'https://images.pexels.com/photos/1028716/pexels-photo-1028716.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',6.0,2.0,65.0,0);
INSERT INTO "recipes" VALUES(30,6,'Berry Electrolyte Refresher','A hydrating drink with berries, coconut water, and chia for natural electrolytes.','1. Muddle berries with honey and lemon juice in a pitcher.
2. Stir in coconut water and chia seeds.
3. Chill for 10 minutes before serving to let the chia hydrate.',2,116.31,2.07,2.04,23.71,'https://images.pexels.com/photos/1105166/pexels-photo-1105166.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',10.0,0.0,52.0,0);
INSERT INTO "recipe_ingredients" VALUES(1,1,80.0,'g',311.2,13.52,5.52,53.04,NULL);
INSERT INTO "recipe_ingredients" VALUES(1,2,240.0,'ml',36.0,1.44,3.12,1.68,'Warm but do not boil to maintain creaminess.');
INSERT INTO "recipe_ingredients" VALUES(1,3,15.0,'g',72.9,2.55,4.65,6.3,NULL);
INSERT INTO "recipe_ingredients" VALUES(1,4,100.0,'g',89.0,1.1,0.3,23.0,'Slice just before serving to prevent browning.');
INSERT INTO "recipe_ingredients" VALUES(1,5,1.0,'scoop',120.0,24.0,1.5,3.0,'Whisk in off the heat to avoid clumping.');
INSERT INTO "recipe_ingredients" VALUES(2,33,180.0,'g',279.0,23.4,19.8,1.8,'About 3 large eggs.');
INSERT INTO "recipe_ingredients" VALUES(2,11,10.0,'ml',88.4,0.0,9.98,0.0,'Heat just until shimmering.');
INSERT INTO "recipe_ingredients" VALUES(2,15,5.0,'g',7.45,0.31,0.025,1.65,'Minced.');
INSERT INTO "recipe_ingredients" VALUES(2,34,70.0,'g',21.7,0.7,0.21,4.2,'Diced.');
INSERT INTO "recipe_ingredients" VALUES(2,7,80.0,'g',14.4,0.72,0.16,3.12,'Halved.');
INSERT INTO "recipe_ingredients" VALUES(2,28,50.0,'g',11.5,1.45,0.2,1.8,'Roughly chopped.');
INSERT INTO "recipe_ingredients" VALUES(2,10,40.0,'g',105.6,5.6,8.4,1.6,'Crumbled before serving.');
INSERT INTO "recipe_ingredients" VALUES(3,17,180.0,'g',106.2,18.0,5.22,6.48,'Use thick strained yogurt.');
INSERT INTO "recipe_ingredients" VALUES(3,1,60.0,'g',233.4,10.14,4.14,39.78,'Pulse into flour if preferred.');
INSERT INTO "recipe_ingredients" VALUES(3,33,120.0,'g',186.0,15.6,13.2,1.2,'About 2 large eggs.');
INSERT INTO "recipe_ingredients" VALUES(3,35,5.0,'g',2.65,0.0,0.0,1.35,NULL);
INSERT INTO "recipe_ingredients" VALUES(3,19,20.0,'g',60.8,0.0,0.0,16.4,'Reserve half for serving.');
INSERT INTO "recipe_ingredients" VALUES(3,18,80.0,'g',45.6,0.56,0.24,11.2,'Fresh or thawed.');
INSERT INTO "recipe_ingredients" VALUES(4,37,2.0,'slice',140.0,7.2,2.2,24.0,'Toast for extra crunch.');
INSERT INTO "recipe_ingredients" VALUES(4,22,100.0,'g',160.0,2.0,15.0,9.0,'Mash with a fork.');
INSERT INTO "recipe_ingredients" VALUES(4,16,10.0,'ml',2.2,0.04,0.0,0.06,'Mix into the avocado.');
INSERT INTO "recipe_ingredients" VALUES(4,36,90.0,'g',105.3,16.2,3.6,0.0,'Slice thinly.');
INSERT INTO "recipe_ingredients" VALUES(4,17,40.0,'g',23.6,4.0,1.16,1.44,'Dollop on top.');
INSERT INTO "recipe_ingredients" VALUES(4,28,30.0,'g',6.9,0.87,0.12,1.08,'Use baby leaves.');
INSERT INTO "recipe_ingredients" VALUES(5,13,300.0,'g',258.0,4.8,0.9,60.0,'Dice into 1 cm cubes.');
INSERT INTO "recipe_ingredients" VALUES(5,11,12.0,'ml',106.08,0.0,11.976,0.0,'Divide for sautéing.');
INSERT INTO "recipe_ingredients" VALUES(5,34,80.0,'g',24.8,0.8,0.24,4.8,'Diced.');
INSERT INTO "recipe_ingredients" VALUES(5,15,6.0,'g',8.94,0.372,0.03,1.98,'Minced.');
INSERT INTO "recipe_ingredients" VALUES(5,28,60.0,'g',13.8,1.74,0.24,2.16,NULL);
INSERT INTO "recipe_ingredients" VALUES(5,33,180.0,'g',279.0,23.4,19.8,1.8,'Whisked lightly.');
INSERT INTO "recipe_ingredients" VALUES(6,6,90.0,'g',331.2,12.6,5.4,57.6,'Rinse well to remove bitterness.');
INSERT INTO "recipe_ingredients" VALUES(6,9,150.0,'g',246.0,13.35,4.05,40.5,'Use cooked or canned chickpeas, drained.');
INSERT INTO "recipe_ingredients" VALUES(6,7,120.0,'g',21.6,1.08,0.24,4.68,'Halve for easier bites.');
INSERT INTO "recipe_ingredients" VALUES(6,8,100.0,'g',16.0,0.7,0.1,3.6,'Dice into small cubes.');
INSERT INTO "recipe_ingredients" VALUES(6,10,60.0,'g',158.4,8.4,12.6,2.4,'Crumbled.');
INSERT INTO "recipe_ingredients" VALUES(6,11,15.0,'ml',132.6,0.0,14.97,0.0,NULL);
INSERT INTO "recipe_ingredients" VALUES(6,16,20.0,'ml',4.4,0.08,0.0,0.12,'Freshly squeezed for best flavor.');
INSERT INTO "recipe_ingredients" VALUES(7,38,220.0,'g',363.0,68.2,8.14,0.0,'Grill and rest before slicing.');
INSERT INTO "recipe_ingredients" VALUES(7,28,80.0,'g',18.4,2.32,0.32,2.88,NULL);
INSERT INTO "recipe_ingredients" VALUES(7,8,80.0,'g',12.8,0.56,0.08,2.88,'Sliced thin.');
INSERT INTO "recipe_ingredients" VALUES(7,7,100.0,'g',18.0,0.9,0.2,3.9,'Halved.');
INSERT INTO "recipe_ingredients" VALUES(7,22,100.0,'g',160.0,2.0,15.0,9.0,'Diced.');
INSERT INTO "recipe_ingredients" VALUES(7,11,15.0,'ml',132.6,0.0,14.97,0.0,'Whisk with lemon for dressing.');
INSERT INTO "recipe_ingredients" VALUES(7,16,20.0,'ml',4.4,0.08,0.0,0.12,NULL);
INSERT INTO "recipe_ingredients" VALUES(8,39,2.0,'piece',260.0,8.0,7.0,44.0,'Gently warm to prevent cracking.');
INSERT INTO "recipe_ingredients" VALUES(8,40,180.0,'g',208.8,16.2,0.72,36.0,'Drain well.');
INSERT INTO "recipe_ingredients" VALUES(8,58,80.0,'g',132.8,6.0,7.12,11.36,NULL);
INSERT INTO "recipe_ingredients" VALUES(8,34,70.0,'g',21.7,0.7,0.21,4.2,'Slice into strips.');
INSERT INTO "recipe_ingredients" VALUES(8,41,80.0,'g',32.8,0.72,0.16,7.6,'Julienned.');
INSERT INTO "recipe_ingredients" VALUES(8,28,60.0,'g',13.8,1.74,0.24,2.16,NULL);
INSERT INTO "recipe_ingredients" VALUES(9,37,2.0,'slice',140.0,7.2,2.2,24.0,'Toast to your liking.');
INSERT INTO "recipe_ingredients" VALUES(9,42,120.0,'g',162.0,34.8,1.92,0.0,'Thinly sliced.');
INSERT INTO "recipe_ingredients" VALUES(9,22,80.0,'g',128.0,1.6,12.0,7.2,'Mashed.');
INSERT INTO "recipe_ingredients" VALUES(9,28,30.0,'g',6.9,0.87,0.12,1.08,'Use baby leaves.');
INSERT INTO "recipe_ingredients" VALUES(9,17,30.0,'g',17.7,3.0,0.87,1.08,'Spread for tang.');
INSERT INTO "recipe_ingredients" VALUES(9,16,5.0,'ml',1.1,0.02,0.0,0.03,'Mix into the avocado.');
INSERT INTO "recipe_ingredients" VALUES(10,43,240.0,'g',182.4,19.2,11.52,4.32,'Press to remove excess moisture.');
INSERT INTO "recipe_ingredients" VALUES(10,14,120.0,'g',40.8,3.36,0.48,8.4,NULL);
INSERT INTO "recipe_ingredients" VALUES(10,34,90.0,'g',27.9,0.9,0.27,5.4,'Slice into strips.');
INSERT INTO "recipe_ingredients" VALUES(10,52,100.0,'g',22.0,3.0,0.3,3.3,'Sliced.');
INSERT INTO "recipe_ingredients" VALUES(10,45,30.0,'ml',15.9,0.24,0.0,3.0,'Add toward the end.');
INSERT INTO "recipe_ingredients" VALUES(10,46,10.0,'ml',88.4,0.0,9.98,0.0,'Drizzle for finishing flavor.');
INSERT INTO "recipe_ingredients" VALUES(10,44,180.0,'g',199.8,4.32,1.62,41.4,'Cooked.');
INSERT INTO "recipe_ingredients" VALUES(11,12,360.0,'g',748.8,72.0,46.8,0.0,'Use skin-on fillets for better moisture.');
INSERT INTO "recipe_ingredients" VALUES(11,13,200.0,'g',172.0,3.2,0.6,40.0,'Cut into 2 cm cubes.');
INSERT INTO "recipe_ingredients" VALUES(11,14,120.0,'g',40.8,3.36,0.48,8.4,NULL);
INSERT INTO "recipe_ingredients" VALUES(11,15,6.0,'g',8.94,0.372,0.03,1.98,'Thinly sliced.');
INSERT INTO "recipe_ingredients" VALUES(11,11,10.0,'ml',88.4,0.0,9.98,0.0,NULL);
INSERT INTO "recipe_ingredients" VALUES(11,16,10.0,'ml',2.2,0.04,0.0,0.06,'Drizzle over salmon before serving.');
INSERT INTO "recipe_ingredients" VALUES(12,47,300.0,'g',480.0,69.0,27.0,0.0,'Use lean 93/7.');
INSERT INTO "recipe_ingredients" VALUES(12,33,60.0,'g',93.0,7.8,6.6,0.6,'Lightly beaten.');
INSERT INTO "recipe_ingredients" VALUES(12,15,8.0,'g',11.92,0.496,0.04,2.64,'Minced.');
INSERT INTO "recipe_ingredients" VALUES(12,50,30.0,'g',129.3,11.4,8.7,1.2,'Finely grated.');
INSERT INTO "recipe_ingredients" VALUES(12,49,240.0,'g',69.6,3.12,1.92,14.4,NULL);
INSERT INTO "recipe_ingredients" VALUES(12,11,10.0,'ml',88.4,0.0,9.98,0.0,'For searing.');
INSERT INTO "recipe_ingredients" VALUES(12,48,260.0,'g',44.2,3.12,0.78,9.1,'Spiralized into noodles.');
INSERT INTO "recipe_ingredients" VALUES(13,51,260.0,'g',520.0,67.6,28.6,0.0,'Slice against the grain.');
INSERT INTO "recipe_ingredients" VALUES(13,6,90.0,'g',331.2,12.6,5.4,57.6,'Cooked in low-sodium broth if desired.');
INSERT INTO "recipe_ingredients" VALUES(13,52,100.0,'g',22.0,3.0,0.3,3.3,'Sliced.');
INSERT INTO "recipe_ingredients" VALUES(13,28,80.0,'g',18.4,2.32,0.32,2.88,NULL);
INSERT INTO "recipe_ingredients" VALUES(13,15,6.0,'g',8.94,0.372,0.03,1.98,NULL);
INSERT INTO "recipe_ingredients" VALUES(13,11,15.0,'ml',132.6,0.0,14.97,0.0,'Divide for steak and vegetables.');
INSERT INTO "recipe_ingredients" VALUES(13,16,10.0,'ml',2.2,0.04,0.0,0.06,'Finish with a squeeze.');
INSERT INTO "recipe_ingredients" VALUES(14,54,320.0,'g',262.4,57.6,2.24,0.0,'Use skinless fillets.');
INSERT INTO "recipe_ingredients" VALUES(14,53,40.0,'g',79.2,4.8,2.4,10.4,NULL);
INSERT INTO "recipe_ingredients" VALUES(14,46,10.0,'ml',88.4,0.0,9.98,0.0,NULL);
INSERT INTO "recipe_ingredients" VALUES(14,16,15.0,'ml',3.3,0.06,0.0,0.09,'Whisk into glaze.');
INSERT INTO "recipe_ingredients" VALUES(14,55,200.0,'g',26.0,1.8,0.4,4.2,'Halve lengthwise.');
INSERT INTO "recipe_ingredients" VALUES(14,31,10.0,'g',8.0,0.18,0.07,1.8,'Julienned.');
INSERT INTO "recipe_ingredients" VALUES(15,15,8.0,'g',11.92,0.496,0.04,2.64,NULL);
INSERT INTO "recipe_ingredients" VALUES(15,56,25.0,'g',40.0,0.75,2.25,4.25,'Adjust heat to taste.');
INSERT INTO "recipe_ingredients" VALUES(15,13,220.0,'g',189.2,3.52,0.66,44.0,'Diced.');
INSERT INTO "recipe_ingredients" VALUES(15,9,200.0,'g',328.0,17.8,5.4,54.0,NULL);
INSERT INTO "recipe_ingredients" VALUES(15,25,200.0,'ml',150.0,1.4,15.2,1.8,NULL);
INSERT INTO "recipe_ingredients" VALUES(15,28,80.0,'g',18.4,2.32,0.32,2.88,NULL);
INSERT INTO "recipe_ingredients" VALUES(15,44,200.0,'g',222.0,4.8,1.8,46.0,'Cooked for serving.');
INSERT INTO "recipe_ingredients" VALUES(16,17,200.0,'g',118.0,20.0,5.8,7.2,'Use 2% or 5% depending on fat goals.');
INSERT INTO "recipe_ingredients" VALUES(16,18,80.0,'g',45.6,0.56,0.24,11.2,'A mix of blueberries, raspberries, and strawberries.');
INSERT INTO "recipe_ingredients" VALUES(16,19,15.0,'g',45.6,0.0,0.0,12.3,NULL);
INSERT INTO "recipe_ingredients" VALUES(16,20,30.0,'g',141.3,2.4,5.4,18.0,'Choose a low-sugar variety.');
INSERT INTO "recipe_ingredients" VALUES(16,21,15.0,'g',86.25,3.18,7.395,3.21,'Lightly toasted.');
INSERT INTO "recipe_ingredients" VALUES(17,9,160.0,'g',262.4,14.24,4.32,43.2,'Cooked and drained.');
INSERT INTO "recipe_ingredients" VALUES(17,11,10.0,'ml',88.4,0.0,9.98,0.0,NULL);
INSERT INTO "recipe_ingredients" VALUES(17,59,6.0,'g',16.92,0.84,0.78,3.24,'Smoked for depth.');
INSERT INTO "recipe_ingredients" VALUES(17,60,3.0,'g',9.9,0.51,0.03,2.19,NULL);
INSERT INTO "recipe_ingredients" VALUES(18,30,160.0,'g',83.2,0.48,0.32,22.4,'Leave skin on for fiber.');
INSERT INTO "recipe_ingredients" VALUES(18,57,40.0,'g',236.0,10.0,20.0,8.0,'Natural style.');
INSERT INTO "recipe_ingredients" VALUES(18,3,10.0,'g',48.6,1.7,3.1,4.2,NULL);
INSERT INTO "recipe_ingredients" VALUES(18,62,2.0,'g',4.94,0.08,0.024,1.62,'Sprinkle evenly.');
INSERT INTO "recipe_ingredients" VALUES(19,8,80.0,'g',12.8,0.56,0.08,2.88,'Cut into batons.');
INSERT INTO "recipe_ingredients" VALUES(19,41,80.0,'g',32.8,0.72,0.16,7.6,'Slice into sticks.');
INSERT INTO "recipe_ingredients" VALUES(19,34,70.0,'g',21.7,0.7,0.21,4.2,'Slice into strips.');
INSERT INTO "recipe_ingredients" VALUES(19,58,90.0,'g',149.4,6.75,8.01,12.78,NULL);
INSERT INTO "recipe_ingredients" VALUES(19,16,10.0,'ml',2.2,0.04,0.0,0.06,'Drizzle over veggies.');
INSERT INTO "recipe_ingredients" VALUES(20,1,120.0,'g',466.8,20.28,8.28,79.56,NULL);
INSERT INTO "recipe_ingredients" VALUES(20,57,80.0,'g',472.0,20.0,40.0,16.0,'Creamy.');
INSERT INTO "recipe_ingredients" VALUES(20,19,40.0,'g',121.6,0.0,0.0,32.8,NULL);
INSERT INTO "recipe_ingredients" VALUES(20,3,20.0,'g',97.2,3.4,6.2,8.4,NULL);
INSERT INTO "recipe_ingredients" VALUES(20,26,40.0,'g',239.2,3.2,17.2,18.4,'Chopped.');
INSERT INTO "recipe_ingredients" VALUES(21,22,150.0,'g',240.0,3.0,22.5,13.5,'Very ripe for the smoothest texture.');
INSERT INTO "recipe_ingredients" VALUES(21,25,60.0,'ml',45.0,0.42,4.56,0.54,'Full-fat canned coconut milk.');
INSERT INTO "recipe_ingredients" VALUES(21,23,20.0,'g',45.6,3.8,2.8,11.6,NULL);
INSERT INTO "recipe_ingredients" VALUES(21,24,30.0,'g',78.0,0.0,0.0,20.1,NULL);
INSERT INTO "recipe_ingredients" VALUES(21,26,25.0,'g',149.5,2.0,10.75,11.5,'Melt gently over a bain-marie.');
INSERT INTO "recipe_ingredients" VALUES(21,27,5.0,'ml',14.4,0.0,0.0,0.65,NULL);
INSERT INTO "recipe_ingredients" VALUES(22,25,200.0,'ml',150.0,1.4,15.2,1.8,NULL);
INSERT INTO "recipe_ingredients" VALUES(22,19,30.0,'g',91.2,0.0,0.0,24.6,NULL);
INSERT INTO "recipe_ingredients" VALUES(22,61,8.0,'g',25.84,6.56,0.0,0.0,'Powdered.');
INSERT INTO "recipe_ingredients" VALUES(22,17,150.0,'g',88.5,15.0,4.35,5.4,'Room temperature.');
INSERT INTO "recipe_ingredients" VALUES(22,27,5.0,'ml',14.4,0.0,0.0,0.65,NULL);
INSERT INTO "recipe_ingredients" VALUES(22,18,90.0,'g',51.3,0.63,0.27,12.6,'For topping.');
INSERT INTO "recipe_ingredients" VALUES(23,30,300.0,'g',156.0,0.9,0.6,42.0,'Sliced.');
INSERT INTO "recipe_ingredients" VALUES(23,62,4.0,'g',9.88,0.16,0.048,3.24,NULL);
INSERT INTO "recipe_ingredients" VALUES(23,24,30.0,'g',78.0,0.0,0.0,20.1,NULL);
INSERT INTO "recipe_ingredients" VALUES(23,1,40.0,'g',155.6,6.76,2.76,26.52,NULL);
INSERT INTO "recipe_ingredients" VALUES(23,21,20.0,'g',115.0,4.24,9.86,4.28,NULL);
INSERT INTO "recipe_ingredients" VALUES(24,17,200.0,'g',118.0,20.0,5.8,7.2,'Room temperature.');
INSERT INTO "recipe_ingredients" VALUES(24,5,1.0,'scoop',120.0,24.0,1.5,3.0,NULL);
INSERT INTO "recipe_ingredients" VALUES(24,19,25.0,'g',76.0,0.0,0.0,20.5,NULL);
INSERT INTO "recipe_ingredients" VALUES(24,63,40.0,'g',228.0,8.4,20.0,8.4,NULL);
INSERT INTO "recipe_ingredients" VALUES(24,18,80.0,'g',45.6,0.56,0.24,11.2,'For topping.');
INSERT INTO "recipe_ingredients" VALUES(25,64,250.0,'g',150.0,2.25,1.0,37.5,'Frozen chunks work well.');
INSERT INTO "recipe_ingredients" VALUES(25,25,100.0,'ml',75.0,0.7,7.6,0.9,NULL);
INSERT INTO "recipe_ingredients" VALUES(25,19,30.0,'g',91.2,0.0,0.0,24.6,NULL);
INSERT INTO "recipe_ingredients" VALUES(25,65,20.0,'ml',5.0,0.08,0.0,0.16,NULL);
INSERT INTO "recipe_ingredients" VALUES(26,28,60.0,'g',13.8,1.74,0.24,2.16,NULL);
INSERT INTO "recipe_ingredients" VALUES(26,29,50.0,'g',17.5,1.45,0.25,3.5,'Remove tough stems.');
INSERT INTO "recipe_ingredients" VALUES(26,30,120.0,'g',62.4,0.36,0.24,16.8,'Core and chop.');
INSERT INTO "recipe_ingredients" VALUES(26,8,100.0,'g',16.0,0.7,0.1,3.6,'Peeled if waxed.');
INSERT INTO "recipe_ingredients" VALUES(26,16,15.0,'ml',3.3,0.06,0.0,0.09,NULL);
INSERT INTO "recipe_ingredients" VALUES(26,31,10.0,'g',8.0,0.18,0.07,1.8,'Grate before blending.');
INSERT INTO "recipe_ingredients" VALUES(26,32,200.0,'ml',0.0,0.0,0.0,0.0,'Chilled.');
INSERT INTO "recipe_ingredients" VALUES(27,2,300.0,'ml',45.0,1.8,3.9,2.1,NULL);
INSERT INTO "recipe_ingredients" VALUES(27,4,120.0,'g',106.8,1.32,0.36,27.6,'Frozen for thickness.');
INSERT INTO "recipe_ingredients" VALUES(27,23,15.0,'g',34.2,2.85,2.1,8.7,NULL);
INSERT INTO "recipe_ingredients" VALUES(27,5,1.0,'scoop',120.0,24.0,1.5,3.0,NULL);
INSERT INTO "recipe_ingredients" VALUES(27,57,30.0,'g',177.0,7.5,15.0,6.0,NULL);
INSERT INTO "recipe_ingredients" VALUES(28,66,120.0,'g',51.6,1.92,0.24,11.52,'Peeled.');
INSERT INTO "recipe_ingredients" VALUES(28,41,100.0,'g',41.0,0.9,0.2,9.5,'Roughly chopped.');
INSERT INTO "recipe_ingredients" VALUES(28,67,200.0,'ml',90.0,1.4,0.0,22.0,'Fresh squeezed.');
INSERT INTO "recipe_ingredients" VALUES(28,31,8.0,'g',6.4,0.144,0.056,1.44,NULL);
INSERT INTO "recipe_ingredients" VALUES(28,16,15.0,'ml',3.3,0.06,0.0,0.09,NULL);
INSERT INTO "recipe_ingredients" VALUES(28,32,100.0,'ml',0.0,0.0,0.0,0.0,NULL);
INSERT INTO "recipe_ingredients" VALUES(29,2,250.0,'ml',37.5,1.5,3.25,1.75,NULL);
INSERT INTO "recipe_ingredients" VALUES(29,68,5.0,'g',16.2,1.55,0.25,1.9,'Sift to avoid clumps.');
INSERT INTO "recipe_ingredients" VALUES(29,5,0.5,'scoop',60.0,12.0,0.75,1.5,NULL);
INSERT INTO "recipe_ingredients" VALUES(29,19,15.0,'g',45.6,0.0,0.0,12.3,NULL);
INSERT INTO "recipe_ingredients" VALUES(30,18,120.0,'g',68.4,0.84,0.36,16.8,'Lightly crushed.');
INSERT INTO "recipe_ingredients" VALUES(30,19,15.0,'g',45.6,0.0,0.0,12.3,NULL);
INSERT INTO "recipe_ingredients" VALUES(30,16,15.0,'ml',3.3,0.06,0.0,0.09,NULL);
INSERT INTO "recipe_ingredients" VALUES(30,69,300.0,'ml',57.0,1.2,0.0,13.2,NULL);
INSERT INTO "recipe_ingredients" VALUES(30,3,12.0,'g',58.32,2.04,3.72,5.04,NULL);
COMMIT;
