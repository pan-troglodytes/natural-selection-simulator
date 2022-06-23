# natural selection simulator

natural selection simulator (nss) is a 3d zero player game where rabbits compete for food.
rabbits consume energy as they live and it can only be recovered by eating the available food, only the fittest will survive and pass on their traits. 
users can manipulate different aspects of the simulation such as the rabbits traits and the structure of the terrain they hop on

## screenshots
[![bunny](https://raw.githubusercontent.com/pan-troglodytes/natural-selection-simulator/master/screenshots/bunny01.png)](bunny)
[![bunny](https://raw.githubusercontent.com/pan-troglodytes/natural-selection-simulator/master/screenshots/bunny02.png)](bunny)
[![bunny](https://raw.githubusercontent.com/pan-troglodytes/natural-selection-simulator/master/screenshots/bunny03.png)](bunny)

## build

use the export feature in the godot editor

you can save the binary anywhere, like for example:
```
$HOME/software/natural-selection-simulator/bin
```

## add binary to PATH variable. 

### gnu/linux, macos:
```
PATH=$PATH:$HOME/software/natural-selection-simulator/bin

```
+ the path you need to enter depends on where you saved your binary
+ execute above code in a terminal to add it temporarily
+ or append it to ~/.bashrc (or equivalent file) to add it persistently

## usage

attributes defined by the user are done so with command line arguments, e.g (assuming the binary name is 'nss'):

```
nss \
--terrain amplitude=5 heightMap=$HOME/Pictures/nss/textures/terrain/whirl300.png \
--plants energyMin=60 energyMax=70 spawnDelay=.3 \
--colony quantity=50 x=0,300 z=0,300 ageMax=30 hopForceForwards=5,15 hopForceUp=5,15 wanderRange=40,60 reproductiveCost=20,30 reproductiveThreshold=30,40 greed=30,50 mutationChance=35 mutationPotency=.3 species=1 coat=$HOME/Pictures/nss/textures/coat/coat-refined.png baseColour=147.107.84 patternColour=230.214.222
```
any number of instances of ``--colony`` can be added

for integer values a single value can be given or a range of values, separated by a comma, where an integer in that range is randomly selected for each colony member 

it is advisable to move the ``textures`` directory to somewhere you will remember, like your Pictures directory, by making a new directory and move it there, e.g:

```
mkdir $HOME/Pictures/nss
```
```
cp -r $HOME/software/natural-selection-simulator/textures $HOME/Pictures/nss
```

## mutable traits
	
### quantity

number of rabbits in the colony

### x

starting x position of rabbits

### z

starting z position of rabbits (y value is up and down, and will be just above the highest point of terrain they are assigned to)

### ageMax

the age of the rabbits death, a hop ages the rabbit once

### hopForceForwards

how much the rabbit can hop forwards

### hopForceUp

how much the rabbit can hop up

### wanderRange

when a rabbit cant find a mate or food, it will randomly turn within a range of plus and minus the wanderRange (note that in the given example: wanderRange=40,60. the wander range does not range from 40 to 60 degrees, but rather each rabbit gets a value from the range, for example 47, where its wander range will be -47 to 47 degrees)

### reproductiveCost 

how much energy a rabbit spends to reproduce

### reproductiveThreshold

how much energy is needed before it *can* search for a mate

### greed

how much energy is needed before it *will* actually start searching for a mate. the rabbit will search for a mate when its energy is >= reproductiveThreshold + greed. it will continue searching for mates until its energy is < reproductiveThreshold
## non-mutable traits

### mutationChance

the % chance of a rabbits trait mutating upon birth 

### mutationPotency

the multiplier for how much the trait will increase or decrease

### species

an integer to group rabbits into distinct species. rabbits can only reproduce within their own species

### coat

the path to a texture which describes where colours should be (not what they are). the texture should consist of black and any other colour pixels

### baseColour

the colour to replace the black pixels of the texture

### patternColour

the colour to replace the all other colour pixels of the texture (colours are applied dynamically this way so that children can inherit different colours from their parents)

## saving presets

it can be hard to type the entire command in the terminal, it can help to save the commands into files and then execute their contents, for example, with bash:

### save commands

```
echo "nss \
--terrain amplitude=5 heightMap=$HOME/Pictures/nss/textures/terrain/whirl300.png \
--plants energyMin=60 energyMax=70 spawnDelay=.3 \
--colony quantity=50 x=0,300 z=0,300 ageMax=30 hopForceForwards=5,15 hopForceUp=5,15 wanderRange=40,60 reproductiveCost=20,30 reproductiveThreshold=30,40 greed=30,50 mutationChance=35 mutationPotency=.3 species=1 coat=$HOME/Pictures/nss/textures/coat/coat-refined.png baseColour=147.107.84 patternColour=230.214.222" \
> $HOME/Pictures/nss/nss-preset-01.txt

```

in this example the preset is saved in the previously created nss/ directory in Pictures/

### execute preset

```
$(cat $HOME/Pictures/nss-preset-01.txt)
```

### edit preset

presets are helpful as it can be easier to edit the values in a text editor:

```
nano $HOME/Pictures/nss/nss-preset-01.txt
```
