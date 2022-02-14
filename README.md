# Minidenticons

Super lightweight SVG identicon generator.

[![version](https://badgen.net/elm-package/v/laurentpayot/minidenticons)](https://github.com/laurentpayot/minidenticons-elm/blob/main/elm.json)
[![elm version](https://badgen.net/elm-package/elm/laurentpayot/minidenticons)](https://github.com/laurentpayot/minidenticons-elm/blob/main/elm.json)
[![license](https://badgen.net/elm-package/license/laurentpayot/minidenticons)](https://github.com/laurentpayot/minidenticons-elm/blob/main/LICENSE)

[![Minidenticons](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/minidenticons.png)](https://laurentpayot.github.io/minidenticons/)

## Why

Generate identicons (pixelated avatars) on the client from usernames instead of fetching images from a server!

## Live Demo 🎮

Play with it [here](https://laurentpayot.github.io/minidenticons/).

## Usage

```elm
identicon : Int -> Int -> Html msg
```

The `identicon` function will return a SVG string generated from its username string argument. The saturation and lightness arguments have to be percentages, i.e integers between 0 and 100.

```elm
identicon 50 50 "alienHead66"
```

For instance with the `alienHead66` username you will get the following identicon (for a saturation and lightness of 50%):

![Minidenticons](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/alienHead66_150.svg)

- Note that the picture above is resized. [By default identicons will take all the space available.](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/alienHead66.svg)

- The white space around the colored squares is here to allow uncropped circle avatars like the ones you can see in [the demo](https://laurentpayot.github.io/minidenticons/).

### Color Customization

Play with [the demo](https://laurentpayot.github.io/minidenticons/) to find a combination of saturation and lightness that matches your website theme colors: light, dark, pastel or whatever 😎

![Minidenticons light](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/minidenticons_light.png)
![Minidenticons dark](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/minidenticons_dark.png)
![Minidenticons pastel](https://raw.githubusercontent.com/laurentpayot/minidenticons-elm/main/img/minidenticons_pastel.png)

## Collisions

You will always get the same identicon for a given username. But it is not impossible to have different usernames with the same identicon. That's a [collision](https://en.wikipedia.org/wiki/Hash_collision).

Generated identicons are 5×5 pixels large with vertical symmetry, and can have 18 different hues for the same saturation and lightness.
This means there are 2⁽³×⁵⁾ × 18 = 589,824 different identicons possible, but actually much less because of the modulo-based algorithm used to get more colored pixels at the center of the identicon instead of having them scattered. So duplicate identicons are inevitable when using a lot of them. It shouldn’t matter as identicons should not be used solely to identify an user, and should always be coupled to a *unique* username :wink:

Tests results below show that you have roughly a 7% chance to generate a duplicate identicon when already using 1000 of them.

```bash
0 collisions out of 100 (0.00%)
0 collisions out of 200 (0.00%)
2 collisions out of 300 (0.67%)
6 collisions out of 400 (1.50%)
11 collisions out of 500 (2.20%)
21 collisions out of 600 (3.50%)
38 collisions out of 700 (5.43%)
49 collisions out of 800 (6.13%)
55 collisions out of 900 (6.11%)
66 collisions out of 1000 (6.60%)
296 collisions out of 2000 (14.80%)
589 collisions out of 3000 (19.63%)
962 collisions out of 4000 (24.05%)
1441 collisions out of 5000 (28.82%)
1965 collisions out of 6000 (32.75%)
2564 collisions out of 7000 (36.63%)
3173 collisions out of 8000 (39.66%)
3860 collisions out of 9000 (42.89%)
4570 collisions out of 10000 (45.70%)
```

## License

[BSD 3-Clause](https://github.com/laurentpayot/minidenticons-elm/blob/main/LICENSE)
