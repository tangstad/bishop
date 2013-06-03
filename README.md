# Bishop - Drunken Bishop implementation in Elixir

## Background
Drunken bishop is an algorithm used to implement fingerprint visualization in OpenSSH, described in ["The drunken bishop: An analysis of the OpenSSH fingerprint visualization algorithm"](http://www.dirk-loss.de/sshvis/drunken_bishop.pdf).

Aaron Toponce had a nice explanation of it on his [blog](http://pthree.org/2013/05/30/openssh-keys-and-the-drunken-bishop/), that made it seem like a nice exercise for learning some Elixir.

This is my first Elixir project, so comments and corrections, especially as pull requests, are appreciated.

## API
* Bishop.walkhex(hexstring) -- Generate visualization from the hexstring
* Bishop.walk_randomly(n)   -- Generate randomart with the bishop moving n positions

## Example
    iex> Bishop.walkhex "d4:d3:fd:ca:c4:d3:e9:94:97:cc:52:21:3b:e4:ba:e9"
    +-----------------+
    |             o . |
    |         . .o.o .|
    |        . o .+.. |
    |       .   ...=o+|
    |        S  . .+B+|
    |            oo+o.|
    |           o  o. |
    |          .      |
    |           E     |
    +-----------------+

## Command Line
A command line application can be generated with **mix escriptize**, and has the following usage:

    $ ./bishop d4:d3:fd:ca:c4:d3:e9:94:97:cc:52:21:3b:e4:ba:e9
    d4:d3:fd:ca:c4:d3:e9:94:97:cc:52:21:3b:e4:ba:e9
    +-----------------+
    |             o . |
    |         . .o.o .|
    |        . o .+.. |
    |       .   ...=o+|
    |        S  . .+B+|
    |            oo+o.|
    |           o  o. |
    |          .      |
    |           E     |
    +-----------------+

## Implementation
Considered as a series of transformations, we do the following conversions on the input string:

* Remove ":" delimiters between hexadecimal words
* Downcase
* Map each character into a value (0 to 15)
* Split up each value into two parts (each 0 to 3)
* Reverse local order of every series of four values
* Map to directions (northeast, northwest, southeast or southwest)
* Map directions to a set of traversed coordinates
* Map coordinates into a set of visited positions with count stored in HashDict
* Draw the area as ascii art, marking off start and end positions and mapping each count to a specific character

