dotfiles=$(wildcard *.dot)
pngfiles=$(patsubst %.dot,%.png,$(dotfiles))

all:$(pngfiles)

%.png:%.dot
	@neato -Tpng $< -o $@

clean:
	@rm -rf *.png
