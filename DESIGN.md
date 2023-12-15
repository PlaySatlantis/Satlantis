# Satlantis Design Draft
This design draft outlines the purpose, general structure, and implementation goals for the Satlantis Minetest game and migration. It covers gameplay elements, server infrastructure, design requirements, and more.

- [Satlantis Design Draft](#satlantis-design-draft)
  - [Satlantis Minecraft](#satlantis-minecraft)
    - [Purpose](#purpose)
    - [Economic Model](#economic-model)
      - [Products](#products)
      - [ASICs](#asics)
      - [Quests](#quests)
      - [Trade](#trade)
      - [Sponsors](#sponsors)
    - [World](#world)
      - [Central Hub](#central-hub)
      - [The Mines](#the-mines)
      - [The Overworld](#the-overworld)
    - [Features](#features)
      - [Minecraft Tweaks](#minecraft-tweaks)
      - [Load Spread](#load-spread)
      - [Other Noteworthy Plugins](#other-noteworthy-plugins)
  - [Satlantis Minetest](#satlantis-minetest)
    - [Setting](#setting)
      - [Motherships](#motherships)
      - [Skyships](#skyships)
      - [Planets](#planets)
        - [Resource Planets](#resource-planets)
        - [The Nether Realm](#the-nether-realm)
        - [The Ethereal Realm](#the-ethereal-realm)
        - [Planet Discovery](#planet-discovery)
    - [Implementations](#implementations)
      - [Content](#content)
      - [Planets](#planets-1)
      - [Skyships](#skyships-1)
      - [Crypto](#crypto)
    - [Roadmap](#roadmap)
      - [Prototype](#prototype)
      - [MVP](#mvp)
      - [V1](#v1)
      - [V2](#v2)

## Satlantis Minecraft
### Purpose
The Satlantis Minecraft server operates as a relatively standard survival-ish server with the exception of regenerating resources, mini-games, and additional tweaks. The server makes use of *Bitcoin* (specifically the *Satoshi* "sats" subunit) to share profits with its players from any purchasable items, including cosemetics and perks. This currency can also be used between players in-game.

### Economic Model
#### Balances
Players have an in-game account with a balance funded by Satoshi. Players transfer money from their bitcoin wallet through *Zebedee* to the server wallet, increasing their in-game balance. This balance is used for in-game transactions. Their balance can also be withdrawn from in-game to their wallet once again. 

#### Products
Players may purchase products from the server including (but not limited to): Player cosmetics, premium quests, extra materials, and world adjustments. When a purchase is made, 50% of the revenue is added to a community fund pool. 1/144 of the pool is distributed to players every 10 minutes ("100%" over the course of a day, new additions and diminishing fractions notwithstanding.) The portion a player receives depends on their hashrate, accumulated from active *ASIC* blocks fueled by that player.

#### ASICs
ASIC chips (Application-Specific Integrated Circuit) are modern hardware for crypto-mining. Satlantis includes a custom *ASIC* block which may be fueled with emeralds. It is obtained by leveling up battle passes after completing quests, or purchasing from the server or other players. A fueled ASIC as a specific hashrate defined by its generation (analogous to hardware technology generations). The total active hashrate a player has relative to the total server hashrate (sum of all player hashrates) is the percentage of the fund pool they receive during payout. The fuel consumption rate of an ASIC depends on the generation.

#### Quests
*Battle passes* are provided to players every season (1-2 months) which include daily or weekly quests. Completing a quest grants points, and every 150 points upgrades the battle pass and grants a reward (such as ASICs or other items). The available quests and rewards can be increased by purchasing a premium battle pass from the server. The pass level and rewards are refreshed each season.

Quests may be anything, from collecting a certain number of resources, killing a certain amount of enemies, or completing some mini-game challenges.

#### Trade
Players can sell items in an auction house at a fixed price (sats) for other players to purchase. Players may also send sats directly via a command when bartering other items. Item-to-item barter is also still possible (of course).

#### Sponsors
Sponsors may contribute to the fund pool in return for in-world product placements, advertisements, affiliate links, purchase interfaces, etc.

### World
#### Central Hub
The Central Hub of the server is where players spawn, trade items, and travel to community locations. Various stats and information is also presented in this area.

#### The Mines
The mines are a community locale for mining ores. Only the ores can be broken, and eventually replenish. The upper level of the mines is easily traversed, with less available ore. The lower levels are more difficult to traverse (requiring parkour or other means of travel) but provide rarer materials.

#### The Overworld
The overworld outside is a mostly-standard survival landscape. The world is limited to ~10Km in each direction, and was created using World Painter. Players may be teleported to a random position in the world from a portal in the Central Hub.

### Features
#### Minecraft Tweaks
Satlantis has changed the following vanilla Minecraft features:
* Mob spawn rate is heavily reduced
* Redstone is not available
* Villagers are not available (nor are villages)

#### Load Spread
The server aims to support at least 100 players concurrently by utilizing multiple connected server instances.

#### Other Noteworthy Plugins
* Chunk land claim
* Player clans
* Chat channels
* Server map
* Shops
* WorldEdit
* Stripe integration
* Zebedee integration
* Chess

## Satlantis Minetest
Satlantis aims to migrate most core ideas to the Minetest engine to take advantage of creative freedom (lack of EULA) and flexible features. Some Minecraft content will be migrated 1:1, with exceptions where engine capabilities may differ and where improvements can be made. Much of the server structure will be reorganized to fit a different theme.

Satlantis Minetest ("Satlantest") will be designed as a game targeting Minetest 5.8.0 or newer and be freely licensed. The new thematic setting for the server is outlined below as the most outstanding change. Technical implementation details follow.

### Setting
Satlantest will use an outer-space setting focused on space exploration and scifi mechanics. Locales will be converted to planets which players may explore. Player hubs and properties will be focused around ships which can be built by players.

This setting provides easy decentralization, modularization, and load-balancing.

#### Motherships
The *M.S. Satlantis* is the main hub. It is a large space station where all players start out. The mothership has community trade centers, connections to nearby resource planets, events, and city properties. There are no natural resources on motherships, but motherships will trade joules for resources.

Motherships have ferries to a limited selection of nearby resource planets. Motherships may also have tasks available to gain points/money. Players can purchase spacestation starter kits at motherships.

#### Space Stations
Space stations are player-built colonies which act as the home for each player. They are a small platform at their core which players can build upon. They start at a certain size and may be upgraded.

Space stations must be purchased from a mothership at a high price (the first one is "free").

Players can use their space stations to store items and ships.

#### Ships
Shuttles are used to move between motherships, nearby planets, and space stations. They are free to use, but cant go everywhere.

Players may purchase/build their own ships to explore and do more travelling. This idea will be expanded later.

#### Planets
Various planets are scattered throughout the galaxy. Some planets are dedicated to resources, some to realestate, and some are specialized realms that take extra resources to travel to.

##### Resource Planets
Resource planets are dedicated to 1 or 2 resources at most, with spaceports acting as the area for gathering regenerating resources. The rest of the planet is also available for realestate.

Resource planets always have habitable zones. Some resource planets may have uninhabitable zones with much cheaper land. Making a planet habitable could be a purchase option.

##### The Nether Realm
This is the analog to Minecraft's Nether (fortunately, "Nether" is Greek). Planet 616 is the planet of The Beast, where players may fight demons and The Nether Beast. Dark Magic is prevalent on this planet. The outer shell of the planet is mostly volcanoes and magma. Lifeforms exist in the core of the planet. Due to the hostile nature of the planet, it has no spaceports and must be traversed manually.

##### The Ethereal Realm
This is an analog to Minecraft's End, and the antithesis to dark realms. The gateway to the Aether is located in a nebula somewhere probably. Within lies the Ethereal Dragon as well as a network of gateways through spacetime. This is how players may unlock personal fast-travel (similar to Minecraft Nether portals). This part will be refined later.

##### Planet Discovery
Given enough funds, players may choose to "discover a new planet", where a new planet is generated which they may choose to inhabit and/or sell.

### Implementations
#### Content
Various blocks and items from Minetest Game will be extracted to make up a bulk of the Minecraft-like content. Some extra mods may be included to provide extra building materials and similar variety to Minecraft. Some mods may be made from scratch to take advantage of new engine features or better implementations.
Content missing from MTG:
* Baked clay
* Extra stones
* Painted tiles
* Armor
* Bows
* Nether
* Aether
* Mobs
* Readable signs
* Skins

#### Planets
Each planet will be zoned into a section set aside for that planet. Planets will not be very large, so many can be fit in one Minetest map. This will include motherships, which count as small planets.

Planets may be procedurally generated using mapgen, but pre-generated for mapgen costs. 

Possible planet mechanic: When reaching the edge of a planetoid, the player could be teleported to the other side to simulate a sphere. There are many visual issues with this, however.

#### Skyships
A dedicated area of the world will be reserved for player skyships. Skyships never physically move and stay in assigned cels. Layers of the world will be reserved for various sizes of ship. Ship sizes may be something like 256x, 512x, 1024x. A central control module can be moved to any point in the ship, and is used to control the ship. More modules could be purchased?

#### Crypto
Zebedee should be relatively easy to integrate using the REST API. ASICs will be linked to a separate server running calulations.
