Style guide

- Use a personal voice, this wil be said in my own voice. Slightly self deprecataing enjoying of dry humor with occasional breaks. High diction.
- Let's follow a stuff made here video format, 1) tease the problem and overengineered solution, 2) Walk chronologically and build a narrative out of the solution, 3) walk through any setbacks in the process, 4) finalize the project and show the payoff to the problem in step 1
- I like hard cuts just prior to the the punchline. Giving the reader a chance to get the inside joke, but having it be a pretty low bar
- for each section I'd like you to generate a shot list, 

## Problem

I enjoy playing Factorio, but I'm not very good at it. I've got kids vying for my time, work to do, and here in the midwest, copious amounts of snow to shovel. One of my friends mocks my love for Factorio from time to time, saying isn't building and connecting systems kind like work why would you do that? If only I could take the tools that eliminate tedium from my professional side and use them to maximize Factorio endorphins.

## Goals

So let's set some goals for ourselves:

1. I want to be able to automagically create a base
1. I want to be able to correct things that I break
1. No making research that's got to be done by me

## So is this even possible?

Well the author of factorio (Kavorik) has kindly provided support for RAC (Remote Access Control) which allows you to send commands to Facotorio in a programatic manner. So an external application can interact with the game in real time.

There's also support for loading your own modules where we can add custom behavior to the game, say like being able to Create, read, update, or Delete items, the infamous CRUD that so many developers spend their career on. 

So if I had an application that could instruct factorio what I want to do (via RAC) then the module could perform those changes for us.

## Everythings a nail

Well I use a tool called [terraform](https://www.terraform.io/) to manage my infrastructure, and it lets me mix and match different cloud providers as needed. I wonder if I could use it to compose factorio.

Terraform is a tool that follows this flow:

1. Declare and modify your into `.tf` files showing the resources that depend on each other
2. Build a plan which will show which resources will be created, updated, or destroyed when we execute the `.tf` we've declared up to this point
3. Implement those changes
4. Go back to step 1 and repeat

We could write a terraform provider that will interact with our Factorio mod, through the rac. Allowing us to declare TF resources that are then created within factorio

## Great, let's test this out

Well, first let's get Factorio up and running here and let our local machine connect to it. https://hub.docker.com/r/factoriotools/factorio exists and after tweaking the mods a bit we've got a version that is up and running that we can connect to.

## Now the terraform

Just prior to jumping into it I stumbled across [this](https://registry.terraform.io/providers/efokschaner/factorio/latest/docs) a beautiful base lua module and terraform provider that was written as a proof of concept by the warrior-poet Efokschaner.

It doesn't quite do everything we'll want to do but we'll definitely not reinvent any wheels here we don't have to.

I've got that up and running and can run the default proof of concept. Fantastic. Now we just need to extend things a bit and give our selves some reusable concepts.

## The first terraform module

Great let's start with some `burner miner drill`s these are basically the first thing you build in the game, and harvest ores for coal, but while I can build them I need the ability to "preload" them with terraform with fuel, or these will be the non burning non mining varietey.

I've added support to lua mod to specify `contents` and loading stacks of items into entities as they are created. I then added an option `contents` block that lets us specify the desired parts and how many are in them.

After writing this, I can update my terraform like so, and the drill will now be happily churning until it runs out of fuel.


## Wait, isn't that just a blueprint?

Well, yes and no. Blueprints yes can be used to create entities but:

1. They require you to have a build bot that can build them
1. You can't deliver fuel to them
1. You have to be relatively close or daisy chain robo ports
1. if something changes it won't correct drift

## Starter base


