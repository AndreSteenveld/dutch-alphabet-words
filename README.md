# Dutch alphabet words

Is it possible to create a set of dutch words containing all the letters of the alphabet exactly once? 

This is clearly a fun programming exercise ala advent of code and not something that has a praticular value. I also want to experiment a little with PG to solve this. Other tools I used were `make` to easily run some simple commands, `docker / docker-compose` to run an instance of postgres and dbeaver + `psql` to as a convienent database clients.

# Running 

1. To start I downloaded the dutch wordlist from OpenTaal (`curl https://raw.githubusercontent.com/OpenTaal/opentaal-wordlist/master/wordlist.txt > ./wordlist.txt`)
2. `docker-compose up -d`
2. `make migrate-database`
3. `make import-words`

Cleaning the current state can be done using `make clean` which will remote the container and volume.

# How, why, what?

In my first attempt (see ./query-using-bitfields.sql) I tried working with bitfields as a mask to determine if any letters were already present in the a word chain. Figuring that doing simpel 'and's and 'or's would be very quick. Bitfields can be indexed but there is no way to do a check for overlap using a index which renders them a bit pointless for this situation. With this knowledge, is this possible using arrays?

<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/AndreSteenveld/dutch-alphabet-words">Dutch alphabet words</a> by <span property="cc:attributionName">Andre Steenveld</span> is licensed under <a href="http://creativecommons.org/licenses/by-nc-sa/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-SA 4.0</a></p>
