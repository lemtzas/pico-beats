pico8="../../../pico8"
CART=${1-snek-over-16}
$pico8 \
    -windowed 1 -width 512 -height 512 \
    -sound 256 -music 256 \
    -run $CART
