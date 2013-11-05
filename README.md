# Pacman

Goal: Understanding better functional programming.

Elixir Berlin meetup: 05/11/2013.

![](http://www.wired.com/images/article/full/2008/07/pacman_500px.jpg)

## Getting started.

1. Fork this project.
2. Create a branch with your name.
3. Once happy submit a pull request.

## ASCII Pacman Challenge

Pacman finds himself in a grid filled with monsters.

Oh no!

Will he be able to eat all the dots on the board before the monsters eat him?

For this challnege we are concern with the transformations required on a board state and 
less on the pretty graphics or user interaction.

This problem can be taken as far as you would like. Don't expect to complete everything.

Here is a guideline for what the game needs:

 * pacman is on a grid filled with dots
 * pacman has a direction
 * pacman moves on each tick
 * user can rotate pacman
 * pacman eats dots
 * pacman wraps around 
 * pacman stops on wall
 * pacman will not rotate into a wall
 * game score (levels completed, number of dots eaten in this level)
 * monsters...
 * levels
 * animate pacman eating (mouth opens and closes)

## Questions.

Some questions and thoughts to get you started.

1. How do we represent the grid?
2. How do we indicate where pacman is?
3. How do we indicate where dots are?
4. How does pacman eat dots.
